#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "Run this as your normal user, not with sudo."
  exit 1
fi

sudo -v

# Enable multilib for Steam and other 32-bit packages.
if ! grep -q '^[[:space:]]*\[multilib\]' /etc/pacman.conf; then
  sudo sed -i \
    '/^[[:space:]]*#\[multilib\]/,/^[[:space:]]*#Include = \/etc\/pacman.d\/mirrorlist/{
      s/^[[:space:]]*#\[multilib\]/[multilib]/
      s/^[[:space:]]*#Include =/Include =/
    }' /etc/pacman.conf
fi

# Full upgrade, not pacman -Sy alone.
sudo pacman -Syu

OFFICIAL=(
  base-devel git
  neovim firefox btop man tldr unzip zip
  openssh fastfetch ncdu tree ripgrep
  otf-font-awesome
  flatpak flatseal
  steam
  spotify-player libreoffice-fresh wireshark-qt qbittorrent
  gwenview mpv kolourpaint
  qemu-full virt-manager virt-viewer libvirt dnsmasq edk2-ovmf swtpm
  docker
  linux-headers libusb
  libinput-tools brightnessctl power-profiles-daemon
  hyprland hyprpolkitagent hyprpaper
  wl-clipboard rofi waybar flameshot lxappearance
  qt5-wayland qt6-wayland pavucontrol networkmanager
  alacritty ly dunst hyprlock libnotify
  qt6ct-kde
  ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-common
  ttf-nerd-fonts-symbols-mono
  cmake extra-cmake-modules ninja scdoc gamemode vulkan-headers prismlauncher
  grub os-prober ntfs-3g efibootmgr
  yazi wiremix
)

sudo pacman -S --needed "${OFFICIAL[@]}"

# Build and install yay-bin from ~/AUR.
# This does not install the separate "yay" package.
mkdir -p "$HOME/AUR"
if [[ ! -d "$HOME/AUR/yay-bin" ]]; then
  git clone https://aur.archlinux.org/yay-bin.git "$HOME/AUR/yay-bin"
fi
(
  cd "$HOME/AUR/yay-bin"
  makepkg -si
)

AUR=(
  visual-studio-code-bin
  zen-browser-bin
  brave-bin
  helium-browser-bin
  vesktop-bin
  localsend-bin
  blueberry
  smile
  arch-sense
)

yay -S --needed "${AUR[@]}"

# Install Arch-Sense user permissions as requested.
arch-sense --install-permissions

# Optional NVIDIA drivers: install only if these suit your GPU.
read -r -p "Install NVIDIA driver packages? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  yay -S --needed nvidia-open-dkms nvidia-utils lib32-nvidia-utils \
    libva-nvidia-driver linux-firmware-nvidia
fi

# Only the Sober Flatpak remains from your original Flatpak list.
flatpak remote-add --if-not-exists flathub \
  https://flathub.org/repo/flathub.flatpakrepo
flatpak install --system -y flathub org.vinegarhq.Sober

# Start virtualization and Docker services.
sudo systemctl enable --now libvirtd
sudo systemctl enable --now docker

# Switch to Ly. Disable SDDM if present, then enable Ly.
sudo systemctl disable --now sddm.service 2>/dev/null || true
sudo systemctl enable ly.service

echo
echo "Install finished. Reboot and test the Ly login screen."

sudo pacman -Rns plasma sddm sddm-kcm
yay -S kde-applications-nogames-nodevel-noedu-meta 
