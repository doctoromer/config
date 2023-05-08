#!/usr/bin/env python3
import argparse
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

import dploy
import requests

try:
    from rich.logging import RichHandler
except ImportError:
    RichHandler = None

import verify


logger = logging.getLogger(__name__)

SOURCE_CODE_ASSET = "SOURCE_CODE_ASSET.zip"

SCRIPT_DIR = Path(__file__).parent

with open("binaries.json", "r") as binaries_file:
    BINARIES = json.load(binaries_file)


PACKAGES = ["misc", "neovim", "zsh", "binaries"]
BINARIES_DIR = "binaries"


def ensure_dirs(path):
    """ Creates `path` if it doesn't exist, else it does nothing. """
    if not path.parent.exists():
        os.makedirs(str(path.parent))


def _get_from_release_endpoint(repo_name, api_path=""):
    with requests.get(f"https://api.github.com/repos/{repo_name}/releases/{api_path}") as response:
        response_data = response.json()
        return response_data


def get_release(repo_name, asset_regex, api_path):
    """
    Get an asset from a release of github repository using github's API.
    If the `asset_regex` is `SOURCE_CODE_ASSET`, it return the zip file of the source.
    returns the tuple (`asset_name`, `asset_content`).
    """
    logger.debug(f"Reading latest release of {repo_name}")
    response_data = _get_from_release_endpoint(repo_name, api_path=api_path)

    if asset_regex == SOURCE_CODE_ASSET:
        with requests.get(response_data["zipball_url"]) as response:
            return SOURCE_CODE_ASSET, response.content

    for asset in response_data["assets"]:
        if re.match(asset_regex, asset["name"]):
            with requests.get(asset["browser_download_url"]) as response:
                return asset["name"], response.content
    else:
        raise ValueError(f"No matching asset to regex {asset_regex}")


def get_latest_release(repo_name, asset_regex):
    return get_release(repo_name, asset_regex, "latest")


def get_release_by_tag(repo_name, asset_regex, tag_name):
    return get_release(repo_name, asset_regex, f"tags/{tag_name}")


def match_file_map_entry(base_dir, entry_name, file_map):
    """ Search an entry in the file map that matches the entry in the received archive """
    matches = [
        match for match in (re.match(pattern, entry_name) for pattern in file_map)
        if match is not None
    ]

    if len(matches) == 0:
        return None
    elif len(matches) == 1:
        file_pattern = matches[0].re.pattern
        output_path = base_dir / file_map[file_pattern]
    else:
        raise ValueError("Too many matches in file map")

    return output_path


def _extract_tarball(name, data, base_dir, file_map):
    logger.debug(f"Extracting tar file: {name}")

    with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as tar_file:
        for member in tar_file.getmembers():

            output_path = match_file_map_entry(base_dir, member.path, file_map)

            if output_path is None or output_path.exists():
                continue

            extracted_file = tar_file.extractfile(member)
            ensure_dirs(output_path)
            with output_path.open("wb") as output_file:
                output_file.write(extracted_file.read())
                output_path.chmod(0o755)


def _extract_zip(name, data, base_dir, file_map):
    logger.debug(f"Extracting zip file: {name}")

    with zipfile.ZipFile(io.BytesIO(data), mode="r") as zip_file:

        for entry_name in zip_file.namelist():
            original_entry_name = entry_name

            if name == SOURCE_CODE_ASSET:
                entry_name = os.sep.join(Path(entry_name).parts[1:])

            output_path = match_file_map_entry(base_dir, entry_name, file_map)
            if output_path is None or output_path.exists():
                continue

            extracted_data = zip_file.read(original_entry_name)
            ensure_dirs(output_path)
            with output_path.open("wb") as output_file:
                output_file.write(extracted_data)
                output_path.chmod(0o755)


def write_or_extract_binaries(name, data, base_dir, file_map):
    """
    Write or extract a binary named `name` that contains `data` to `base_dir` based on `file_map`.
    Based on `name` it can extract tar.gz and zip files or just write plain non-archive file.
    the `file_map` maps an entry in the archive to relative path in `base_dir`.
    """
    base_dir = Path(base_dir)

    if name.endswith(".tar.gz"):
        _extract_tarball(name, data, base_dir, file_map)

    elif name.endswith(".zip"):
        _extract_zip(name, data, base_dir, file_map)
    else:
        logger.debug(f"Saving regular file: {name}")
        output_path = base_dir / file_map[name]
        ensure_dirs(output_path)
        with output_path.open("wb") as output_file:
            output_file.write(data)
            output_path.chmod(0o755)


def is_download_required(binaries, base_dir, name):
    """ Check if all the required files in `BINARIES` exist. """
    base_dir = Path(base_dir)
    for path in binaries[name]["file_map"].values():
        if not (base_dir / path).exists():
            return True
    return False


def download_submodules():
    """ Download git submodules """
    subprocess.check_call(["git", "submodule", "update", "--init"])


def download_binaries():
    """ Download all binaries specified in `binaries` into `base_dir` """
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
    subprocess.check_call(["binaries/usr/bin/vim", "--cmd", 'lua vim.g.download_mode = true', "--headless"])


def download_zsh_plugins():
    """ Download zsh plugins using zcomet """
    zsh_init_path = SCRIPT_DIR / "zsh/usr/share/zsh/config/init.zsh"
    subprocess.check_call(["zsh", str(zsh_init_path)])


def fix_permissions():
    """ Change ownership to the directory of this script if it is executed with sudo. """
    real_user = os.environ.get("SUDO_USER", None)
    if real_user is not None:
        subprocess.call(["chown", "-f", "-R", real_user, SCRIPT_DIR, f"/home/{real_user}/.local/share/nvim"])


def update_zsh_plugins():
    zsh_init_path = SCRIPT_DIR / "zsh/usr/share/zsh/config/plugins.zsh"
    subprocess.call(["zsh", "-c", f"source {zsh_init_path}", "-c", "zcomet update"])


def download():
    """ Download all dependencies """
    required_commands = ["git", "zsh", "wget", "unzip"]
    missing_commands = [command for command in required_commands if shutil.which(command) is None]
    if len(missing_commands) > 0:
        logger.error(f"Please install the following commands: {', '.join(missing_commands)}")
        return

    download_functions = [
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


def auto_remove():
    example_binary = Path("/usr/bin/vim")
    if example_binary.is_symlink():
        # We resolve the symlink to vim binary, then go up to the root of the config dir to find the install.py script
        install_script_path = example_binary.resolve().parents[3] / "install.py"
        logger.info(f"Executing remove script in: {install_script_path}")
        subprocess.check_call(["python3", install_script_path, "remove"])
    else:
        logger.info("No previously installed config detected, exiting...")


def parse_args():
    subcommands = {
        "verify": "Verify that essential programs are installed",
        "download": "Download required files",
        "install": "Create symlinks to the configuration",
        "remove": "Remove symlinks to the configuration",
        "auto-remove": "Remove previous installation of this config"
    }
    parser = argparse.ArgumentParser()
    parser.add_argument("-v", action="store_true", default=False, dest="verbose")
    subparsers_parser = parser.add_subparsers()
    subparsers = {}
    for subcommand, help_text in subcommands.items():
        subparsers[subcommand] = subparsers_parser.add_parser(subcommand, help=help_text)
        subparsers[subcommand].set_defaults(command=subcommand)

    for command in ("install", "remove", "auto-remove"):
        subparsers[command].add_argument("--packages", "-p", default=None)

    return parser.parse_args()


def configure_logger(verbose):
    if RichHandler is not None:
        handler = RichHandler(rich_tracebacks=True, tracebacks_show_locals=True)
    else:
        handler = logging.StreamHandler()

    logging.basicConfig(
        level=logging.DEBUG if verbose else logging.INFO,
        format="%(asctime)-15s - %(levelname)s - %(message)s",
        datefmt="[%X]",
        handlers=[handler],
    )


def execute_dploy(action, packages):
    try:
        getattr(dploy, action)(packages, "/")
    except PermissionError:
        logger.error("Please run again with root")


def main():
    args = parse_args()
    configure_logger(args.verbose)

    logger.debug(f"Executing {args.command} command")

    if args.command in ("install", "remove"):
        if args.packages is None:
            packages = PACKAGES
        else:
            packages = args.packages.split(",")

    if args.command == "install":
        try:
            execute_dploy("stow", packages)
        except Exception as err:
            logger.error(err.args[0])
            return 1
        else:
            logger.info("Finish installation successfully")
            return 0
    elif args.command == "remove":
        execute_dploy("unstow", packages)
    elif args.command == "auto-remove":
        auto_remove()
    elif args.command == "download":
        download()
    elif args.command == "verify":
        verify.verify_environment()
    else:
        logger.error(f"Unknown command: {args.command}")
        return 1


if __name__ == "__main__":
    exit(main())
