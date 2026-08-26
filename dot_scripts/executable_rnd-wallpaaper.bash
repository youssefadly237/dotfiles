#!/usr/bin/env bash

case "$1" in
daemon)
    exec "$HOME/.cargo/bin/awww-daemon"
    ;;
esac

wallpaper=$(printf '%s\n' "$HOME"/Pictures/wallpapers/gowall/* | shuf -n 1)

[ -f "$wallpaper" ] || exit 1

"$HOME/.cargo/bin/awww" img \
    --transition-type fade \
    --transition-duration 2 \
    "$wallpaper"
