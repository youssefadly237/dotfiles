#!/bin/bash
# System monitor for Waybar
# Usage: sysmon.sh cpu|ram|gpu

# gen ASCII bar (centered with padding)
generate_bar() {
    local usage=$1
    local total=25
    local bars=$((usage * total / 100))
    local empty=$((total - bars))
    printf '█%.0s' $(seq 1 $bars)
    printf '░%.0s' $(seq 1 $empty)
}

# Get CPU usage
get_cpu_usage() {
    top -bn1 | grep 'Cpu(s)' | awk '{print int($2 + $4)}'
}

# Get CPU temp
get_cpu_temp() {
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        awk '{printf "%.0f", $1/1000}' /sys/class/thermal/thermal_zone0/temp
    elif command -v sensors &>/dev/null; then
        sensors | grep -i 'package id 0' | awk '{print int($4)}' | tr -d '+'
    else
        echo "N/A"
    fi
}

# Get RAM usage
get_ram_usage() {
    free | awk 'NR==2{printf "%d", $3/$2*100}'
}

# Get GPU usage
get_gpu_usage() {
    nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null || echo "0"
}

# Get top CPU processes
get_top_cpu() {
    local num_cores=$(nproc)
    ps aux --sort=-%cpu | awk -v cores="$num_cores" 'NR>1 && NR<=11 && $11 !~ /^(ps|awk|top|grep)$/ {
        cpu_total = $3 / cores
        if (cpu_total > 0.1) {
            printf "%-20s %5.1f%%\n", substr($11,1,20), cpu_total
            count++
        }
        if (count >= 5) exit
    }'
}

# Get top RAM processes
get_top_ram() {
    ps aux --sort=-%mem | awk 'NR>1 && NR<=6 {printf "%-20s %5s%%\n", substr($11,1,20), $4}'
}

# Get top GPU processes
get_top_gpu() {
    if command -v nvidia-smi &>/dev/null; then
        local output=$(nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv,noheader 2>/dev/null)
        if [ -z "$output" ]; then
            echo "No active GPU compute processes"
        else
            echo "$output" | head -5 | awk -F', ' '
            {
                gsub(/^[ \t]+|[ \t]+$/, "", $2)
                cmd = $2
                sub(".*/", "", cmd)
                printf "%-20s %s\n", substr(cmd, 1, 20), $3
            }'
        fi
    else
        echo "nvidia-smi not found"
    fi
}

# Output JSON for Waybar
output_json() {
    local text=$1
    local tooltip=$2

    tooltip=$(echo "$tooltip" | sed 's/\\/\\\\/g; s/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')

    echo "{\"text\":\"$text\",\"tooltip\":\"$tooltip\"}"
}

# main
case "$1" in
cpu)
    USAGE=$(get_cpu_usage)
    TEMP=$(get_cpu_temp)
    BAR=$(generate_bar "$USAGE")
    TOP=$(get_top_cpu)

    TOOLTIP=$(printf 'CPU Usage: %s%% | Temp: %s°C\n\n%s\n\n%s' \
        "$USAGE" "$TEMP" "$BAR" "$TOP")

    output_json "${USAGE}" "$TOOLTIP"
    ;;
ram)
    USAGE=$(get_ram_usage)
    USED=$(free -h | awk 'NR==2{print $3}')
    TOTAL=$(free -h | awk 'NR==2{print $2}')
    BAR=$(generate_bar "$USAGE")
    TOP=$(get_top_ram)

    TOOLTIP=$(printf 'RAM Usage: %s%% (%s / %s)\n\n%s\n\n%s' \
        "$USAGE" "$USED" "$TOTAL" "$BAR" "$TOP")

    output_json "${USAGE}" "$TOOLTIP"
    ;;
gpu)
    USAGE=$(get_gpu_usage)
    TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo "N/A")
    MEM_USED=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>/dev/null || echo "N/A")
    MEM_TOTAL=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null || echo "N/A")
    BAR=$(generate_bar "$USAGE")
    TOP=$(get_top_gpu)

    TOOLTIP=$(printf 'GPU Usage: %s%% | Temp: %s°C\nVRAM: %s MiB / %s MiB\n\n%s\n\n%s' \
        "$USAGE" "$TEMP" "$MEM_USED" "$MEM_TOTAL" "$BAR" "$TOP")

    output_json "${USAGE}" "$TOOLTIP"
    ;;
*)
    output_json "Error" "Usage: $0 {cpu|ram|gpu}"
    exit 1
    ;;
esac
