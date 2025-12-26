#!/usr/bin/env bash

archive_path=$1
reset=$2


FULL_PATH="/dev/disk/by-label/NICENANO"

build_and_flash() {
    local side=$1
    local archive_path=$2
    local rese=$3
    local file_name="corne_$side-nice_nano_v2-zmk.uf2"
    local action_name=$side
    
    if [ -n "$archive_path" ]; then
        mkdir -p build/zephyr
        if [ "$rese" = "reset" ]; then
            action_name="reset"
            file_name="settings_reset-nice_nano_v2-zmk.uf2"
        fi
        echo "Extracting $action_name file from $archive_path"
        unzip -p "$archive_path" "$file_name" > "build/zephyr/$file_name"
    else
        echo "Building $side side"
        west build -p -b nice_nano_v2 zmk/app -- -DZEPHYR_BASE=$(pwd)/zephyr -DZEPHYR_SDK_INSTALL_DIR=~/zephyr-sdk-0.16.5 -DSHIELD=corne_$side -DZMK_CONFIG=$(pwd)/config
        mv build/zephyr/zmk.uf2 build/zephyr/$file_name
    fi
    
    echo "Plug in the $side side..."
    while [ ! -L "$FULL_PATH" ]; do
        sleep 0.5
    done
    udisksctl mount -b "$FULL_PATH"
    cp "build/zephyr/$file_name" "/run/media/valtrois/NICENANO/"

    echo "Waiting for unmount"
    while [ -L "$FULL_PATH" ]; do
        sleep 0.5
    done

    echo "Done with $side side"
}
if [ "$reset" = "reset" ]; then
    build_and_flash left "$archive_path" reset
    build_and_flash right "$archive_path" reset
fi
build_and_flash left "$archive_path"
build_and_flash right "$archive_path"
