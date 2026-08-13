#!/bin/bash

read -p "Enter URL: " INPUTURL
yt-dlp \
  -f "bestvideo[height<=360]+bestaudio/best[height<=360]" \
  --merge-output-format mp4 \
  -o "temp.%(ext)s" \
  "$INPUTURL"

ffmpeg -i temp.mp4 \
  -vn \
  -c:a libmp3lame \
  -q:a 0 \
  "out.mp3"
rm temp.mp4
echo "$INPUTURL"