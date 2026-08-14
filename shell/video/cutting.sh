#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/imports.sh"

printf "Source: %b%s%b\n" "${Yellow}" "$(pwd)" "${Color_Off}"

# Let user pick one video file with fzf
INPUT="$(ls -t "$(pwd)"/*.{mp4,mkv,mov,avi,webm,m4v} 2>/dev/null | fzf --prompt='Select Video file: ' --no-multi)"

if [ -z "$INPUT" ] || [ ! -f "$INPUT" ]; then
    echo "No Video file selected."
    return 1 2>/dev/null || exit 1
fi

# Let user choose timestamp input method
ts_options=("Select timestamp file (.txt / .md)" "Enter timestamps manually (space-separated)")
ts_choice=$(printf '%s\n' "${!ts_options[@]}" | while read i; do
    echo "$((i+1)). ${ts_options[$i]}"
done | fzf \
    --prompt="Timestamp Source > " \
    --pointer="➤" \
    --marker="◆" \
    --height=30% \
    --layout=reverse)

ts_index="${ts_choice%%.*}"

TIMESTAMP_FILE=""
if [ "$ts_index" = "1" ]; then
    TIMESTAMP_FILE="$(ls -t "$(pwd)"/*.{txt,md} 2>/dev/null | fzf --prompt='Select Timestamp file: ' --no-multi)"
    if [ -z "$TIMESTAMP_FILE" ] || [ ! -f "$TIMESTAMP_FILE" ]; then
        echo "No Timestamp file selected."
        return 1 2>/dev/null || exit 1
    fi
elif [ "$ts_index" = "2" ]; then
    TIMESTAMP_FILE=""
else
    echo "No timestamp option selected."
    return 1 2>/dev/null || exit 1
fi


to_seconds() {
    local t="$1"

    IFS=: read -ra parts <<< "$t"

    if [ ${#parts[@]} -eq 3 ]; then
        echo $((10#${parts[0]} * 3600 + 10#${parts[1]} * 60 + 10#${parts[2]}))
    elif [ ${#parts[@]} -eq 2 ]; then
        echo $((10#${parts[0]} * 60 + 10#${parts[1]}))
    else
        echo "${parts[0]}"
    fi
}

to_hms() {
    local total="$1"

    printf "%02d:%02d:%02d" \
        $((total / 3600)) \
        $(((total % 3600) / 60)) \
        $((total % 60))
}

BASENAME=$(basename "$INPUT")
VIDNAME="${BASENAME%.*}"

OUTDIR="$VIDNAME"
mkdir -p "$OUTDIR"

SEGMENTS=()

if [ -n "$TIMESTAMP_FILE" ] && [ -f "$TIMESTAMP_FILE" ]; then
    echo "Loading timestamps from: $TIMESTAMP_FILE"

    while IFS= read -r line || [ -n "$line" ]
    do
        # Remove Windows CR
        line="${line%$'\r'}"

        # Remove comments
        line="${line%%#*}"

        # Trim spaces
        line="$(echo "$line" | xargs)"

        [ -z "$line" ] && continue

        for token in $line; do
            SEGMENTS+=("$token")
        done
    done < "$TIMESTAMP_FILE"
else
    echo "Enter timestamps (space-separated):"
    echo "Examples:"
    echo "  d-10 5 1:20 1:20-4 1:01:20-115"
    echo "  (Use d<offset> e.g. d-10 or d5 to shift all timestamps)"
    read -r -p "Timestamps: " user_input
    read -ra SEGMENTS <<< "$user_input"
fi

# Extract delay (e.g. d-10, d5, d+5) from segments
DELAY=0
FILTERED_SEGMENTS=()
for item in "${SEGMENTS[@]}"; do
    if [[ "$item" =~ ^d([+-]?[0-9]+)$ ]]; then
        DELAY="${BASH_REMATCH[1]}"
    else
        FILTERED_SEGMENTS+=("$item")
    fi
done
SEGMENTS=("${FILTERED_SEGMENTS[@]}")

echo
if [ "$DELAY" -ne 0 ]; then
    echo "Delay offset: ${DELAY}s"
fi
echo "Loaded ${#SEGMENTS[@]} timestamps:"
printf '  %s\n' "${SEGMENTS[@]}"
echo

if [ ${#SEGMENTS[@]} -eq 0 ]; then
    echo "No timestamps loaded."
    exit 1
fi

{
    if [ "$DELAY" -ne 0 ]; then
        echo "d${DELAY}"
    fi
    printf "%s\n" "${SEGMENTS[@]}"
} > "$OUTDIR/timestamps.txt"

COUNT=1

for ARG in "${SEGMENTS[@]}"
do
    if [[ "$ARG" == *"-"* ]]; then
        START="${ARG%-*}"
        DURATION="${ARG##*-}"
    else
        START="$ARG"
        DURATION=2
    fi

    START_SEC=$(to_seconds "$START")
    START_SEC=$((START_SEC + DELAY))

    if [ "$START_SEC" -lt 0 ]; then
        START_SEC=0
    fi

    OUTPUT_FILE="$OUTDIR/clip_${COUNT}.mp4"

    echo "[$COUNT] Cutting $ARG"

    ffmpeg -y \
        -ss "$(to_hms "$START_SEC")" \
        -i "$INPUT" \
        -t "$DURATION" \
        -c copy \
        "$OUTPUT_FILE"

    if [ $? -ne 0 ]; then
        echo "ffmpeg failed on: $ARG"
    fi

    COUNT=$((COUNT + 1))
done

echo
echo "Done."
echo "Output folder: $OUTDIR"
echo "Timestamp file: $OUTDIR/timestamps.txt"