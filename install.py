#!/usr/bin/env python3
import io
import os
import re
from pathlib import Path
import tarfile
import zipfile

import dploy
import requests


BINARIES = {
    "fzf": {
        "repo": "junegunn/fzf",
        "asset_regex": "fzf.*linux.*amd64.*",
        "file_map": {
            "fzf": "usr/bin/fzf"
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
    }
}


def ensure_dirs(path):
    if not path.parent.exists():
        os.makedirs(str(path.parent))


def get_latest_release(repo_name, asset_regex):
    with requests.get(f"https://api.github.com/repos/{repo_name}/releases/latest") as response:
        assets = response.json()["assets"]

    for asset in assets:
        if re.match(asset_regex, asset["name"]):
            with requests.get(asset["browser_download_url"]) as response:
                return asset["name"], response.content


def write_or_extract_binaries(name, data, base_dir, file_map):
    base_dir = Path(base_dir)

    if name.endswith(".tar.gz"):
        with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as tar_file:

            for member in tar_file.getmembers():
                if name not in file_map:
                    continue
                output_path = base_dir / file_map[name]
                if output_path.exists():
                    continue

                extracted_file = tar_file.extractfile(member)
                ensure_dirs(output_path)
                with output_path.open("wb") as output_file:
                    output_file.write(extracted_file.read())
                    output_path.chmod(0o755)

    elif name.endswith(".zip"):
        with zipfile.ZipFile(io.BytesIO(data), mode="r") as zip_file:

            for name in zip_file.namelist():
                if name not in file_map:
                    continue
                output_path = base_dir / file_map[name]
                if output_path.exists():
                    continue

                extracted_data = zip_file.read(name)
                ensure_dirs(output_path)
                with output_path.open("wb") as output_file:
                    output_file.write(extracted_data)
                    output_path.chmod(0o755)

    else:
        output_path = base_dir / file_map[name]
        ensure_dirs(output_path)
        with output_path.open("wb") as output_file:
            output_file.write(data)
            output_path.chmod(0o755)


def is_download_required(base_dir, name):
    base_dir = Path(base_dir)
    for path in BINARIES[name]["file_map"].values():
        if not (base_dir / path).exists():
            return True
    return False


def download_binaries(base_dir):
    for name, binary in BINARIES.items():
        if is_download_required(base_dir, name):
            print(f"Downloading {name}")
            asset_name, asset_data = get_latest_release(binary["repo"], binary["asset_regex"])
            write_or_extract_binaries(asset_name, asset_data, base_dir, BINARIES[name]["file_map"])
        else:
            print(f"Downloading {name} is not required")


if __name__ == '__main__':
    main()
