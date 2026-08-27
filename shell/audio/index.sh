options=("Cut audio into audio clips" )

choice=$(printf '%s\n' "${!options[@]}" | while read i; do
    echo "$((i+1)). ${options[$i]}"
done | fzf\
        --prompt="AUDIO > " \
        --pointer="➤" \
        --marker="◆" \
        --height=30% \
        --layout=reverse)
index="${choice%%.*}"

case "$index" in
    1)
        source "$SCRIPT_DIR/shell/audio/cutting.sh"
        ;;
    *)
        echo "Invalid choice"
        ;;
esac