#!/bin/bash
set -euo pipefail

CONFIG="$HOME/.config/niri/tablet.kdl"

mapfile -t OUTPUTS < <(niri msg outputs | awk '/^Output/ {print $NF}' | tr -d '()')

[[ ${#OUTPUTS[@]} -eq 0 ]] && exit 1

CURRENT=$(awk '/map-to-output/ {print $2}' "$CONFIG" | tr -d '"')

NEXT="${OUTPUTS[0]}"
for i in "${!OUTPUTS[@]}"; do
    [[ "${OUTPUTS[$i]}" == "$CURRENT" ]] && NEXT="${OUTPUTS[$(((i + 1) % ${#OUTPUTS[@]}))]}" && break
done

sed -i "s/map-to-output \"[^\"]*\"/map-to-output \"$NEXT\"/" "$CONFIG"

niri msg action load-config-file
echo "Tablet: $CURRENT → $NEXT"
