#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/imports.sh"

printf "Source: %b%s%b\n" "${Yellow}" "$(pwd)" "${Color_Off}"

# Let user pick PDFs with fzf (Tab to select multiple, Enter to confirm)
FILES=()
while IFS= read -r file; do
    [[ -n "$file" ]] && FILES+=("$file")
done <<< "$(ls -t "$(pwd)"/*.pdf 2>/dev/null | fzf --multi --prompt='Select PDFs (Tab to pick, Enter to confirm): ')"

if [ ${#FILES[@]} -eq 0 ]; then
    echo "No PDFs selected."
    return 1 2>/dev/null || exit 1
fi

read -p "Output filename (without .pdf): " NAME

DEST=$(printf "Current - %s\nDefault - %s\n" "$(pwd)" "$DEFAULT_DEST" \
    | fzf --prompt='Save to: ' --height=5)

if [ -z "$DEST" ]; then
    echo "No destination selected."
    return 1 2>/dev/null || exit 1
fi

# Extract the path after " - "
DEST="${DEST#*- }"

printf "\nMerging:%b\n" "${Yellow}"
printf '  %s\n' "${FILES[@]}"
printf "%b\n" "${Color_Off}"

pdfunite "${FILES[@]}" "$DEST$NAME.pdf"

echo
printf "%b Saved to:\n" "${BIGreen}"
echo " $DEST$NAME.pdf"
printf "%b" "${Color_Off}"
