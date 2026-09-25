#!/bin/bash -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")
COOL="$ROOT_DIR/binaries/usr/bin/cool"

main()
{
    profile=${1:-}

    case $profile in
        local|system)
            ;;
        -h|--help|*)
            echo "Usage: $0 system|local"
            echo "system: System wide installation"
            echo "local: User local installation"
            exit
            ;;
    esac

    if [ "$(id -u)" != "0" ]; then
        echo "Please execute this script as root!"
        exit 1
    fi

    if [ ! -x "$COOL" ]; then
        echo "Missing installer: $COOL"
        exit 1
    fi

    target_user=${SUDO_USER:-root}
    target_home=$(getent passwd "$target_user" | cut -d: -f6)

    echo "Updating apt sources..."
    apt update -qq

    echo "Installing zsh, git, libfuse2, xclip"
    apt install -y -qqq zsh git libfuse2 xclip
    if [ "$profile" != "system" ]; then
        echo "Removing tmux and neovim (new versions are packed with the config)"
        apt purge -y -qqq tmux neovim
    fi

    case $profile in
        local)
            runuser -u "$target_user" -- env HOME="$target_home" \
                "$COOL" --root "$ROOT_DIR" install --profile "$profile"
            ;;
        system)
            "$COOL" --root "$ROOT_DIR" install --profile "$profile"
            ;;
    esac

    zshrc="$target_home/.zshrc"
    if [ -f "$zshrc" ]; then
        printf 'Copy to %s:\n\n' "$zshrc"
        cat "$ROOT_DIR/zshrc.example"
    else
        cp --update=none "$ROOT_DIR/zshrc.example" "$zshrc"
        chown "$target_user:$target_user" "$zshrc"
        echo "Created zshrc in $zshrc"
    fi
}

main "$@"
