#!/usr/bin/env bash

archive_path=$1


FULL_PATH="/dev/disk/by-label/NICENANO"

build_and_flash() {
    local side=$1
    local archive_path=$2
    
    if [ -n "$archive_path" ]; then
        echo "Extracting $side side from $archive_path..."
        mkdir -p build/zephyr
        unzip -p "$archive_path" "corne_$side-nice_nano_v2-zmk.uf2" > "build/zephyr/corne_$side.uf2"
    else
        echo "Building $side side..."
        west build -p -b nice_nano_v2 zmk/app -- -DZEPHYR_BASE=$(pwd)/zephyr -DZEPHYR_SDK_INSTALL_DIR=~/zephyr-sdk-0.16.5 -DSHIELD=corne_$side -DZMK_CONFIG=$(pwd)/config
        mv build/zephyr/zmk.uf2 build/zephyr/corne_$side.uf2
    fi
    
    echo "Plug in the $side side..."
    while [ ! -L "$FULL_PATH" ]; do
        sleep 5
    done
    
    udisksctl mount -b "$FULL_PATH"
    cp "build/zephyr/corne_$side.uf2" "/run/media/valtrois/NICENANO/"
    udisksctl unmount -b "$FULL_PATH"
    # udisksctl power-off -b "$FULL_PATH"
    echo "Done with $side side"
    sleep 5
}

build_and_flash left $archive_path
build_and_flash right $archive_path
