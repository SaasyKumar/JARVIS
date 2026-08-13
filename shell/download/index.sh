echo "$STORAGE"
options=("youtube video" "youtube audio" )

choice=$(printf '%s\n' "${!options[@]}" | while read i; do
    echo "$((i+1)). ${options[$i]}"
done | fzf\
        --prompt="DOWNLOAD > " \
        --pointer="➤" \
        --marker="◆" \
        --height=30% \
        --layout=reverse)
index="${choice%%.*}"

case "$index" in
    1)
        source "$SCRIPT_DIR/shell/download/youtube.sh"
        ;;
    2)
        source "$SCRIPT_DIR/shell/download/youtubeaud.sh"
        ;;
    3)
        WITH_AUTH="Y"
        source "$SCRIPT_DIR/shell/download/mp4.sh"
        ;;
    *)
        echo "Invalid choice"
        ;;
esac