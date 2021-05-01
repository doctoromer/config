#!/bin/sh


get-depends() {
    apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances $* | grep "^\w" | sort -u
}

download-depends() {
    local output_dir=$1
    shift 1
    local dependencies=$(get-depends $*)
    cd $output_dir
    apt-get download $dependencies
    cd -
}

get-deb-depends() {
    dpkg -I $1 | grep Depends | cut -d' ' -f3- | sed 's/, /\n/g'
}

download-deb-depends() {
    local output_dir=$1
    local deb_file=$2
    local dependencies=$(get-deb-depends $deb_file)
    download-depends $output_dir $dependencies
}
