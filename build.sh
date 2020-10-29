BUILD_DIR=build
TARGET_NAME=omer-config

cd omer-config/etc/xdg/nvim/bundle/LanguageClient-neovim
./install.sh
cd -

cd omer-config/usr/local/src/fzf
./install --bin
cd -

# Build main deb package
dpkg-deb --build $TARGET_NAME
mkdir -p $BUILD_DIR
mv $TARGET_NAME.deb $BUILD_DIR
