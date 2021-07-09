#!/usr/bin/env python3
import argparse
import io
import logging
import os
import re
import subprocess
from pathlib import Path
import tarfile
import zipfile

import dploy
import requests

try:
    from rich.logging import RichHandler
except ImportError:
    RichHandler = None


logger = logging.getLogger(__name__)

SOURCE_CODE_ASSET = "SOURCE_CODE_ASSET.zip"


BINARIES = {
    "fzf": {
        "repo": "junegunn/fzf",
        "asset_regex": "fzf.*linux.*amd64.*",
        "file_map": {
            "fzf": "usr/bin/fzf"
        }
    },
    "fzf-completion": {
        "repo": "junegunn/fzf",
        "asset_regex": SOURCE_CODE_ASSET,
        "file_map": {
            "shell/completion.zsh": "usr/local/share/zsh/site-functions/fzf-completion.zsh",
            "shell/key-bindings.zsh": "usr/local/share/zsh/site-functions/fzf-key-bindings.zsh"
        }
    },
    "exa": {
        "repo": "ogham/exa",
        "asset_regex": "exa.*linux.*x86_64.*",
        "file_map": {
            "bin/exa": "usr/bin/exa",
            "man/exa.1": "usr/share/man/man1/exa.1",
            "completions/exa.zsh": "usr/local/share/zsh/site-functions/exa.zsh"
        }
    },
    "vim": {
        "repo": "neovim/neovim",
        "asset_regex": "nvim.appimage",
        "file_map": {
            "nvim.appimage": "usr/bin/vim"
        }
    },
    "diff-so-fancy": {
        "repo": "so-fancy/diff-so-fancy",
        "asset_regex": "diff-so-fancy",
        "file_map": {
            "diff-so-fancy": "usr/bin/diff-so-fancy"
        }
    }
}

PACKAGES = ["misc", "neovim", "zsh", "binaries"]
BINARIES_DIR = "binaries"


def ensure_dirs(path):
    """ Creates `path` if it doesn't exist, else it does nothing. """
    if not path.parent.exists():
        os.makedirs(str(path.parent))


def get_latest_release(repo_name, asset_regex):
    """
    Get an asset from the last release of github repository using github's API.
    If the `asset_regex` is `SOURCE_CODE_ASSET`, it return the zip file of the source.
    returns the tuple (`asset_name`, `asset_content`).
    """
    logger.info(f"Reading latest release of {repo_name}")
    with requests.get(f"https://api.github.com/repos/{repo_name}/releases/latest") as response:
        response_data = response.json()

    if asset_regex == SOURCE_CODE_ASSET:
        with requests.get(response_data["zipball_url"]) as response:
            return SOURCE_CODE_ASSET, response.content

    for asset in response_data["assets"]:
        if re.match(asset_regex, asset["name"]):
            with requests.get(asset["browser_download_url"]) as response:
                return asset["name"], response.content


def _extract_tarball(name, data, base_dir, file_map):
    logger.info(f"Extracting tar file: {name}")

    with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as tar_file:
        for member in tar_file.getmembers():
            if member.path not in file_map:
                continue
            output_path = base_dir / file_map[member.path]
            if output_path.exists():
                continue

            extracted_file = tar_file.extractfile(member)
            ensure_dirs(output_path)
            with output_path.open("wb") as output_file:
                output_file.write(extracted_file.read())
                output_path.chmod(0o755)


def _extract_zip(name, data, base_dir, file_map):
    logger.info(f"Extracting zip file: {name}")

    with zipfile.ZipFile(io.BytesIO(data), mode="r") as zip_file:

        for entry_name in zip_file.namelist():
            original_entry_name = entry_name
            if name == SOURCE_CODE_ASSET:
                entry_name = os.sep.join(Path(entry_name).parts[1:])

            if entry_name not in file_map:
                continue

            output_path = base_dir / file_map[entry_name]
            if output_path.exists():
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
        logger.info(f"Saving regular file: {name}")
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


def download_binaries(binaries, base_dir):
    """ Download all binaries specified in `binaries` into `base_dir` """
    for name, binary in binaries.items():
        if is_download_required(binaries, base_dir, name):
            logger.info(f"Downloading {name}")
            asset_name, asset_data = get_latest_release(binary["repo"], binary["asset_regex"])
            write_or_extract_binaries(asset_name, asset_data, base_dir, binaries[name]["file_map"])
        else:
            logger.info(f"Downloading {name} is not required")


def post_install():
    """
    Executing post-install tasks.
    Currently, only updating remote plugins in vim.
    """
    logger.info("Updating neovim remote plugins")
    subprocess.check_call("vim --headless -c :UpdateRemotePlugins -c :q".split(" "))


def parse_args():
    subcommands = {
        "verify": "Verify that essential programs are installed",
        "download": "Download required files",
        "install": "Create symlinks to the configuration",
        "remove": "Remove symlinks to the configuration"
    }
    parser = argparse.ArgumentParser()
    subparsers_parser = parser.add_subparsers()
    subparsers = {}
    for subcommand, help_text in subcommands.items():
        subparsers[subcommand] = subparsers_parser.add_parser(subcommand, help=help_text)
        subparsers[subcommand].set_defaults(command=subcommand)

    for command in ("install", "remove"):
        subparsers[command].add_argument(
            "--packages",
            "-p",
            choices=["all"] + PACKAGES,
            default="all"
        )

    return parser.parse_args()


def configure_logger():
    FORMAT = "%(message)s"
    if RichHandler is not None:
        handler = RichHandler(rich_tracebacks=True, tracebacks_show_locals=True)
    else:
        handler = logging.StreamHandler()

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)-15s - %(levelname)s - %(message)s",
        datefmt="[%X]",
        handlers=[handler],
    )


def main():
    configure_logger()
    args = parse_args()

    logger.info(f"Executing {args.command} command")

    if args.command == "install":
        if args.packages == "all":
            packages = PACKAGES
        else:
            packages = args.packages
        dploy.stow(packages, "/")
        if "neovim" in packages:
            post_install()

    elif args.command == "remove":
        if args.packages == "all":
            dploy.unstow(PACKAGES, "/")
        else:
            dploy.unstow(args.packages, "/")
    elif args.command == "download":
        download_binaries(BINARIES, BINARIES_DIR)
    elif args.command == "verify":
        pass
    else:
        logger.error(f"Unknown command: {args.command}")


if __name__ == "__main__":
    main()
