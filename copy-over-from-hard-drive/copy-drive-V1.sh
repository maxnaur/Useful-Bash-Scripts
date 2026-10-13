#!/usr/bin/env bash

SOURCE_DIR="${1:-}"
DEST_DIR="${2:-}"

if [[ -z "$SOURCE_DIR" || -z "$DEST_DIR" ]]; then
    echo "Usage: $0 <source_directory> <destination_directory>" >&2
    exit 1
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Error: source directory does not exist: $SOURCE_DIR" >&2
    exit 1
fi

SOURCE_DIR="$(realpath -- "$SOURCE_DIR")"
DEST_DIR="$(realpath -m -- "$DEST_DIR")"

if [[ "$SOURCE_DIR" == "$DEST_DIR" ]]; then
    echo "Source and destination are the same directory; nothing to copy."
    exit 0
fi

case "$DEST_DIR/" in
    "$SOURCE_DIR/"*)
        echo "Error: destination is inside the source directory; refusing to copy recursively." >&2
        exit 1
        ;;
esac

mkdir -p -- "$DEST_DIR" || exit 1

# Create corresponding directories, including empty ones.
find "$SOURCE_DIR" -mindepth 1 -type d -print0 |
while IFS= read -r -d '' src_dir; do
    relative_path="${src_dir#"$SOURCE_DIR"/}"
    mkdir -p -- "$DEST_DIR/$relative_path"
done

# Copy regular files only when missing or their content differs.
find "$SOURCE_DIR" -type f -print0 |
while IFS= read -r -d '' src_file; do
    relative_path="${src_file#"$SOURCE_DIR"/}"
    dest_file="$DEST_DIR/$relative_path"

    mkdir -p -- "$(dirname -- "$dest_file")"

    if [[ -f "$dest_file" ]] &&
       [[ "$(sha256sum -- "$src_file" | cut -d ' ' -f 1)" == \
          "$(sha256sum -- "$dest_file" | cut -d ' ' -f 1)" ]]; then
        #echo "Skipping unchanged: $relative_path"
        continue
    fi

    cp -p -- "$src_file" "$dest_file"
    echo "Copied: $relative_path"
done

