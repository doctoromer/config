#!/bin/bash -e

main ()
{
    if [ "$(id -u -n)" != "root" ]; then
        echo Please execute this script as root\!
        exit 1
    fi

    echo Updating apt sources...
    apt update -qq

    echo
    apt install -y -qq silversearcher-ag zsh git python3-pip libfuse2
    # Required for install.py
    pip3 install -q requests dploy
    # This packages collide with some of the binaries
    apt purge -y -qq vim vim-common vim-runtime vim-tiny tmux neovim

    echo
    python3 install.py auto-remove
    python3 install.py install

    echo

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
