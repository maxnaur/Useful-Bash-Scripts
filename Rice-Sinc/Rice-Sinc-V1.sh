# rice update config files
rs() {
  local backup_root="$HOME/Documents/Arch-Rice/config-files"
  local bashrc_dest="$HOME/Documents/Arch-Rice/config-files/bashrc"
  mkdir -p $backup_root/config
  mkdir -p $backup_root/etc
  mkdir -p $backup_root/AUR

  # update config folders
  local folders=("BraveSoftware" "btop" "dunst" "Code" "fastfetch" "flameshot" "fontconfig" "hypr" "kitty" "net.imput.helium" "nvim" "pacseek" "qBittorrent" "rofi" "spotify-player" "vesktop" "waybar" "wireshark" "zen")

  for folder in "${folders[@]}"; do
    local src="$HOME/.config/$folder"
    local dest="$backup_root/config/"
    sync_if_changed "$src" "$dest" "folder"
  done

  # remove browser spesific storage
  rm -rf "$backup_root/config/zen/3dhfb575.Default (release)/storage/temporary/"
  rm -rf "$backup_root/config/net.imput.helium/Default/Service Worker/CacheStorage/"

  # kde config for hyprland with kde apps
  sync_if_changed "$HOME/.config/kdeglobals" "$backup_root/config/kdeglobals" "file"

  # update bashrc
  sync_if_changed "$HOME/.bashrc" "$bashrc_dest" "file"

  # update etc config files
  local etc_folders=("pacman.conf")

  for folder in "${etc_folders[@]}"; do
    local src="/etc/$folder"
    local dest="$backup_root/etc/"
    sync_if_changed "$src" "$dest" "file" "true"
  done

  # update etc config folder
  local etc_folders=("default" "ly")

  for folder in "${etc_folders[@]}"; do
    local src="/etc/$folder"
    local dest="$backup_root/etc/"
    sync_if_changed "$src" "$dest" "folder" "true"
  done

  # clear the cash inside the folders
  local remove_folder=("/config/discord/Cache" "/config/vesktop/Code Cache" "/config/vesktop/Crashpad" "")
  local remove_file=("/config/vesktop/SingletonCookie" "/config/vesktop/SingletonLock" "/config/vesktop/SingletonSocket" "")

  # update config folders
  local folders=("Linuwu-Sense" "packettracer" "yay-bin")

  for folder in "${folders[@]}"; do
    local src="$HOME/AUR/$folder"
    local dest="$backup_root/AUR/"
    sync_if_changed "$src" "$dest" "folder"
    local git="$backup_root/AUR/$folder/.git"
    rm $git
    echo "rm -rf $git"
  done

  sudo chown -R max:max $backup_root
}

sync_if_changed() {
  local src="$1"
  local dest="$2"
  local type="$3"
  local sudos="$4"

  # If source doesn't exist, skip
  [[ -e "$src" ]] || return 1

  # Generate hash of CONTENT only, ignoring file paths
  # We find all files, and for each file, we feed the content into sha256sum
  # 'cat' ensures we are hashing the bytes of the file, not the filename string
  local src_hash=$(LC_ALL=C find "$src" -type f -print0 | sort -z | xargs -0 cat | sha256sum | awk '{print $1}')
  local dest_hash=$(LC_ALL=C find "$dest" -type f -print0 | sort -z | xargs -0 cat | sha256sum | awk '{print $1}')

  if [ "$src_hash" != "$dest_hash" ]; then
    echo "Updating: $src"
    mkdir -p "$(dirname "$dest")"
    if [ "$type" == "folder" ]; then
      rm "$dest" 2>/dev/null
      if [ "$sudos" == "true" ]; then
        sudo cp -r "$src" "$dest"
      else
        cp -r "$src" "$dest"
      fi
    else
      cp "$src" "$dest"
    fi
  fi
}
