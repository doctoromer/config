#!/bin/sh

main ()
{
    if [[ ! $(id -u -n) == "root" ]]; then
        echo Please execute this script as root\!
        exit 1
    fi

    apt update
    apt install -y silversearcher-ag zsh git python3-pip
    # Required for install.py
    pip3 install -q dploy
    # This packages collide with some of the binaries
    apt purge -y vim vim-common vim-runtime vim-tiny tmux

    python3 install.py install

    export HOME=$(sh -c "echo ~${SUDO_USER:-}")
    cp -n zshrc.example $HOME/.zshrc
}

main $*
