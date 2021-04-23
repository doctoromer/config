#!/bin/sh

# If stow is not installed, display error message and exit
command -v stow >/dev/null 2>&1 || {
    echo >&2 Please install stow:
    echo >&2
    echo >&2 " " sudo apt install stow
    echo >&2
    exit 1
}

if [ $# -ne 1 ]; then
    echo >&2 Invalid number of arguments!
    exit 1
fi

STOW_FLAGS="--target=/ --ignore=DEBIAN -v"
PACKAGE=omer-config

case "$1" in
    link)
        ./build.sh setup
        sudo stow $STOW_FLAGS $PACKAGE
        sudo bash $PACKAGE/DEBIAN/postinst configure
        ;;
    unlink)
        sudo stow -D $STOW_FLAGS $PACKAGE
        ;;
    *)
        echo "Usage: $0 link|unlink"
esac
