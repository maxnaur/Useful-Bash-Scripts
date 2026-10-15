# rice update config files
rs() {
  local DEST_DIR="$HOME/Documents/Arch-Rice/config-files"

  # Create backup directories
  mkdir -p "$DEST_DIR"/{config,etc,AUR}

  # Sync config folders
  local config_folders=("BraveSoftware" "btop" "dunst" "Code" "fastfetch" "flameshot" "fontconfig" "hypr" "kitty" "net.imput.helium" "nvim" "pacseek" "qBittorrent" "rofi" "spotify-player" "vesktop" "waybar" "wireshark" "zen")

  for folder in "${config_folders[@]}"; do
    rsync -av --delete "$HOME/.config/$folder/" "$DEST_DIR/config/$folder/"
  done

  # Remove browser-specific storage
  rm -rf "$DEST_DIR/config/zen/3dhfb575.Default (release)/storage/temporary/"
  rm -rf "$DEST_DIR/config/net.imput.helium/Default/Service Worker/CacheStorage/"

  # Sync KDE config
  rsync -av "$HOME/.config/kdeglobals" "$DEST_DIR/config/"

  # Sync bashrc
  rsync -av "$HOME/.bashrc" "$DEST_DIR/config-files/"

  # Sync /etc files and folders with sudo
  rsync -av --delete "$HOME/.config/kdeglobals" "$DEST_DIR/config/"
  sudo rsync -av "$HOME/AUR/" "$DEST_DIR/AUR/" --exclude='.git'
  sudo rsync -av "/etc/pacman.conf" "$DEST_DIR/etc/"
  sudo rsync -av --delete "/etc/default/" "$DEST_DIR/etc/default/"
  sudo rsync -av --delete "/etc/ly/" "$DEST_DIR/etc/ly/"

  # Fix ownership
  sudo chown -R max:max "$backup_root"
}
