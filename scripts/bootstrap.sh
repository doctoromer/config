#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
RELEASE_URL=https://github.com/doctoromer/config/releases/latest/download
ASSET=cool-linux-x86_64
OUTPUT="$ROOT_DIR/binaries/usr/bin/cool"

if [ "$(uname -s)" != Linux ] || [ "$(uname -m)" != x86_64 ]; then
    echo "Only x86-64 Linux is supported" >&2
    exit 1
fi

fetch()
{
    url=$1
    output=$2
    if command -v curl >/dev/null 2>&1; then
        curl --fail --location --retry 3 --output "$output" "$url"
    elif command -v wget >/dev/null 2>&1; then
        wget --output-document="$output" "$url"
    else
        echo "curl or wget is required" >&2
        exit 1
    fi
}

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT INT TERM
fetch "$RELEASE_URL/$ASSET" "$tmp_dir/$ASSET"
fetch "$RELEASE_URL/$ASSET.sha256" "$tmp_dir/$ASSET.sha256"

expected=$(awk -v asset="$ASSET" '$2 == asset { print $1 }' "$tmp_dir/$ASSET.sha256")
actual=$(sha256sum "$tmp_dir/$ASSET" | awk '{ print $1 }')
if [ -z "$expected" ] || [ "$actual" != "$expected" ]; then
    echo "Checksum verification failed" >&2
    exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"
install -m 0755 "$tmp_dir/$ASSET" "$OUTPUT"
echo "Installed cool to $OUTPUT"
