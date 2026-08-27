echo "$STORAGE"
options=("Image AI Upscale")

choice=$(printf '%s\n' "${!options[@]}" | while read i; do
    echo "$((i+1)). ${options[$i]}"
done | fzf\
        --prompt="IMAGE > " \
        --pointer="➤" \
        --marker="◆" \
        --height=30% \
        --layout=reverse)
index="${choice%%.*}"

case "$index" in
    1)
        source "$SCRIPT_DIR/shell/image/upscaling.sh"
        ;;
    *)
        echo "Invalid choice"
        ;;
esac