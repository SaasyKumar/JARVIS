#!/bin/bash

# Usage:
# ./makegif.sh "https://example.com/video.mp4"
echo "VPN: $VPN_STATUS"

INPUTURL="${1%%\?*}"
DEST="${GIF_DESTINATION:-.}"
mkdir -p "$DEST"
OUTPUT="$DEST/${GIF_OUTNAME:-out}.gif"
OUTPUT_MP3="$DEST/${MP3_OUTNAME:-out}.mp3"

if [ -z "$INPUTURL" ]; then
    read -p "Enter URL: " INPUTURL
fi
if [ "$WITH_AUTH" = "Y" ]; then
    read -p "Enter Auth param: " PARAM
    INPUTURL="$INPUTURL?$PARAM"
fi
read -p "Enter timestamps (e.g. 5 1:20-4 a-10:12-12): " -a SEGMENTS

TMPDIR=$(mktemp -d)
GIF_LIST="$TMPDIR/gif_list.txt"
AUDIO_LIST="$TMPDIR/audio_list.txt"

GIF_COUNT=0
AUDIO_COUNT=0

for ARG in "${SEGMENTS[@]}"
do
    IS_AUDIO=false
    if [[ "$ARG" == a-* ]]; then
        IS_AUDIO=true
        ARG="${ARG#a-}"
    fi

    if [[ "$ARG" == *"-"* ]]; then
        START="${ARG%-*}"
        DURATION="${ARG##*-}"
    else
        START="$ARG"
        DURATION=2
    fi

    if [ "$IS_AUDIO" = true ]; then
        AUDIO_CLIP="$TMPDIR/audio_$AUDIO_COUNT.mp3"

        ffmpeg -y \
            -ss "$START" \
            -t "$DURATION" \
            -i "$INPUTURL" \
            -vn \
            -c:a libmp3lame \
            -q:a 2 \
            "$AUDIO_CLIP"

        echo "file '$AUDIO_CLIP'" >> "$AUDIO_LIST"

        AUDIO_COUNT=$((AUDIO_COUNT + 1))
    else
        CLIP="$TMPDIR/clip_$GIF_COUNT.mp4"

        ffmpeg -y \
            -ss "$START" \
            -t "$DURATION" \
            -i "$INPUTURL" \
            -c:v libx264 \
            -preset ultrafast \
            -an \
            "$CLIP"

        echo "file '$CLIP'" >> "$GIF_LIST"

        GIF_COUNT=$((GIF_COUNT + 1))
    fi
done

if [ "$GIF_COUNT" -gt 0 ]; then
    MERGED="$TMPDIR/merged.mp4"

    ffmpeg -y \
        -f concat \
        -safe 0 \
        -i "$GIF_LIST" \
        -c copy \
        "$MERGED"

    ffmpeg -y \
        -i "$MERGED" \
        -vf "fps=12,scale=480:-1:flags=lanczos" \
        "$OUTPUT"

    echo "GIF created: $OUTPUT"
fi

if [ "$AUDIO_COUNT" -gt 0 ]; then
    ffmpeg -y \
        -f concat \
        -safe 0 \
        -i "$AUDIO_LIST" \
        -c copy \
        "$OUTPUT_MP3"

    echo "MP3 created: $OUTPUT_MP3"
fi

if [ "$COPY_TO_CLIPBOARD" = "Y" ]; then
    if [ "$GIF_COUNT" -gt 0 ] && [ -f "$OUTPUT" ]; then
        RESOLVED_OUTPUT="$(cd "$(dirname "$OUTPUT")" && pwd)/$(basename "$OUTPUT")"
        osascript -e 'set the clipboard to (POSIX file "'"$RESOLVED_OUTPUT"'")'
        echo "GIF copied to clipboard."
    elif [ "$AUDIO_COUNT" -gt 0 ] && [ -f "$OUTPUT_MP3" ]; then
        RESOLVED_OUTPUT_MP3="$(cd "$(dirname "$OUTPUT_MP3")" && pwd)/$(basename "$OUTPUT_MP3")"
        osascript -e 'set the clipboard to (POSIX file "'"$RESOLVED_OUTPUT_MP3"'")'
        echo "MP3 copied to clipboard."
    fi
fi

rm -rf "$TMPDIR"

echo "$INPUTURL"
echo "created from: "
echo "${SEGMENTS[@]}"