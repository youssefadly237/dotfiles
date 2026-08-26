#!/usr/bin/env bash

CONFIG="$HOME/.config/niri/tablet.kdl"
TMP="$CONFIG.tmp"

awk -f "$HOME/.scripts/niri-tablet.awk" "$CONFIG" >"$TMP" &&
    mv "$TMP" "$CONFIG"

niri msg action load-config-file
