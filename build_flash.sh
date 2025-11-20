#!/bin/bash

left=${1:-left}
right=${2:-right}

FULL_PATH="/dev/disk/by-label/NICENANO"

build_and_flash() {
    local side=$1
    echo "Building $side side..."
    
    west build -p -b nice_nano_v2 zmk/app -- -DZEPHYR_BASE=$(pwd)/zephyr -DZEPHYR_SDK_INSTALL_DIR=~/zephyr-sdk-0.16.5 -DSHIELD=corne_$side -DZMK_CONFIG=$(pwd)/config
    mv build/zephyr/zmk.uf2 build/zephyr/corne_$side.uf2
    
    echo "Plug in the $side side..."
    while [ ! -L "$FULL_PATH" ]; do
        sleep 5
    done
    
    udisksctl mount -b "$FULL_PATH"
    cp build/zephyr/corne_$side.uf2 /run/media/valtrois/NICENANO/
    echo "Done with $side side"
}

build_and_flash $left
build_and_flash $right
