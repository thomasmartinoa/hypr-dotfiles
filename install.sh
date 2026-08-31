#!/usr/bin/env bash
#
# Installer for thomasmartinoa/hypr-dotfiles
# See usage() below, or run ./install.sh --help

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Every top-level directory that is a stow package.
PACKAGES=(alacritty gtk hyprland kde kittyterminal nvim qt rofi starship swaync
          theme waybar wlogout zsh)

PKGS_REPO=(
  hyprland hyprlock hypridle waybar rofi swaync awww
  xdg-desktop-portal-hyprland polkit-gnome qt5ct qt6ct power-profiles-daemon
  kitty alacritty zsh starship
  neovim fastfetch btop eza
  grim slurp wl-clipboard cliphist playerctl brightnessctl batsignal jq ffmpeg
  thunar pavucontrol networkmanager nm-connection-editor
  ttf-jetbrains-mono-nerd inter-font papirus-icon-theme adw-gtk-theme stow
)

# Not in the official Arch repos. On CachyOS these ship in the [cachyos] repo;
# on plain Arch they come from the AUR.
PKGS_AUR=(wlogout adwaita-qt5 adwaita-qt6)

# ============================================================================
# Presentation
# ============================================================================
# Colour only when stdout is a terminal, so piping to a file or a pager gives
# clean text instead of escape sequences.
if [[ -t 1 ]] && [[ "${TERM:-dumb}" != "dumb" ]] && [[ -z "${NO_COLOR:-}" ]]; then
  C_DIM=$'\033[2;37m'; C_TXT=$'\033[0;37m';  C_HI=$'\033[1;97m'
  C_OK=$'\033[1;32m';  C_WRN=$'\033[1;33m';  C_ERR=$'\033[1;31m'
  C_ACC=$'\033[1;36m'; C_RST=$'\033[0m'
else
  C_DIM=''; C_TXT=''; C_HI=''; C_OK=''; C_WRN=''; C_ERR=''; C_ACC=''; C_RST=''
fi

STEP_N=0
STEP_TOTAL=6

banner() {
  printf '%s\n' ""
  printf '%s\n' "${C_HI}    ██╗  ██╗██╗   ██╗██████╗ ██████╗ ${C_RST}"
  printf '%s\n' "${C_HI}    ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗${C_RST}"
  printf '%s\n' "${C_HI}    ███████║ ╚████╔╝ ██████╔╝██████╔╝${C_RST}"
  printf '%s\n' "${C_DIM}    ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗${C_RST}"
  printf '%s\n' "${C_DIM}    ██║  ██║   ██║   ██║     ██║  ██║${C_RST}"
  printf '%s\n' "${C_DIM}    ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝${C_RST}"
  printf '%s\n' "${C_ACC}         d o t f i l e s${C_RST}${C_DIM}  ·  hyprland · lua${C_RST}"
  printf '%s\n' ""
  printf '%s\n' "${C_DIM}    ────────────────────────────────────────────${C_RST}"
  printf '%s\n' "${C_DIM}    repo   ${C_RST}${C_TXT}${DOTFILES_DIR}${C_RST}"
  printf '%s\n' "${C_DIM}    target ${C_RST}${C_TXT}${HOME}${C_RST}"
  printf '%s\n' "${C_DIM}    mode   ${C_RST}${C_TXT}${RUN_MODE}${C_RST}"
  printf '%s\n' "${C_DIM}    ────────────────────────────────────────────${C_RST}"
}

step()  { STEP_N=$((STEP_N+1)); printf '\n%s\n' "${C_ACC}[${STEP_N}/${STEP_TOTAL}]${C_RST} ${C_HI}$*${C_RST}"; }
skip()  { STEP_N=$((STEP_N+1)); printf '\n%s\n' "${C_DIM}[${STEP_N}/${STEP_TOTAL}] $* (skipped)${C_RST}"; }
info()  { printf '  %s %s\n' "${C_ACC}·${C_RST}" "$*"; }
ok()    { printf '  %s %s\n' "${C_OK}✓${C_RST}" "$*"; }
warn()  { printf '  %s %s\n' "${C_WRN}!${C_RST}" "$*" >&2; }
die()   { printf '\n  %s %s\n\n' "${C_ERR}✗${C_RST}" "$*" >&2; exit 1; }
# Indent every line of a multi-line block, not just the first. Trailing blank
# lines are dropped so callers don't have to trim their accumulators.
block() { printf '%s' "$*" | sed -e '/^[[:space:]]*$/d' -e 's/^/      /'; echo; }

# Stow's conflict text is a long sentence naming both the source and the target.
# Only the target matters to the reader, so pull it out:
#   "* cannot stow <src> over existing target <tgt> since neither a link ..."
#   "* existing target is not owned by stow: <tgt>"
conflict_targets() {
  sed -e 's|.*over existing target \([^ ]*\) since.*|~/\1|' \
      -e 's|.*existing target is not owned by stow: *|~/|' <<<"$*" \
    | sed 's/^[[:space:]]*\*[[:space:]]*//' | sort -u
}

usage() {
  cat <<'EOF'
Installer for thomasmartinoa/hypr-dotfiles

  ./install.sh                install packages, then symlink configs with stow
  ./install.sh --stow-only    skip package installation
  ./install.sh --dry-run      show what stow would do, change nothing
  ./install.sh --migrate      back up files that block stow, then continue
  ./install.sh --skip-root    don't copy the GTK config into /root
  ./install.sh --help         this text

On a fresh machine, Hyprland writes its own default ~/.config/hypr/hyprland.lua
on first launch, which blocks stow. --migrate clears it (backing it up first).

Set NO_COLOR=1 to disable colour.
EOF
}

# ============================================================================
# Arguments
# ============================================================================
STOW_ONLY=0; DRY_RUN=0; MIGRATE=0; SKIP_ROOT=0
for arg in "$@"; do
  case "$arg" in
    --stow-only) STOW_ONLY=1 ;;
    --dry-run)   DRY_RUN=1 ;;
    --migrate)   MIGRATE=1 ;;
    --skip-root) SKIP_ROOT=1 ;;
    -h|--help)   usage; exit 0 ;;
    *) printf 'unknown option: %s\n\n' "$arg" >&2; usage >&2; exit 2 ;;
  esac
done

RUN_MODE="full install"
[[ $STOW_ONLY -eq 1 ]] && RUN_MODE="stow only"
[[ $DRY_RUN   -eq 1 ]] && RUN_MODE="dry run (nothing will change)"
[[ $MIGRATE   -eq 1 ]] && RUN_MODE="$RUN_MODE + migrate"

banner

[[ $EUID -eq 0 ]] && die "Do not run this as root. It installs into \$HOME and calls sudo only where needed."

# ============================================================================
# 1. Packages
# ============================================================================
if [[ $STOW_ONLY -eq 0 && $DRY_RUN -eq 0 ]]; then
  step "Packages"

  if ! command -v pacman >/dev/null 2>&1; then
    warn "pacman not found — this installer only automates Arch-based systems."
    warn "Install these by hand, then re-run with --stow-only:"
    block "${PKGS_REPO[*]}"
    block "${PKGS_AUR[*]}"
    die "Nothing installed."
  fi

  # Check each package resolves BEFORE calling pacman. A single unknown name
  # makes `pacman -S` refuse the whole transaction, which under `set -e` would
  # abort the installer with a bare pacman error and nothing else done.
  info "Resolving ${#PKGS_REPO[@]} packages..."
  avail=(); missing=()
  for pkg in "${PKGS_REPO[@]}"; do
    if pacman -Si "$pkg" >/dev/null 2>&1; then avail+=("$pkg"); else missing+=("$pkg"); fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    warn "${#missing[@]} package(s) not found in your configured repos:"
    block "${missing[*]}"
    warn "Continuing with the rest. Install those by hand if you want the full setup."
  fi

  if [[ ${#avail[@]} -gt 0 ]]; then
    info "Installing ${#avail[@]} package(s) — sudo will prompt."
    sudo pacman -S --needed "${avail[@]}"
    ok "Repo packages done."
  fi

  # Some of PKGS_AUR may be in a configured repo (CachyOS); the rest need the AUR.
  from_repo=(); need_aur=()
  for pkg in "${PKGS_AUR[@]}"; do
    if pacman -Si "$pkg" >/dev/null 2>&1; then from_repo+=("$pkg"); else need_aur+=("$pkg"); fi
  done

  if [[ ${#from_repo[@]} -gt 0 ]]; then
    info "In a configured repo: ${from_repo[*]}"
    sudo pacman -S --needed "${from_repo[@]}"
  fi

  if [[ ${#need_aur[@]} -gt 0 ]]; then
    if command -v paru >/dev/null 2>&1; then
      info "Installing with paru: ${need_aur[*]}"
      paru -S --needed "${need_aur[@]}"
      ok "AUR packages done."
    elif command -v yay >/dev/null 2>&1; then
      info "Installing with yay: ${need_aur[*]}"
      yay -S --needed "${need_aur[@]}"
      ok "AUR packages done."
    else
      warn "No AUR helper found. Install these by hand:"
      block "${need_aur[*]}"
      warn "Without wlogout the logout menu won't work; without adwaita-qt* Qt apps"
      warn "fall back to the Fusion style (the hypr-mono palette still applies)."
    fi
  fi
else
  skip "Packages"
fi

command -v stow >/dev/null 2>&1 || die "GNU Stow is not installed (pacman -S stow)."

# ============================================================================
# 2. Migration
# ============================================================================
# Files written by nwg-look, the partial GTK4 theme-symlink hack, or Hyprland's
# own first-launch config generator sit exactly where stow needs to put symlinks.
#
# The GTK4 entries matter more than they look: symlinking only gtk.css from a
# theme into ~/.config/gtk-4.0/ breaks it, because GTK resolves that file's
# relative @imports against ~/.config/gtk-4.0/ (the logical path), not against
# the theme directory. libadwaita.css is then never found and GTK4 apps end up
# with no theme at all.
MIGRATE_PATHS=(
  # Hyprland writes a default config on its first launch when none exists. On a
  # fresh machine you log into Hyprland before running this script, so these are
  # almost always present and are the most common reason stow aborts. The
  # session banner "You're using an autogenerated config!" is the giveaway.
  "$HOME/.config/hypr/hyprland.lua"
  "$HOME/.config/hypr/hyprland.conf"
  "$HOME/.gtkrc-2.0"
  "$HOME/.gtkrc-2.0.mine"
  "$HOME/.config/gtk-3.0/settings.ini"
  "$HOME/.config/gtk-3.0/gtk.css"
  "$HOME/.config/gtk-4.0/settings.ini"
  "$HOME/.config/gtk-4.0/gtk.css"
  "$HOME/.config/gtk-4.0/gtk-dark.css"
  "$HOME/.config/gtk-4.0/assets"
  "$HOME/.config/kdeglobals"
)

if [[ $MIGRATE -eq 1 && $DRY_RUN -eq 0 ]]; then
  step "Migration"
  backup="$HOME/.config/hypr-dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
  moved=0
  for f in "${MIGRATE_PATHS[@]}"; do
    [[ -e "$f" || -L "$f" ]] || continue
    # Never move a link this repo already owns — that would undo a good stow
    # and makes re-running --migrate destructive instead of idempotent.
    if [[ -L "$f" ]] && [[ "$(readlink -f "$f" 2>/dev/null)" == "$DOTFILES_DIR"/* ]]; then
      continue
    fi
    # Preserve the path under $HOME, not just the basename: gtk-3.0/settings.ini
    # and gtk-4.0/settings.ini would otherwise collide and one would be lost.
    rel="${f#"$HOME"/}"
    mkdir -p "$backup/$(dirname "$rel")"
    mv -- "$f" "$backup/$rel"
    info "moved ${rel}"
    moved=$((moved+1))
  done
  if [[ $moved -gt 0 ]]; then
    ok "Backed up $moved file(s) to ${backup/#$HOME/\~}"
  else
    ok "Nothing to migrate — those paths are already clear."
  fi
else
  skip "Migration"
fi

# ============================================================================
# 3. Pre-flight
# ============================================================================
step "Pre-flight checks"

if [[ $DRY_RUN -eq 0 ]]; then
  # Screenshot binds pipe through `tee`, which will not create the directory.
  mkdir -p "$HOME/Pictures/screenshot"
  # Keep ~/.config/qt[56]ct real directories so stow folds only colors/ into a
  # symlink, leaving qt[56]ct.conf real files that the GUIs can rewrite.
  mkdir -p "$HOME/.config/qt5ct" "$HOME/.config/qt6ct"
  ok "Directories ready."
fi

# Every package must exist, or stow fails partway through.
absent=()
for pkg in "${PACKAGES[@]}"; do
  [[ -d "$DOTFILES_DIR/$pkg" ]] || absent+=("$pkg")
done
if [[ ${#absent[@]} -gt 0 ]]; then
  warn "These stow packages are listed but missing from the repo:"
  block "${absent[*]}"
  die "Repo looks incomplete — a partial clone?"
fi
ok "All ${#PACKAGES[@]} stow packages present."

# Stow refuses to overwrite real files. Find them before it fails halfway.
conflicts="$(stow --no --verbose=1 --target="$HOME" --dir="$DOTFILES_DIR" "${PACKAGES[@]}" 2>&1 \
             | grep -i 'existing target' || true)"

if [[ -n "$conflicts" ]]; then
  warn "Stow found real files where symlinks need to go:"
  block "$(conflict_targets "$conflicts")"
  echo

  # The overwhelmingly common case on a fresh install: you logged into Hyprland
  # once before running this, so Hyprland generated its own default config.
  if grep -q 'hypr/hyprland\.\(lua\|conf\)' <<<"$conflicts"; then
    warn "That hyprland.lua is Hyprland's own autogenerated default — it writes"
    warn "one on first launch when no config exists. If your session shows the"
    warn "banner \"You're using an autogenerated config!\", this is it, and it is"
    warn "safe to replace."
    echo
  fi

  # Split the conflicts into what --migrate handles and what it does not, so the
  # advice is specific rather than "figure it out".
  unhandled=""
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    covered=0
    for m in "${MIGRATE_PATHS[@]}"; do
      grep -qF "${m#"$HOME"/}" <<<"$line" && { covered=1; break; }
    done
    [[ $covered -eq 0 ]] && unhandled+="$line"$'\n'
  done <<<"$conflicts"

  # Only advertise --migrate if it would actually help. Suggesting it when every
  # remaining conflict is outside MIGRATE_PATHS just sends the reader in a loop.
  if [[ "$(printf '%s' "$unhandled" | wc -l)" -lt "$(printf '%s' "$conflicts" | wc -l)" ]]; then
    warn "Fix:  ./install.sh --migrate    (backs these up, then continues)"
  fi
  if [[ -n "$unhandled" ]]; then
    echo
    warn "These are not ones this script will touch — move them by hand:"
    block "$(conflict_targets "$unhandled")"
    warn "e.g.  mv ~/.config/hypr/hyprlock.conf ~/.config/hypr/hyprlock.conf.bak"
    warn "Then re-run. Anything you move is yours to restore."
  fi
  [[ $DRY_RUN -eq 0 ]] && die "Aborting so nothing of yours is lost."
else
  ok "No conflicts."
fi

# ============================================================================
# 4. Symlinks
# ============================================================================
if [[ $DRY_RUN -eq 1 ]]; then
  step "Symlinks (dry run)"
  plan="$(stow --no --verbose=2 --target="$HOME" --dir="$DOTFILES_DIR" "${PACKAGES[@]}" 2>&1 \
          | grep -E '^(LINK|UNLINK|CONFLICT)' || true)"
  if [[ -n "$plan" ]]; then
    block "$plan"
    info "$(grep -c '^LINK' <<<"$plan" || true) link(s) would be created."
  else
    ok "Nothing to do — all ${#PACKAGES[@]} packages are already linked."
  fi
  printf '\n  %s %s\n\n' "${C_OK}✓${C_RST}" "Dry run complete — nothing was changed."
  exit 0
fi

step "Symlinks"
info "Stowing: ${PACKAGES[*]}"
stow --restow --target="$HOME" --dir="$DOTFILES_DIR" "${PACKAGES[@]}"
ok "${#PACKAGES[@]} packages linked."

chmod +x "$HOME/.config/rofi/launchers/launcher.sh" \
         "$HOME/.config/rofi/scripts/clipboard.sh" \
         "$HOME/.config/waybar/scripts/launch.sh" \
         "$HOME/.config/wlogout/launch.sh" \
         "$HOME/.config/hypr/scripts/songdetail.sh" 2>/dev/null || true

# ============================================================================
# 5. Qt configuration
# ============================================================================
# Templated rather than stowed: color_scheme_path must be an absolute path
# (qt*ct resolves it with QFile, which does not expand "~"), and the qt*ct GUIs
# rewrite these files in place, which would push window geometry into git.
step "Qt configuration"
for v in 5 6; do
  conf="$HOME/.config/qt${v}ct/qt${v}ct.conf"
  tmpl="$DOTFILES_DIR/templates/qt${v}ct.conf.in"
  [[ -r "$tmpl" ]] || { warn "missing template: templates/qt${v}ct.conf.in"; continue; }
  rendered="$(sed "s|@HOME@|$HOME|g" "$tmpl")"
  if [[ -e "$conf" ]] && ! diff -q <(printf '%s\n' "$rendered") "$conf" >/dev/null 2>&1; then
    cp -- "$conf" "$conf.bak"
    info "backed up qt${v}ct.conf → qt${v}ct.conf.bak"
  fi
  printf '%s\n' "$rendered" > "$conf"
  ok "qt${v}ct.conf rendered (colour scheme: hypr-mono)"
done

# ============================================================================
# 6. Root theming
# ============================================================================
# Apps that re-exec themselves through pkexec (grub-customizer is the one here)
# run their GUI as root. pkexec sanitises the environment, so GTK_THEME and
# XDG_CONFIG_HOME do not survive, and root reads /root/.config — which has no
# theme at all, hence the stock light Adwaita window. Give root its own copies.
if [[ $SKIP_ROOT -eq 1 ]]; then
  skip "Root theming"
elif ! command -v pkexec >/dev/null 2>&1; then
  skip "Root theming (no pkexec on this system)"
else
  step "Root theming"
  info "For pkexec GUIs such as grub-customizer. sudo may prompt."
  if sudo -v; then
    sudo mkdir -p /root/.config/gtk-3.0 /root/.config/gtk-4.0 /root/.config/hypr-theme
    # gtk.css imports ../hypr-theme/palette.css, so root needs that too.
    sudo cp -- "$DOTFILES_DIR/theme/.config/hypr-theme/palette.css" /root/.config/hypr-theme/palette.css
    sudo cp -- "$DOTFILES_DIR/gtk/.config/gtk-3.0/settings.ini"     /root/.config/gtk-3.0/settings.ini
    sudo cp -- "$DOTFILES_DIR/gtk/.config/gtk-3.0/gtk.css"          /root/.config/gtk-3.0/gtk.css
    sudo cp -- "$DOTFILES_DIR/gtk/.config/gtk-4.0/settings.ini"     /root/.config/gtk-4.0/settings.ini
    sudo cp -- "$DOTFILES_DIR/gtk/.config/gtk-4.0/gtk.css"          /root/.config/gtk-4.0/gtk.css
    sudo cp -- "$DOTFILES_DIR/gtk/.gtkrc-2.0"                       /root/.gtkrc-2.0
    ok "Root GTK config installed."
  else
    warn "Skipped — no sudo. pkexec GUIs keep the default light theme."
    warn "Re-run later, or pass --skip-root to silence this."
  fi
fi

# ============================================================================
# Summary
# ============================================================================
printf '\n%s\n' "${C_DIM}  ────────────────────────────────────────────────────────────${C_RST}"
printf '%s\n\n' "  ${C_OK}✓${C_RST} ${C_HI}Installed.${C_RST}${C_DIM}  Restart your apps to see the theme.${C_RST}"

# NOTE: do not write this as `fc-list | grep -q`. `grep -q` exits on the first
# match, fc-list then dies of SIGPIPE (141), and `set -o pipefail` turns the
# whole pipeline into a failure — so the check reports "missing" even when the
# font is installed. Capture first, match second.
font_ok=0
font_families="$(fc-list : family 2>/dev/null || true)"
grep -qi 'JetBrainsMono Nerd Font Propo' <<<"$font_families" && font_ok=1
if [[ $font_ok -eq 1 ]]; then
  printf '  %s %s\n' "${C_OK}✓${C_RST}" "Font: JetBrainsMono Nerd Font Propo found."
else
  printf '  %s %s\n' "${C_WRN}!${C_RST}" "${C_WRN}Font missing:${C_RST} JetBrainsMono Nerd Font ${C_HI}Propo${C_RST} is not installed."
  printf '      %s\n' "Every waybar and swaync icon will render as a blank box."
  printf '      %s\n' "Fix:  sudo pacman -S ttf-jetbrains-mono-nerd"
fi

# printf '\n  %s\n' "${C_HI}Next steps${C_RST}"
# printf '  %s\n' "${C_DIM}  1${C_RST} Edit ${C_TXT}hyprland/.config/hypr/modules/monitors.lua${C_RST} — it is hardcoded"
# printf '  %s\n' "${C_DIM}   ${C_RST} to a 2560x1440@165Hz eDP-1 at 1.6x scale. Run ${C_TXT}hyprctl monitors${C_RST}."
# printf '  %s\n' "${C_DIM}  2${C_RST} Restart GTK/Qt apps — they read their theme at startup."
# printf '  %s\n' "${C_DIM}   ${C_RST} ${C_TXT}SUPER+R${C_RST} restarts waybar and swaync for you."
# printf '  %s\n' "${C_DIM}  3${C_RST} Apps with their own theme engines are not covered: VS Code, Zen,"
# printf '  %s\n' "${C_DIM}   ${C_RST} Telegram, LocalSend, OBS, Heroic. See the README section"
# printf '  %s\n' "${C_DIM}   ${C_RST} \"Apps that ignore the system theme\"."
# printf '\n%s\n\n' "${C_DIM}  ────────────────────────────────────────────────────────────${C_RST}"
