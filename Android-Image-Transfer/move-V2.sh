#!/bin/bash

# Loop through every directory and file in the current directory
for item in *; do
  # Skip the script itself
  if [ "$item" == "move-V1.sh" ]; then
    continue
  fi
  if [ "$item" == "move-V2.sh" ]; then
    continue
  fi

  echo "Processing: $item"
  # ADB pushes files directly to the device without needing a mount point
  adb push "$item" "/sdcard/Pictures/"
done

echo "Transfer complete."
