echo "$STORAGE"
options=("Cut movie into clips" "AI Upscale video")

choice=$(printf '%s\n' "${!options[@]}" | while read i; do
    echo "$((i+1)). ${options[$i]}"
done | fzf\
        --prompt="VIDEO > " \
        --pointer="➤" \
        --marker="◆" \
        --height=30% \
        --layout=reverse)
index="${choice%%.*}"

case "$index" in
    1)
        source "$SCRIPT_DIR/shell/video/cutting.sh"
        ;;
    2)
        source "$SCRIPT_DIR/shell/video/upscaling.sh"
        ;;
    *)
        echo "Invalid choice"
        ;;
esac