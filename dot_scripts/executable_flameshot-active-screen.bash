#!/usr/bin/env bash
# a promblem with this scritpt, is that it works with the active winodw
# not with where the cursor is, but I think this is good enough, my goal is to
# bypass screen selection

output=$(niri msg -j focused-output) || exit 1
name=$(jq -r '.name' <<<"$output") || exit 1

case "$name" in
eDP-1)
    screen=0
    ;;

HDMI-A-1)
    screen=1
    ;;
*)
    echo "Unknown output: $name" >&2
    exit 1
    ;;
esac

flameshot screen -n "$screen" --edit
