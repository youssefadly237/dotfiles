# Text to Speech converter using Coqui TTS XTTS-v2
unalias tts_convert 2>/dev/null

tts_convert() {
    local speaker="Chandra MacFarland"
    local input_file=""
    local output_file=""

    # Parse options
    local OPTIND opt
    while getopts "s:" opt; do
        case $opt in
        s)
            speaker="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    if [ $# -lt 1 ]; then
        echo "Usage: tts_convert [-s speaker] input.txt [output.wav]"
        echo "Default speaker: Chandra MacFarland"
        return 1
    fi

    input_file="$1"
    output_file="${2:-${input_file:r}.wav}"

    if [ ! -f "$input_file" ]; then
        echo "Error: Input file not found"
        return 1
    fi

    /home/youssef-adly/Apps/Audify/.venv/bin/tts \
        --model_name "tts_models/multilingual/multi-dataset/xtts_v2" \
        --speaker_idx "$speaker" \
        --language_idx en \
        --use_cuda \
        --text "$(cat "$input_file")" \
        --out_path "$output_file"
}
