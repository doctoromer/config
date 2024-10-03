#!/usr/bin/env python3
import argparse
import logging
import subprocess
import sys
from pathlib import Path

from utils import ROOT_DIR, configure_logger

logger = logging.getLogger(__name__)

PACKAGES = ["misc", "neovim", "zsh", "binaries"]


def auto_remove():
    example_binary = Path("/usr/bin/vim")
    if example_binary.is_symlink():
        # We resolve the symlink to vim binary, then go up to the root of the config dir to find the install.py script
        install_script_path = example_binary.resolve().parents[3] / "scripts" / "install.py"
        logger.info(f"Executing remove script in: {install_script_path}")
        subprocess.check_call(["python3", install_script_path, "remove"])
    else:
        logger.info("No previously installed config detected, exiting...")


def create_symlinks(action, packages, profile):
    packages = sum((["-s", str(ROOT_DIR / package)] for package in packages), [])
    try:
        sym_path = str(ROOT_DIR / "binaries/usr/bin/sym")
        subprocess.check_call(
            [sym_path, action, "--linkmap", "linkmap.toml", "--profile", profile],
            env={"RUST_BACKTRACE": "1"}
        )
    except PermissionError:
        logger.error("Please run again with root")


def parse_args():
    subcommands = {
        "download": "Download required files",
        "install": "Create symlinks to the configuration",
        "remove": "Remove symlinks to the configuration",
        "auto-remove": "Remove previous installation of this config"
    }
    parser = argparse.ArgumentParser()
    parser.add_argument("-v", action="store_true", default=False, dest="verbose", help="Show more logs")

    subparsers_parser = parser.add_subparsers()
    subparsers = {}
    for subcommand, help_text in subcommands.items():
        subparsers[subcommand] = subparsers_parser.add_parser(subcommand, help=help_text)
        subparsers[subcommand].set_defaults(command=subcommand)

    for command in ("install", "remove", "auto-remove"):
        subparsers[command].add_argument("--packages", "-p", default=None)
        subparsers[command].add_argument("--profile", default="system")

    args = parser.parse_args()
    if not hasattr(args, "command"):
        parser.print_help()
        return None
    else:
        return args


def main():
    args = parse_args()

    if args is None:
        return 1

    configure_logger(args.verbose)

    if sys.version_info < (3, 6):
        logger.error("Python version should be atleast 3.6!")
        return 1

    logger.debug(f"Executing {args.command} command")

    if args.command in ("install", "remove"):
        if args.packages is None:
            packages = PACKAGES
        else:
            packages = args.packages.split(",")

    if args.command == "install":
        try:
            create_symlinks("link", packages, args.profile)
            if args.profile == "local":
                subprocess.check_call(["git", "config", "--global", "include.path", "~/.config/gitconfig"])
        except Exception as err:
            logger.error(err.args[0])
            return 1
        else:
            logger.info("Finish installation successfully")
            return 0
    elif args.command == "remove":
        create_symlinks("unlink", packages, args.profile)
        if args.profile == "local":
            subprocess.check_call(["git", "config", "--global", "--unset", "include.path"])
    elif args.command == "auto-remove":
        auto_remove()
    else:
        logger.error(f"Unknown command: {args.command}")
        return 1


if __name__ == "__main__":
    exit(main())
