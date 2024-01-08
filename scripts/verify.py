#!/usr/bin/env python3
import shutil

VALID = "\x1b[92mValid\x1b[39m"
INVALID = "\x1b[91mInvalid\x1b[39m"


def check_commands(*commands):
    for command in commands:
        if shutil.which(command) is not None:
            return True
    return False


def check_import(import_name):
    try:
        __import__(import_name)
    except ImportError:
        return False
    else:
        return True


FEATURES = {
    "ag": (check_commands, "ag"),
    "zsh": (check_commands, "zsh"),
    "git": (check_commands, "git"),
    "unzip": (check_commands, "unzip"),
    "wget": (check_commands, "wget"),
    "dploy": (check_import, "dploy")
}


def verify_environment():
    invalid_features = []

    print("Verifying:")

    for name, (function, args) in FEATURES.items():
        if type(args) not in (list, tuple):
            args = [args]
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
