#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FPS=2
if [ -f "$SCRIPT_DIR/imports.sh" ]; then
    source "$SCRIPT_DIR/imports.sh"
fi

SRC="${DEFAULT_LAST_IMAGE_SRC:-$HOME/Desktop}"
DEST="${GIF_DESTINATION:-$HOME/Documents/Personal/.tuko/temp}"
mkdir -p "$DEST"
OUTPUT="$DEST/${GIF_OUTNAME:-out}.gif"

printf "Source: %b%s%b\n" "${Yellow}" "$SRC" "${Color_Off}"
printf "Destination: %b%s%b\n" "${Yellow}" "$DEST" "${Color_Off}"

read -p "How many recent images to convert? " N

if [ -z "$N" ] || ! [[ "$N" =~ ^[0-9]+$ ]] || [ "$N" -le 0 ]; then
    echo "Invalid number of images."
    return 1 2>/dev/null || exit 1
fi

FILES=()

while IFS= read -r file; do
    [[ -n "$file" ]] && FILES+=("$file")
done <<< "$(ls -t "$SRC"/*.png 2>/dev/null | head -n "$N" | sort)"

if [ ${#FILES[@]} -eq 0 ]; then
    echo "No PNGs found in $SRC."
    return 1 2>/dev/null || exit 1
fi

printf "\nConverting %d image(s) at 1 fps:\n" "${#FILES[@]}"
printf '  %s\n' "${FILES[@]}"

TMPDIR=$(mktemp -d)

MAX_W=0
MAX_H=0

for file in "${FILES[@]}"; do
    DIM=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$file" 2>/dev/null)
    W="${DIM%x*}"
    H="${DIM#*x}"
    if [[ "$W" =~ ^[0-9]+$ ]] && [ "$W" -gt "$MAX_W" ]; then
        MAX_W="$W"
    fi
    if [[ "$H" =~ ^[0-9]+$ ]] && [ "$H" -gt "$MAX_H" ]; then
        MAX_H="$H"
    fi
done

if [ "$MAX_W" -le 0 ] || [ "$MAX_H" -le 0 ]; then
    MAX_W=1920
    MAX_H=1080
fi

COUNT=0
for file in "${FILES[@]}"; do
    TARGET_IMG="$TMPDIR/img_$(printf "%04d" "$COUNT").png"
    ffmpeg -y -i "$file" \
        -vf "scale=${MAX_W}:${MAX_H}:force_original_aspect_ratio=decrease,pad=${MAX_W}:${MAX_H}:(ow-iw)/2:(oh-ih)/2:color=0x00000000" \
        "$TARGET_IMG" >/dev/null 2>&1
    COUNT=$((COUNT + 1))
done

ffmpeg -y \
    -framerate $FPS \
    -i "$TMPDIR/img_%04d.png" \
    -vf "split[s0][s1];[s0]palettegen=reserve_transparent=on[p];[s1][p]paletteuse" \
    "$OUTPUT"

rm -rf "$TMPDIR"

if [ -f "$OUTPUT" ]; then
    rm -f "${FILES[@]}"
fi

if [ "$COPY_TO_CLIPBOARD" = "Y" ] && [ -f "$OUTPUT" ]; then
    RESOLVED_OUTPUT="$(cd "$(dirname "$OUTPUT")" && pwd)/$(basename "$OUTPUT")"
    osascript -e 'set the clipboard to (POSIX file "'"$RESOLVED_OUTPUT"'")'
    echo "GIF copied to clipboard."
fi

echo
printf "%bSaved to:%b\n" "${BIGreen}" "${Color_Off}"
echo "$OUTPUT"