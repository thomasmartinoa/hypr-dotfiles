#!/usr/bin/env bash

# Installer for thomasmartinoa/hypr-dotfiles
#
#   ./install.sh              install packages, then symlink configs with stow
#   ./install.sh --stow-only  skip package installation
#   ./install.sh --dry-run    show what stow would do, change nothing

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Every top-level directory that is a stow package.
PACKAGES=(alacritty hyprland kittyterminal nvim rofi starship swaync waybar wlogout zsh)

# In the official Arch repos (core/extra).
PKGS_REPO=(
  hyprland hyprlock hypridle waybar rofi swaync awww
  xdg-desktop-portal-hyprland polkit-gnome qt6ct power-profiles-daemon
  kitty alacritty zsh starship
  neovim fastfetch btop eza
  grim slurp wl-clipboard cliphist playerctl brightnessctl batsignal jq ffmpeg
  thunar pavucontrol networkmanager nm-connection-editor
  ttf-jetbrains-mono-nerd stow
)

# Not in the official repos. On CachyOS wlogout ships in the [cachyos] repo;
# on plain Arch it comes from the AUR.
PKGS_AUR=(wlogout)

STOW_ONLY=0
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --stow-only) STOW_ONLY=1 ;;
    --dry-run)   DRY_RUN=1 ;;
    -h|--help)   sed -n '2,8p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

info()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die()   { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }

[[ $EUID -eq 0 ]] && die "Do not run this as root. It installs into \$HOME and calls sudo only where needed."

if [[ $STOW_ONLY -eq 0 && $DRY_RUN -eq 0 ]]; then
  if ! command -v pacman >/dev/null 2>&1; then
    warn "pacman not found — this installer only automates Arch-based systems."
    warn "Install these by hand, then re-run with --stow-only:"
    printf '   %s\n' "${PKGS_REPO[*]}" "${PKGS_AUR[*]}"
    exit 1
  fi

  info "Installing packages from the official repos..."
  sudo pacman -S --needed "${PKGS_REPO[@]}"

  if pacman -Si "${PKGS_AUR[0]}" >/dev/null 2>&1; then
    info "${PKGS_AUR[*]} is available in a configured repo — installing."
    sudo pacman -S --needed "${PKGS_AUR[@]}"
  elif command -v paru >/dev/null 2>&1; then
    info "Installing ${PKGS_AUR[*]} with paru..."
    paru -S --needed "${PKGS_AUR[@]}"
  elif command -v yay >/dev/null 2>&1; then
    info "Installing ${PKGS_AUR[*]} with yay..."
    yay -S --needed "${PKGS_AUR[@]}"
  else
    warn "No AUR helper found. Install these manually or the logout menu won't work:"
    printf '   %s\n' "${PKGS_AUR[*]}"
  fi
fi

command -v stow >/dev/null 2>&1 || die "GNU Stow is not installed (pacman -S stow)."

# --------------------------------------------------------------- pre-flight ---
# Screenshot binds pipe through `tee` into this directory; it must already exist.
if [[ $DRY_RUN -eq 0 ]]; then
  mkdir -p "$HOME/Pictures/screenshot"
fi

# A leftover hyprland.conf wins ambiguity against hyprland.lua. Flag it.
if [[ -e "$HOME/.config/hypr/hyprland.conf" || -L "$HOME/.config/hypr/hyprland.conf" ]]; then
  warn "~/.config/hypr/hyprland.conf exists (possibly a dead symlink from an older install)."
  warn "Remove it so Hyprland unambiguously loads hyprland.lua."
fi

# Stow refuses to overwrite real files. Find them before it fails halfway.
conflicts="$(stow --no --verbose=1 --target="$HOME" --dir="$DOTFILES_DIR" "${PACKAGES[@]}" 2>&1 \
             | grep -i 'existing target' || true)"
if [[ -n "$conflicts" ]]; then
  warn "Stow found real files where symlinks need to go:"
  printf '   %s\n' "$conflicts"
  warn "Back them up and delete them, then re-run. Example:"
  warn "   mv ~/.config/hypr/hyprlock.conf ~/.config/hypr/hyprlock.conf.bak"
  [[ $DRY_RUN -eq 0 ]] && die "Aborting so nothing of yours is lost."
fi

# -------------------------------------------------------------------- stow ---
if [[ $DRY_RUN -eq 1 ]]; then
  info "Dry run — stow would link:"
  stow --no --verbose=2 --target="$HOME" --dir="$DOTFILES_DIR" "${PACKAGES[@]}"
  exit 0
fi

info "Symlinking: ${PACKAGES[*]}"
stow --restow --target="$HOME" --dir="$DOTFILES_DIR" "${PACKAGES[@]}"

chmod +x "$HOME/.config/rofi/launchers/launcher.sh" \
         "$HOME/.config/rofi/scripts/clipboard.sh" \
         "$HOME/.config/waybar/scripts/launch.sh" \
         "$HOME/.config/wlogout/launch.sh" \
         "$HOME/.config/hypr/scripts/songdetail.sh" 2>/dev/null || true

info "Done."
echo
echo "  Two things worth checking before you log in:"
echo "   1. Fonts: this rice needs the *Propo* JetBrainsMono Nerd Font variant."
echo "      Verify with:  fc-list : family | grep -i 'JetBrainsMono Nerd Font Propo'"
echo "      Empty output means every waybar/swaync icon will render as a blank box."
echo "   2. Monitor: hyprland/.config/hypr/modules/monitors.lua is hardcoded to a"
echo "      2560x1440@165Hz eDP-1 at 1.6x scale. Edit it for your display."
