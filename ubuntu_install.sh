#!/bin/sh

main ()
{
    if [ "$(id -u -n)" != "root" ]; then
        echo Please execute this script as root\!
        exit 1
    fi

    apt update
    apt install -y silversearcher-ag zsh git python3-pip
    # Required for install.py
    pip3 install -q requests dploy
    # This packages collide with some of the binaries
    apt purge -y vim vim-common vim-runtime vim-tiny tmux

    python3 install.py install

    export HOME=$(sh -c "echo ~${SUDO_USER:-}")
    export ZSHRC=$HOME/.zshrc
    if [ -f $ZSHRC ]; then
        echo "Copy to $ZSHRC:\n"
        cat zshrc.example
    else
        cp -n zshrc.example $ZSHRC
    fi
}

main $*
