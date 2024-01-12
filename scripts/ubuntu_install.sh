#!/bin/bash -e

SCRIPT_DIR=$(dirname $(realpath "$0"))

main ()
{
    if [ "$(id -u -n)" != "root" ]; then
        echo Please execute this script as root\!
        exit 1
    fi

    echo Updating apt sources...
    apt update -qq

    echo Installing ag, zsh, git, and pip3
    apt install -y -qqq silversearcher-ag zsh git python3-pip libfuse2
    # Required for install.py
    pip3 install -qqq dploy
    # This packages collide with some of the binaries
    echo Removing tmux and neovim \(new versions are packed with the config\)
    apt purge -y -qqq tmux neovim

    python3 $SCRIPT_DIR/install.py auto-remove
    python3 $SCRIPT_DIR/install.py install

    export HOME=$(sh -c "echo ~${SUDO_USER:-}")
    export ZSHRC=$HOME/.zshrc

    if [ -f $ZSHRC ]; then
        echo -e "Copy to $ZSHRC:\n"
        cat zshrc.example
    else
        cp -n zshrc.example $ZSHRC
        chown $SUDO_USER:$SUDO_USER $ZSHRC
        echo Created zshrc in $ZSHRC
    fi
}

main $*
