#!/bin/sh

BUILD_DIR=build
TARGET_NAME=omer-config

setup() {
    mkdir -p $BUILD_DIR

    cd omer-config/etc/xdg/nvim/bundle/LanguageClient-neovim
    ./install.sh
    cd -

    cd omer-config/usr/local/src/fzf
    ./install --bin
    cd -

    EXA_BIN=$TARGET_NAME/usr/bin/exa
    if [ ! -e $EXA_BIN ]; then
        wget https://github.com/ogham/exa/releases/download/v0.9.0/exa-linux-x86_64-0.9.0.zip -q -O $BUILD_DIR/exa.zip
        unzip $BUILD_DIR/exa.zip -d $BUILD_DIR
        rm $BUILD_DIR/exa.zip
        mv $BUILD_DIR/exa* $EXA_BIN
    fi

}

build() {
    setup
    # Build main deb package
    dpkg-deb --build $TARGET_NAME
    mv $TARGET_NAME.deb $BUILD_DIR
}


case "$1" in
    setup)
        setup
        ;;
    *)
        setup
        build
esac
