#!/bin/bash
# Quotes credits -> github.com/quotable-io/data
# quotes file -> https://raw.githubusercontent.com/quotable-io/data/refs/heads/master/data/quotes.json
# commit -> 20037e8161167d25e971d2dcfe1ee0398eb8eb89

set -euo pipefail

# Config
readonly QUOTES_FILE="$HOME/.config/taskbeep/quotes.json"
readonly CACHE_FILE="$HOME/.config/taskbeep/motivational_quotes.txt"
readonly MOTIVATIONAL_TAGS=(
    "Success" "Motivational" "Self Help" "Courage" "Character"
    "Change" "Opportunity" "Work" "Failure" "Wisdom" "Knowledge"
)

mkdir -p "$(dirname "$QUOTES_FILE")"

download_quotes() {
    local url="https://raw.githubusercontent.com/quotable-io/data/master/data/quotes.json"
    if ! curl -sL "$url" -o "$QUOTES_FILE"; then
        echo "Failed to download quotes" >&2
        return 1
    fi
}

validate_json() {
    [[ -f "$1" ]] && jq empty "$1" >/dev/null 2>&1
}

create_cache() {
    local filter=""

    for tag in "${MOTIVATIONAL_TAGS[@]}"; do
        [[ -n "$filter" ]] && filter+=" or "
        filter+="(.tags[] == \"$tag\")"
    done

    if validate_json "$QUOTES_FILE"; then
        jq -r ".[] | select($filter) | \"\(.content) — \(.author)\"" "$QUOTES_FILE" |
            sort -u >"$CACHE_FILE"
    fi
}

get_motivational_quote() {
    if [[ -s "$CACHE_FILE" ]]; then
        shuf -n 1 "$CACHE_FILE"
        return 0
    fi

    if ! [[ -f "$QUOTES_FILE" ]] || ! validate_json "$QUOTES_FILE"; then
        download_quotes || return 1
    fi

    create_cache

    if [[ -s "$CACHE_FILE" ]]; then
        shuf -n 1 "$CACHE_FILE"
    else
        echo "Keep going! You're doing great!"
    fi
}

# Main
main() {
    local quote response

    quote=$(get_motivational_quote)

    notify-send "TaskBeep" \
        "Task: $TASKBEEP_TOPIC
Duration: ${TASKBEEP_DURATION}s
Session: #$TASKBEEP_SESSION_COUNT" \
        --urgency=critical -t 10000

    notify-send "Motivation" "$quote" --urgency=critical -t 10000

    response=$(echo -e "working\nwasting\nstop (working)\nstop (wasting)" |
        fuzzel --dmenu --prompt="Was the time productive? ")

    case "$response" in
    "working") taskbeep working ;;
    "wasting") taskbeep wasting ;;
    "stop (working)") taskbeep stop --working ;;
    "stop (wasting)") taskbeep stop --wasting ;;
    *) exit 0 ;;
    esac
}

main "$@"
