#!/usr/bin/env python3
import io
import json
import logging
import os
import re
import shutil
import subprocess
import tarfile
import zipfile
from pathlib import Path
from urllib import request

from utils import ROOT_DIR, configure_logger

logger = logging.getLogger(__name__)

SOURCE_CODE_ASSET = "SOURCE_CODE_ASSET.zip"
BINARIES_DIR = Path("binaries")

with (ROOT_DIR / "binaries.json").open("r") as binaries_file:
    BINARIES = json.load(binaries_file)


def ensure_dirs(path):
    """ Creates `path` if it doesn't exist, else it does nothing. """
    if not path.parent.exists():
        os.makedirs(str(path.parent))


def _get_from_release_endpoint(repo_name, api_path=""):
    response = request.urlopen(f"https://api.github.com/repos/{repo_name}/releases/{api_path}")
    return json.load(response)


def get_release(repo_name, asset_regex, api_path):
    """
    Get an asset from a release of github repository using github's API.
    If the `asset_regex` is `SOURCE_CODE_ASSET`, it return the zip file of the source.
    returns the tuple (`asset_name`, `asset_content`).
    """
    logger.debug(f"Reading latest release of {repo_name}")
    response_data = _get_from_release_endpoint(repo_name, api_path=api_path)

    if asset_regex == SOURCE_CODE_ASSET:
        response = request.urlopen(response_data["zipball_url"]).read()
        return SOURCE_CODE_ASSET, response

    for asset in response_data["assets"]:
        if re.fullmatch(asset_regex, asset["name"]):
            response = request.urlopen(asset["browser_download_url"]).read()
            return asset["name"], response
    else:
        raise ValueError(f"No matching asset to regex {asset_regex}")


def get_latest_release(repo_name, asset_regex):
    return get_release(repo_name, asset_regex, "latest")


def get_release_by_tag(repo_name, asset_regex, tag_name):
    return get_release(repo_name, asset_regex, f"tags/{tag_name}")


def match_file_map_entry(base_path, entry_name, file_map):
    """ Search an entry in the file map that matches the entry in the received archive """
    matches = [
        match for match in (re.fullmatch(pattern, entry_name) for pattern in file_map)
        if match is not None
    ]

    if len(matches) == 0:
        return None
    elif len(matches) == 1:
        file_pattern = matches[0].re.pattern
        output_path = base_path / file_map[file_pattern]
    else:
        raise ValueError("Too many matches in file map")

    return output_path


def _extract_tarball(name, data, base_path, file_map):
    logger.debug(f"Extracting tar file: {name}")

    with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as tar_file:
        for member in tar_file.getmembers():

            output_path = match_file_map_entry(base_path, member.path, file_map)

            if output_path is None or output_path.exists():
                continue

            extracted_file = tar_file.extractfile(member)
            ensure_dirs(output_path)
            with output_path.open("wb") as output_file:
                output_file.write(extracted_file.read())
                output_path.chmod(0o755)


def _extract_zip(name, data, base_path, file_map):
    logger.debug(f"Extracting zip file: {name}")

    with zipfile.ZipFile(io.BytesIO(data), mode="r") as zip_file:

        for entry_name in zip_file.namelist():
            original_entry_name = entry_name

            if name == SOURCE_CODE_ASSET:
                entry_name = os.sep.join(Path(entry_name).parts[1:])

            output_path = match_file_map_entry(base_path, entry_name, file_map)
            if output_path is None or output_path.exists():
                continue

            extracted_data = zip_file.read(original_entry_name)
            ensure_dirs(output_path)
            with output_path.open("wb") as output_file:
                output_file.write(extracted_data)
                output_path.chmod(0o755)


def write_or_extract_binaries(name, data, base_path, file_map):
    """
    Write or extract a binary named `name` that contains `data` to `base_path` based on `file_map`.
    Based on `name` it can extract tar.gz and zip files or just write plain non-archive file.
    the `file_map` maps an entry in the archive to relative path in `base_path`.
    """
    if name.endswith(".tar.gz"):
        _extract_tarball(name, data, base_path, file_map)

    elif name.endswith(".zip"):
        _extract_zip(name, data, base_path, file_map)
    else:
        logger.debug(f"Saving regular file: {name}")
        output_path = base_path / file_map[name]
        ensure_dirs(output_path)
        with output_path.open("wb") as output_file:
            output_file.write(data)
            output_path.chmod(0o755)


def is_download_required(binaries, base_path, name):
    """ Check if all the required files in `BINARIES` exist. """
    for path in binaries[name]["file_map"].values():
        if not (base_path / path).exists():
            return True
    return False


def download_sym():
    """This is an ugly hack until this script gets a gitlab support or is being rewritten in rust."""
    sym_path = Path(BINARIES_DIR) / "usr/bin/sym"
    if not sym_path.exists():
        response = request.urlopen("https://gitlab.com/api/v4/projects/OmerSarig%2Fsym/releases")
        releases = json.load(response)
        sym_url = releases[0]["assets"]["links"][0]["url"]
        import ipdb;ipdb.set_trace()
        sym_data = request.urlopen(sym_url).read()
        with sym_path.open("wb") as sym_file:
            sym_file.write(sym_data)


def download_submodules():
    """ Download git submodules """
    subprocess.check_call(["git", "submodule", "update", "--init"])


def download_binaries():
    """ Download all binaries specified in `binaries` into `base_path` """
    for name, binary in BINARIES.items():
        if is_download_required(BINARIES, BINARIES_DIR, name):
            logger.info(f"Downloading {name}")
            if "tag" in binary:
                asset_name, asset_data = get_release_by_tag(binary["repo"], binary["asset_regex"], binary["tag"])
            else:
                asset_name, asset_data = get_latest_release(binary["repo"], binary["asset_regex"])
            write_or_extract_binaries(asset_name, asset_data, BINARIES_DIR, BINARIES[name]["file_map"])
        else:
            logger.debug(f"Downloading {name} is not required")


def download_vim_plugins():
    """ Download vim plugins and tools """
    new_env_vars = dict(os.environ)
    new_env_vars["DOWNLOAD_MODE"] = "true"
    new_env_vars["XDG_CONFIG_HOME"] = ROOT_DIR / "neovim/etc/xdg/"
    subprocess.check_call(
        ["binaries/usr/bin/nvim", "--appimage-extract-and-run", "--headless"],
        env=new_env_vars
    )


def download_zsh_plugins():
    """ Download zsh plugins using zcomet """
    zsh_init_path = ROOT_DIR / "zsh/usr/share/zsh/config/init.zsh"
    subprocess.check_call(["zsh", str(zsh_init_path)])


def fix_permissions():
    """ Change ownership to the directory of this script if it is executed with sudo. """
    real_user = os.environ.get("SUDO_USER", None)
    if real_user is not None:
        subprocess.call(["chown", "-f", "-R", real_user, ROOT_DIR, f"/home/{real_user}/.local/share/nvim"])


def update_zsh_plugins():
    zsh_init_path = ROOT_DIR / "zsh/usr/share/zsh/config/plugins.zsh"
    subprocess.call(["zsh", "-c", f"source {zsh_init_path}", "-c", "zcomet update"])


def download():
    """ Download all dependencies """
    required_commands = ["git", "zsh"]
    missing_commands = [command for command in required_commands if shutil.which(command) is None]
    if len(missing_commands) > 0:
        logger.error(f"Please install the following commands: {', '.join(missing_commands)}")
        return

    download_functions = [
        ("Sym", download_sym),
        ("Submodules", download_submodules),
        ("Binaries", download_binaries),
        ("Vim plugins", download_vim_plugins),
        ("Zsh plugins", update_zsh_plugins)
    ]

    try:
        for name, function in download_functions:
            logger.info(f"Downloading {name}")
            function()
    finally:
        fix_permissions()


def main():
    configure_logger(False)
    download()


if __name__ == "__main__":
    main()
