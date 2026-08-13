#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "$DEFAULT_LAST_PDF_SRC"
source "$SCRIPT_DIR/imports.sh"

read -p "How many recent PDFs to merge? " N
read -p "Output filename (without .pdf): " NAME

FILES=()
printf "Destination: %b%s%b\n" "${Yellow}" "$DEFAULT_LAST_PDF_SRC" "${Color_Off}"

while IFS= read -r file; do
    [[ -n "$file" ]] && FILES+=("$file")
done <<< "$(ls -t "$DEFAULT_LAST_PDF_SRC"/*.pdf 2>/dev/null | head -n "$N" | sort)"

if [ ${#FILES[@]} -eq 0 ]; then
    echo "No PDFs found."
    return 1 2>/dev/null || exit 1
fi

printf "Merging:%b\n" "${Yellow}"
printf '%s\n' "${FILES[@]}"

pdfunite "${FILES[@]}" "$DEFAULT_DEST/$NAME.pdf"

echo
printf "%b Saved to:\n" "${BIGreen}"
echo "$DEFAULT_DEST/$NAME.pdf"
