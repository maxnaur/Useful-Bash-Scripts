#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${1:-}"
DEST_DIR="${2:-}"
THREADS="${3:-4}"

if [[ -z "$SOURCE_DIR" || -z "$DEST_DIR" ]]; then
  echo "Usage: $0 <source_directory> <destination_directory> [jobs]" >&2
  exit 1
fi

if [[ ! "$THREADS" =~ ^[1-9][0-9]*$ ]]; then
  echo "Error: jobs must be a positive integer" >&2
  exit 1
fi

if [[ ! -d "$SOURCE_DIR" || ! -d "$DEST_DIR" ]]; then
  if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Error: source directory does not exist: $SOURCE_DIR" >&2
  else
    echo "Error: destination directory does not exist: $DEST_DIR" >&2
  fi
  exit 1
fi

SOURCE_DIR="$(realpath -- "$SOURCE_DIR")"
DEST_DIR="$(realpath -- "$DEST_DIR")"

if [[ "$SOURCE_DIR" == "$DEST_DIR" ]]; then
  echo "Source and destination are the same directory; nothing to copy."
  exit 0
fi

case "$DEST_DIR/" in "$SOURCE_DIR/"*)
  echo "Error: destination is inside the source directory; refusing to copy recursively." >&2
  exit 1
  ;;
esac

command -v rsync >/dev/null || {
  echo "Error: rsync is required" >&2
  exit 1
}

# Each top-level entry is a separate THREAD. NUL delimiters safely handle
# spaces, quotes, and newlines in filenames.
find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 -print0 |
  xargs -0 -r -n 1 -P "$THREADS" \
    bash -c '
            source_dir=$1
            dest_dir=$2
            src=$3

            rel=${src#"$source_dir"/}
            rsync -a -- "$src" "$dest_dir/$rel" || exit $?
            printf "Synced: %s\n" "$rel"
        ' _ "$SOURCE_DIR" "$DEST_DIR"
