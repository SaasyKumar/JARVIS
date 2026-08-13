options=("merge last downloaded" "merge pdf" )
echo "$SCRIPT_DIR"
choice=$(printf '%s\n' "${!options[@]}" | while read i; do
    echo "$((i+1)). ${options[$i]}"
done | fzf)
index="${choice%%.*}"

case "$index" in
    1)
        source "$SCRIPT_DIR/shell/pdf/mergeltdown.sh"
        ;;
    2)
        source "$SCRIPT_DIR/shell/pdf/mergepdf.sh"
        ;;
    *)
        echo "Invalid choice"
        ;;
esac