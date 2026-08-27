options=("offline video" "online mp4" "online with auth param" "from images")
echo "$SCRIPT_DIR"
WITH_AUTH="N"
choice=$(printf '%s\n' "${!options[@]}" | while read i; do
    echo "$((i+1)). ${options[$i]}"
done | fzf\
        --prompt="GIF > " \
        --pointer="➤" \
        --marker="◆" \
        --height=30% \
        --layout=reverse)
index="${choice%%.*}"

case "$index" in
    1)
        source "$SCRIPT_DIR/shell/gif/offline.sh"
        ;;
    2)
        source "$SCRIPT_DIR/shell/gif/mp4.sh"
        ;;
    3)
        WITH_AUTH="Y"
        source "$SCRIPT_DIR/shell/gif/mp4.sh"
        ;;
    4)
        source "$SCRIPT_DIR/shell/gif/image.sh"
        ;;
    *)
        echo "Invalid choice"
        ;;
esac