#!/bin/bash
# Spotify controller for Waybar
# Usage: spotify.sh metadata|play|pause|play-pause|next|prev|vol-up|vol-down

PLAYER=$(playerctl --list-all | grep -i spotify)
[ -z "$PLAYER" ] && {
    [ "$1" = "full" ] && echo '{"text":"No music", "class":"idle"}'
    exit 0
}

escape_markup() {
    echo "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'\''/\&apos;/g'
}

get_volume() {
    local VOLUME
    VOLUME=$(playerctl -p spotify volume 2>/dev/null)

    if [ -z "$VOLUME" ]; then
        echo "0"
    else
        awk -v v="$VOLUME" 'BEGIN{printf "%d", (v*100) + 0.5}'
    fi
}

adjust_volume() {
    local STEP VOL_P
    STEP=$1
    VOL_P=$(get_volume)

    if [ $((VOL_P % 5)) -eq 0 ]; then
        VOL_P=$((VOL_P + STEP))
    elif [ "$STEP" -gt 0 ]; then
        VOL_P=$(((VOL_P / 5 + 1) * 5))
    else
        VOL_P=$(((VOL_P / 5) * 5))
    fi

    [ "$VOL_P" -gt 100 ] && VOL_P=100
    [ "$VOL_P" -lt 0 ] && VOL_P=0

    local VOLUME
    VOLUME=$(awk -v vp="$VOL_P" 'BEGIN{print vp/100}')

    playerctl -p spotify volume "$VOLUME" 2>/dev/null || true
    echo "$VOL_P"
}

case "$1" in
full)
    STATUS=$(playerctl -p spotify status 2>/dev/null)

    TITLE=$(playerctl -p spotify metadata title 2>/dev/null)
    TITLE=$(escape_markup "${TITLE:-No music}")

    ARTIST=$(playerctl -p spotify metadata artist 2>/dev/null)
    ARTIST=$(escape_markup "${ARTIST:-Unknown artist}")

    TOOLTIP=" $TITLE\n $ARTIST\n  $(get_volume)%"

    case "$STATUS" in
    Playing)
        CLASS="playing"
        ;;
    Paused)
        CLASS="paused"
        ;;
    *)
        CLASS="idle"
        ;;
    esac

    echo "{\"text\": \"$TITLE\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$CLASS\"}"
    ;;

metadata)
    METADATA=$(playerctl -p spotify metadata --format '{{ title }}' 2>/dev/null)
    escape_markup "${METADATA:-No music}"
    ;;

play | pause | play-pause | next | previous)
    playerctl -p spotify "$1" 2>/dev/null || true
    ;;

vol-up | vol-down)
    if [ "$1" = "vol-up" ]; then
        VOL_P=$(adjust_volume 5)
    else
        VOL_P=$(adjust_volume -5)
    fi

    echo "{\"text\": \"Volume\", \"tooltip\": \" $VOL_P%\"}"
    ;;

seek-backward | seek-forward)
    if [ "$1" = "seek-forward" ]; then
        OFFSET="5+"
    else
        OFFSET="5-"
    fi

    playerctl -p spotify position "$OFFSET" 2>/dev/null || true
    ;;

*)
    echo "Unknown action: $1"
    exit 1
    ;;
esac
