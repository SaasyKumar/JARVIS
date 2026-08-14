#!/bin/bash

# Determine directory regardless of whether script is run directly or sourced
SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
JARVIS_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

printf "Source Directory: %b%s%b\n" "${Yellow}" "$(pwd)" "${Color_Off}"

# Let user pick video file with fzf
INPUT="$(ls -t "$(pwd)"/*.{mp4,mkv,mov,avi,webm,m4v} 2>/dev/null | fzf --prompt='Select Video to Upscale > ' --no-multi)"

if [ -z "$INPUT" ] || [ ! -f "$INPUT" ]; then
    echo "No video file selected."
    return 1 2>/dev/null || exit 1
fi

printf "Selected: %b%s%b\n" "${Green}" "$INPUT" "${Color_Off}"

scale_options=(
    "2x Upscale (Fast / RealESRGAN_x2plus)"
    "4x Upscale (High Quality / RealESRGAN_x4plus)"
    "4x Anime / Illustration (RealESRGAN_x4plus_anime_6B)"
)

scale_choice=$(printf '%s\n' "${!scale_options[@]}" | while read i; do
    echo "$((i+1)). ${scale_options[$i]}"
done | fzf \
    --prompt="Upscale Mode > " \
    --pointer="➤" \
    --marker="◆" \
    --height=30% \
    --layout=reverse)

scale_index="${scale_choice%%.*}"

if [ "$scale_index" = "2" ]; then
    SCALE_FLAGS="-s 4 -m RealESRGAN_x4plus"
elif [ "$scale_index" = "3" ]; then
    SCALE_FLAGS="-s 4 -m RealESRGAN_x4plus_anime_6B"
elif [ "$scale_index" = "1" ]; then
    SCALE_FLAGS="-s 2 -m RealESRGAN_x2plus"
else
    echo "No upscale mode selected."
    return 1 2>/dev/null || exit 1
fi

VENV_PY="$JARVIS_ROOT/.venv/bin/python3"
if [ ! -f "$VENV_PY" ]; then
    VENV_PY="python3"
fi

printf "%bStarting AI Upscaling...%b\n\n" "${Cyan}" "${Color_Off}"
"$VENV_PY" "$JARVIS_ROOT/video-utils/upscale.py" "$INPUT" $SCALE_FLAGS
