#!/usr/bin/env bash

archive_path=$1


FULL_PATH="/dev/disk/by-label/NICENANO"

build_and_flash() {
    local side=$1
    local archive_path=$2
    
    echo "Extracting reset from $archive_path..."
    mkdir -p build/zephyr
    unzip -p "$archive_path" settings_reset-nice_nano_v2-zmk.uf2 > build/zephyr/settings_reset.uf2
    
    echo "Plug in the $side side..."
    while [ ! -L "$FULL_PATH" ]; do
        sleep 5
    done
    
    udisksctl mount -b "$FULL_PATH"
    cp build/zephyr/settings_reset.uf2 /run/media/valtrois/NICENANO/
    udisksctl unmount -b "$FULL_PATH"
    udisksctl power-off -b "$FULL_PATH"
    echo "Done with $side side"
}

build_and_flash left $archive_path
build_and_flash right $archive_path
