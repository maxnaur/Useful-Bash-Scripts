#!/bin/bash

# 1. Find the actual local path for the MTP mount
# MTP devices are usually mounted under /run/user/1000/gvfs/
# We search for the directory containing "Armor 30"
DEST=$(find /run/user/$UID/gvfs -type d -name "*Armor 30*" 2>/dev/null | head -n 1)

if [ -z "$DEST" ]; then
  echo "Error: Armor 30 not found. Please make sure the device is plugged in and the folder is open in your file manager."
  exit 1
fi

# Define the specific target folder on the device
FINAL_DEST="$DEST/Internal shared storage/Pictures/"

# Ensure the destination directory exists
mkdir -p "$FINAL_DEST"

# Loop through every directory and file in the current directory
for item in *; do
  # Skip the script itself so it doesn't copy move.sh to the phone
  if [ "$item" == "move.sh" ]; then
    continue
  fi

  echo "Processing: $item"
  sudo rsync -a --no-owner --no-group "$item" --inplace -v "$FINAL_DEST"
done

echo "Transfer complete."
