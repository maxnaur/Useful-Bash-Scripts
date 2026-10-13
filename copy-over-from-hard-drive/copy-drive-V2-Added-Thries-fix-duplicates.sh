#!/usr/bin/env bash
set -u

apply=false

if [[ "${1:-}" == "--apply" ]]; then
  apply=true
elif [[ $# -gt 0 ]]; then
  printf 'Usage: %s [--apply]\n' "$0" >&2
  exit 2
fi

# Find directories deepest-first so nested matches are handled before their parents.
while IFS= read -r -d '' inner; do
  parent=$(dirname -- "$inner")
  name=$(basename -- "$inner")

  # Only process a folder when its name matches its parent's name:
  # e.g. ~/name/name
  [[ $(basename -- "$parent") == "$name" ]] || continue

  # Include hidden items, and safely handle empty folders.
  shopt -s dotglob nullglob
  items=("$inner"/*)
  shopt -u dotglob nullglob

  for item in "${items[@]}"; do
    target="$parent/$(basename -- "$item")"

    # Don't overwrite anything already in the parent folder.
    if [[ -e "$target" || -L "$target" ]]; then
      printf 'SKIP (destination exists): %q -> %q\n' "$item" "$target"
      #continue
    fi

    if $apply; then
      if mv -- "$item" "$target"; then
        printf 'MOVED: %q -> %q\n' "$item" "$target"
      else
        printf 'ERROR moving: %q\n' "$item" >&2
      fi
    else
      printf 'Would move: %q -> %q\n' "$item" "$target"
    fi
  done

  # Remove the matched inner folder only if it is now empty.
  if $apply; then
    if rmdir -- "$inner" 2>/dev/null; then
      printf 'REMOVED empty folder: %q\n' "$inner"
    else
      printf 'KEPT folder (not empty): %q\n' "$inner"
    fi
  else
    printf 'Would remove folder if empty: %q\n' "$inner"
  fi
done < <(find "$HOME" -depth -type d -print0)
