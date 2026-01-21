#!/usr/bin/env sh

tolower() {
    tr '[:upper:]' '[:lower:]'
}

delete() {
    cliphist delete
}

copy() {
    cliphist decode | wl-copy
}

history() {
    while true; do
        item=$(cliphist list | fuzzel -d --prompt='History > ')
        [ -z "${item}" ] && return 130

        choice=$(printf 'Copy\nDelete' | fuzzel -d --prompt='History > ' | tolower)
        [ -z "${choice}" ] && return 130

        printf '%b' "$item" | "${choice}"

        if [ "${choice}" = 'copy' ]; then
            return 0
        fi
    done
}

wipe() {
    choice=$(printf 'Yes\nNo' | fuzzel -d --prompt='Wipe clipboard? ' | tolower)
    [ -z "${choice}" ] || [ "${choice}" = 'no' ] && return 130

    cliphist wipe

    exit 0
}

while true; do
    hist_count=$(cliphist list | wc -l)

    if [ "${hist_count}" -eq 0 ]; then
        choice=$(printf 'Exit' | fuzzel -d --prompt='Nothing in clipboard history, exit > ' | tolower)
    else
        choice=$(printf 'History\nWipe\nExit' | fuzzel -d --prompt='Clip Manager > ' | tolower)
    fi
    [ -z "${choice}" ] && exit 130
    [ "${choice}" = 'exit' ] && exit 0

    if "${choice}"; then
        exit 0
    fi
done
