#!/usr/bin/env python3
import shutil

try:
    import colorama
except ImportError:
    colorama = None

VALID = "Valid"
INVALID = "Invalid"
if colorama is not None:
    VALID = colorama.Fore.LIGHTGREEN_EX + VALID + colorama.Fore.RESET
    INVALID = colorama.Fore.LIGHTRED_EX + INVALID + colorama.Fore.RESET


def check_command(command):
    return shutil.which(command) is not None


def check_import(import_name):
    try:
        __import__(import_name)
    except ImportError:
        return False
    else:
        return True


FEATURES = {
    "ag": (check_command, ["ag"]),
    "zsh": (check_command, ["zsh"]),
    "pyls": (check_command, ["pyls"]),
    "clangd": (check_command, ["clangd"]),
    "python-neovim": (check_import, ["neovim.api"]),
    "requests": (check_import, ["requests"]),
    "dploy": (check_import, ["dploy"])
}


def verify_environment():
    invalid_features = []

    print("Verifying:")

    for name, (function, args) in FEATURES.items():
        is_valid = function(*args)
        print(f"    {name.ljust(20)}{VALID if is_valid else INVALID}")
        if not is_valid:
            invalid_features.append(name)

    if len(invalid_features) == 0:
        print(f"\nAll features are {VALID.lower()}")
        return True
    else:
        print(f"\n{INVALID} features: {', '.join(invalid_features)}")
        return False


def main():
    return not verify_environment()


if __name__ == '__main__':
    exit(main())
