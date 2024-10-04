#!/bin/bash -e

SCRIPT_DIR=$(dirname $(realpath "$0"))

main ()
{
    profile=$1

    case $profile in
        local|system)
            ;;
        *|-h|--help)
            echo "Usage: $0 system|local"
            echo "system: System wide installation"
            echo "local: User local installation"
            exit
            ;;
    esac

    if [ "$(id -u -n)" != "root" ]; then
        echo Please execute this script as root\!
        exit 1
    fi

    echo Updating apt sources...
    apt update -qq

    echo Installing zsh, git, and pip3
    apt install -y -qqq zsh git python3-pip libfuse2
    if [ $profile != "system" ]; then
        # This packages collide with some of the binaries
        echo Removing tmux and neovim \(new versions are packed with the config\)
        apt purge -y -qqq tmux neovim
    fi

    python3 $SCRIPT_DIR/install.py auto-remove

    case $profile in
        local)
            su -c "python3 $SCRIPT_DIR/install.py install --profile $profile" $SUDO_USER
            ;;
        system)
            python3 $SCRIPT_DIR/install.py install --profile $profile
            ;;
    esac

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
