#!/bin/bash

# Check if correct number of arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <source_folder> <destination_folder>"
  exit 1
fi

SOURCE=$1
DEST=$2

# Ensure source exists
if [ ! -d "$SOURCE" ]; then
  echo "Error: Source directory $SOURCE does not exist."
  exit 1
fi

# rsync flags explained:
# -a: archive mode (preserves permissions, symlinks, timestamps, etc.)
# -H: preserves hard links
# -W: copy whole files (faster for local-to-local transfers as it skips the delta-diff calculation)
# --inplace: writes data directly to the destination file (reduces overhead)
# -v: verbose (remove if you want it to run silently)

echo "Copying $SOURCE to $DEST..."
rsync -aHW --inplace -v "$SOURCE" "$DEST"

if [ $? -eq 0 ]; then
  echo "Transfer completed successfully."
else
  echo "An error occurred during the transfer."
  exit 1
fi
