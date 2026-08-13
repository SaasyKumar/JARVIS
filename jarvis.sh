SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/imports.sh"


options=("PDF" "Download" "video" "audio" "gif" "git" )

choice=$(printf '%s\n' "${!options[@]}" | while read i; do
    echo "$((i+1)). ${options[$i]}"
done | fzf)
index="${choice%%.*}"

case "$index" in
    1)
        source "$SCRIPT_DIR/shell/pdf/index.sh"
        ;;
    2)
        source "$SCRIPT_DIR/shell/download/index.sh"
        ;;
    3)
        source "$SCRIPT_DIR/shell/video/index.sh"
        ;;
    4)
        source "$SCRIPT_DIR/shell/audio/index.sh"
        ;;
    *)
        echo "Invalid choice"
        ;;
esac

echo "$choice"