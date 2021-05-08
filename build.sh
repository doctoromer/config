#!/bin/sh

BUILD_DIR=build
TARGET_NAME=omer-config

EXA_BINARY=$TARGET_NAME/usr/bin/exa
DSF_BINARY=$TARGET_NAME/usr/bin/diff-so-fancy


setup() {
    mkdir -p $BUILD_DIR

    cd omer-config/etc/xdg/nvim/bundle/LanguageClient-neovim
    ./install.sh
    cd -

    cd omer-config/usr/local/src/fzf
    ./install --bin
    cd -

    if [ ! -e $EXA_BINARY ]; then
        wget https://github.com/ogham/exa/releases/download/v0.9.0/exa-linux-x86_64-0.9.0.zip -q -O $BUILD_DIR/exa.zip
        unzip $BUILD_DIR/exa.zip -d $BUILD_DIR
        rm $BUILD_DIR/exa.zip
        mv $BUILD_DIR/exa* $EXA_BINARY
        chmod +x $EXA_BINARY
    fi

    if [ ! -e $DSF_BINARY ]; then
        wget https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy -q -O $DSF_BINARY
        chmod +x $DSF_BINARY
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
    -h)
        echo "./build.sh [setup]"
        ;;
    *)
        build
        ;;
esac
