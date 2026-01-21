#!/usr/bin/env bash
export PATH="$HOME/.cargo/bin:$PATH"

cmd="$1"

if [[ -n "$cmd" ]]; then
    case "$cmd" in
    working)
        taskbeep working
        exit 0
        ;;
    toggle)
        taskbeep toggle
        exit 0
        ;;
    wasting)
        taskbeep wasting
        exit 0
        ;;
    *)
        echo "Unknown command"
        exit 1
        ;;
    esac
fi

raw=$(taskbeep status --format plain 2>/dev/null)

if [[ $? -ne 0 ]] || [[ -z "$raw" ]]; then
    echo '{"text":"Idle", "class":"idle"}'
    exit 0
fi

status=""
remaining_seconds=0

while IFS='=' read -r key value; do
    case "$key" in
    status)
        status="$value"
        ;;
    remaining_seconds)
        remaining_seconds="$value"
        ;;
    esac
done <<<"$raw"

case "$status" in
running)
    minutes=$((remaining_seconds / 60))
    seconds=$((remaining_seconds % 60))
    text=$(printf "%02d:%02d" "$minutes" "$seconds")
    class="running"
    ;;
paused)
    text="Paused "
    class="paused"
    ;;
waiting)
    text="Waiting"
    class="waiting"
    ;;
*)
    text="Idle"
    class="idle"
    ;;
esac

echo "{\"text\":\"$text\", \"class\":\"$class\"}"
