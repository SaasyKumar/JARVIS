#!/bin/bash

read -p "Enter URL: " INPUTURL
options=("4K cap" "1080p cap")
choice=$(printf '%s\n' "${!options[@]}" | while read i; do
    echo "$((i+1)). ${options[$i]}"
done | fzf\
        --prompt="DOWNLOAD > " \
        --pointer="➤" \
        --marker="◆" \
        --height=30% \
        --layout=reverse)
index="${choice%%.*}"
QUALITY="bv*[height<=1080]+ba/b[height<=1080]"
if [ "$index" = "1" ];then
    QUALITY="bv*+ba/b"
fi
yt-dlp \
  -f "$QUALITY" \
  --merge-output-format mp4 \
  -o "%(title)s.%(ext)s" \
  "$INPUTURL"
echo "$INPUTURL"