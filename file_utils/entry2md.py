from pathlib import Path
import re
import html


# ============================================================
# CLEAN NAME
# ============================================================

def clean_name(value: str) -> str:
    """
    Clean a value for use as:
    - filename
    - data-href

    Keeps only:
    letters, numbers, spaces, _ and -
    """

    value = html.unescape(value)

    # Remove special characters
    value = re.sub(r"[^A-Za-z0-9 _-]", "", value)

    # Collapse multiple spaces
    value = re.sub(r"\s+", " ", value)

    return value.strip()


# ============================================================
# PROCESS ONE MARKDOWN FILE
# ============================================================

def process_file(input_file: Path, output_folder: Path):

    text = input_file.read_text(encoding="utf-8")

    # Original markdown filename without extension
    source_name = input_file.stem

    # --------------------------------------------------------
    # Match:
    #
    # <a href="..." target="_blank">
    #     <img src="..." class="thumb" alt="...">
    # </a>
    #
    # --------------------------------------------------------

    pattern = re.compile(
        r'<a\b(?P<a_attrs>[^>]*)>'
        r'\s*<img\b(?P<img_attrs>[^>]*)>'
        r'\s*</a>',
        re.IGNORECASE | re.DOTALL
    )

    generated_count = 0

    def replace_entry(match):

        nonlocal generated_count

        a_attrs = match.group("a_attrs")
        img_attrs = match.group("img_attrs")

        # ----------------------------------------------------
        # Extract href
        # ----------------------------------------------------

        href_match = re.search(
            r'''href\s*=\s*(['"])(.*?)\1''',
            a_attrs,
            re.IGNORECASE | re.DOTALL
        )

        # ----------------------------------------------------
        # Extract src
        # ----------------------------------------------------

        src_match = re.search(
            r'''src\s*=\s*(['"])(.*?)\1''',
            img_attrs,
            re.IGNORECASE | re.DOTALL
        )

        # ----------------------------------------------------
        # Extract alt
        # ----------------------------------------------------

        alt_match = re.search(
            r'''alt\s*=\s*(['"])(.*?)\1''',
            img_attrs,
            re.IGNORECASE | re.DOTALL
        )

        # If required attributes are missing,
        # leave the original HTML unchanged.
        if not href_match or not src_match or not alt_match:
            return match.group(0)

        href = html.unescape(href_match.group(2))
        src = html.unescape(src_match.group(2))
        alt = html.unescape(alt_match.group(2)).strip()

        # ----------------------------------------------------
        # IGNORE LINKS TO MARKDOWN FILES
        # ----------------------------------------------------
        #
        # Examples ignored:
        #
        # Note.md
        # ./Note.md
        # ../Note.md
        # folder/Note.md
        # Note.MD
        # Note.md#heading
        # Note.md?something
        #
        # ----------------------------------------------------

        href_without_query = href.split("?", 1)[0]
        href_without_fragment = href_without_query.split("#", 1)[0]

        if href_without_fragment.lower().endswith(".md") or not href.lower().startswith("https://"):
            return match.group(0)

        # ----------------------------------------------------
        # IGNORE EMPTY ALT
        # ----------------------------------------------------

        if not alt:
            return match.group(0)

        # ----------------------------------------------------
        # CLEAN ALT
        # ----------------------------------------------------

        clean_alt = clean_name(alt)

        # If nothing remains after cleaning, skip it
        if not clean_alt:
            return match.group(0)

        # ----------------------------------------------------
        # CREATE GENERATED MARKDOWN FILE
        # ----------------------------------------------------

        output_file = output_folder / f"{clean_alt}.md"

        content = (
            f"# {alt}\n"
            f"![[{Path(src).name}|656x369]]\n"
            f"[[{source_name}]]\n\n"
            f"```sh\n"
            f"{href}\n"
            f"```\n"
        )

        output_file.write_text(
            content,
            encoding="utf-8"
        )

        generated_count += 1

        # ----------------------------------------------------
        # ADD / REPLACE data-href
        # ----------------------------------------------------

        if re.search(
            r'\bdata-href\s*=',
            a_attrs,
            re.IGNORECASE
        ):

            # Existing data-href
            new_a_attrs = re.sub(
                r'''data-href\s*=\s*(['"])(.*?)\1''',
                f'data-href="{clean_alt}"',
                a_attrs,
                flags=re.IGNORECASE | re.DOTALL
            )

        else:

            # Add new data-href
            new_a_attrs = (
                f'{a_attrs} data-href="{clean_alt}"'
            )

        # ----------------------------------------------------
        # Return modified HTML
        # ----------------------------------------------------

        return (
            f'<a{new_a_attrs}>'
            f'<img{img_attrs}>'
            f'</a>'
        )

    # --------------------------------------------------------
    # Replace every matching entry
    # --------------------------------------------------------

    new_text = pattern.sub(
        replace_entry,
        text
    )

    # --------------------------------------------------------
    # Save modified original file
    # --------------------------------------------------------

    input_file.write_text(
        new_text,
        encoding="utf-8"
    )

    print(
        f"Processed: {input_file} "
        f"({generated_count} generated)"
    )


# ============================================================
# PROCESS FOLDER RECURSIVELY
# ============================================================

def process_folder(
    input_folder: Path,
    output_folder: Path
):

    output_folder.mkdir(
        parents=True,
        exist_ok=True
    )

    # Recursively find every Markdown file
    md_files = input_folder.rglob("*.md")

    processed_count = 0
    generated_total = 0

    for input_file in md_files:

        # Safety check
        if not input_file.is_file():
            continue

        # Don't process files inside output folder
        try:
            input_file.relative_to(output_folder)
            continue
        except ValueError:
            pass

        before_count = len(
            list(output_folder.glob("*.md"))
        )

        process_file(
            input_file,
            output_folder
        )

        after_count = len(
            list(output_folder.glob("*.md"))
        )

        generated_total += max(
            0,
            after_count - before_count
        )

        processed_count += 1

    print()
    print("=" * 50)
    print("Finished")
    print("=" * 50)
    print(f"Markdown files processed : {processed_count}")
    print(f"Generated files          : {generated_total}")
    print(f"Output folder            : {output_folder}")


# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":

    input_folder = Path(
        input("Input folder: ").strip()
    ).expanduser()

    output_folder = Path(
        input("Output folder: ").strip()
    ).expanduser()

    # --------------------------------------------------------
    # Validate input
    # --------------------------------------------------------

    if not input_folder.exists():
        print(
            f"ERROR: Input folder does not exist:\n"
            f"{input_folder}"
        )
        raise SystemExit(1)

    if not input_folder.is_dir():
        print(
            f"ERROR: Input path is not a directory:\n"
            f"{input_folder}"
        )
        raise SystemExit(1)

    # --------------------------------------------------------
    # Run
    # --------------------------------------------------------

    process_folder(
        input_folder,
        output_folder
    )