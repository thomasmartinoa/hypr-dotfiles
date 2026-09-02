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
  printf '%s\n' "${C_ACC}         d o t f i l e s${C_RST}${C_DIM}  ·  ${C_RST}${C_ACC}m a r t i n${C_RST}"
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

# Build and install yay from the AUR, using makepkg directly.
#
# Deliberately NOT yay-bin/paru-bin: those are prebuilt and linked against a
# fixed libalpm soname, so on a system whose pacman has moved on they install
# and then die with
#     error while loading shared libraries: libalpm.so.15
# Building from source compiles against whatever pacman is actually installed.
#
# yay is worth having rather than calling makepkg per package, because it also
# resolves split packages to their PackageBase and handles PGP keys for source
# tarballs — both of which bit this script when it tried to do it by hand.
bootstrap_yay() {
  local tmp rc=0
  info "Installing base-devel, git and go (needed to build yay)..."
  sudo pacman -S --needed base-devel git go || return 1

  tmp="$(mktemp -d)"
  info "Cloning yay from the AUR..."
  if git clone --depth 1 https://aur.archlinux.org/yay.git "$tmp/yay" >/dev/null 2>&1; then
    if [[ -f "$tmp/yay/PKGBUILD" ]]; then
      info "Building yay — this compiles Go, so give it a minute."
      # Subshell so a failed cd cannot leave us somewhere unexpected.
      ( cd "$tmp/yay" && makepkg -si --noconfirm ) || rc=1
    else
      warn "Cloned yay but there is no PKGBUILD in it."
      rc=1
    fi
  else
    warn "Could not clone yay from the AUR."
    rc=1
  fi
  rm -rf "$tmp"

  if [[ $rc -eq 0 ]] && command -v yay >/dev/null 2>&1; then
    ok "yay installed."
    return 0
  fi
  warn "Could not install yay."
  return 1
}

usage() {
  cat <<'EOF'
Installer for thomasmartinoa/hypr-dotfiles

  ./install.sh                install packages, then symlink configs with stow
  ./install.sh --stow-only    skip package installation
  ./install.sh --dry-run      show what stow would do, change nothing
  ./install.sh --migrate      back up blocking files without asking first
  ./install.sh --no-migrate   never move anything; stop instead
  ./install.sh --skip-root    don't copy the GTK config into /root
  ./install.sh --no-logout    don't offer to log out at the end
  ./install.sh --no-aur       don't offer to install yay / AUR packages
  ./install.sh --help         this text

On a fresh machine, Hyprland writes its own default ~/.config/hypr/hyprland.lua
on first launch, which blocks stow. A normal run notices this, shows you exactly
what is in the way, and offers to back it up — you do not need --migrate for the
common case. Use --migrate to skip that prompt (handy for scripted installs), or
--no-migrate to refuse outright.

Set NO_COLOR=1 to disable colour.
EOF
}

# ============================================================================
# Arguments
# ============================================================================
STOW_ONLY=0; DRY_RUN=0; MIGRATE=0; NO_MIGRATE=0; SKIP_ROOT=0; NO_LOGOUT=0; NO_AUR=0
for arg in "$@"; do
  case "$arg" in
    --stow-only)  STOW_ONLY=1 ;;
    --dry-run)    DRY_RUN=1 ;;
    --migrate)    MIGRATE=1 ;;
    --no-migrate) NO_MIGRATE=1 ;;
    --skip-root)  SKIP_ROOT=1 ;;
    --no-logout)  NO_LOGOUT=1 ;;
    --no-aur)     NO_AUR=1 ;;
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
    aur_helper=""
    command -v paru >/dev/null 2>&1 && aur_helper=paru
    [[ -z "$aur_helper" ]] && command -v yay >/dev/null 2>&1 && aur_helper=yay

    # Nothing to build with. These packages are not optional extras — wlogout is
    # the logout menu and adwaita-qt* is what makes Qt apps take the palette — so
    # offer to bootstrap a helper rather than just printing names.
    if [[ -n "$aur_helper" ]]; then
      info "Installing with $aur_helper: ${need_aur[*]}"
      "$aur_helper" -S --needed "${need_aur[@]}"
      ok "AUR packages done."
    elif [[ $NO_AUR -eq 1 ]]; then
      warn "--no-aur given. Install these by hand to complete the rice:"
      block "${need_aur[*]}"
    else
      warn "These are only in the AUR: ${need_aur[*]}"
      info "Without them: no logout menu, and Qt apps fall back to the Fusion style."
      info "No AUR helper found — yay can be built from source and used to get them."
      echo
      if [[ -t 0 && -t 1 ]]; then
        reply=""
        read -r -p "  $(printf '%s' "${C_ACC}?${C_RST}") Install yay and use it to fetch them? [Y/n] " reply </dev/tty || reply="n"
        echo
        case "${reply,,}" in
          ""|y|yes)
            if bootstrap_yay; then
              info "Installing with yay: ${need_aur[*]}"
              if yay -S --needed "${need_aur[@]}"; then
                ok "AUR packages done."
              else
                warn "yay could not install all of them:"
                block "${need_aur[*]}"
              fi
            else
              warn "Install an AUR helper by hand, then re-run. Needed:"
              block "${need_aur[*]}"
            fi
            ;;
          *)
            warn "Skipped. Install these by hand to complete the rice:"
            block "${need_aur[*]}"
            ;;
        esac
      else
        warn "Not a terminal — cannot ask. Install an AUR helper (paru/yay)"
        warn "and re-run. Needed:"
        block "${need_aur[*]}"
      fi
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

# Which MIGRATE_PATHS are actually present and not already links we own?
# A link already pointing into the repo is a *good* stow — moving it would undo
# the install and make repeated runs destructive instead of idempotent.
migratable_now() {
  local f
  for f in "${MIGRATE_PATHS[@]}"; do
    [[ -e "$f" || -L "$f" ]] || continue
    if [[ -L "$f" ]] && [[ "$(readlink -f "$f" 2>/dev/null)" == "$DOTFILES_DIR"/* ]]; then
      continue
    fi
    printf '%s\n' "$f"
  done
}

do_migrate() {
  local backup rel f moved=0
  backup="$HOME/.config/hypr-dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
  while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    # Preserve the path under $HOME, not just the basename: gtk-3.0/settings.ini
    # and gtk-4.0/settings.ini would otherwise collide and one would be lost.
    rel="${f#"$HOME"/}"
    mkdir -p "$backup/$(dirname "$rel")"
    mv -- "$f" "$backup/$rel"
    info "moved ~/${rel}"
    moved=$((moved+1))
  done < <(migratable_now)
  if [[ $moved -gt 0 ]]; then
    ok "Backed up $moved file(s) to ${backup/#$HOME/\~}"
  else
    ok "Nothing to move."
  fi
}

detect_conflicts() {
  stow --no --verbose=1 --target="$HOME" --dir="$DOTFILES_DIR" "${PACKAGES[@]}" 2>&1 \
    | grep -i 'existing target' || true
}

# Conflicts this script will NOT touch — anything outside MIGRATE_PATHS.
uncovered_conflicts() {
  local line m covered out=""
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    covered=0
    for m in "${MIGRATE_PATHS[@]}"; do
      grep -qF "${m#"$HOME"/}" <<<"$line" && { covered=1; break; }
    done
    [[ $covered -eq 0 ]] && out+="$line"$'\n'
  done <<<"$1"
  printf '%s' "$out"
}

step "Migration"
conflicts="$(detect_conflicts)"
pending="$(migratable_now)"

if [[ -z "$conflicts" ]]; then
  ok "Nothing in the way."
elif [[ $DRY_RUN -eq 1 ]]; then
  info "Would back up:"
  block "$(sed "s|^$HOME|~|" <<<"$pending")"
elif [[ -z "$pending" ]]; then
  ok "Nothing this script can move — see the checks below."
else
  uncovered="$(uncovered_conflicts "$conflicts")"

  warn "These files are where stow needs to put symlinks:"
  block "$(sed "s|^$HOME|~|" <<<"$pending")"

  # The overwhelmingly common case on a fresh install: you logged into Hyprland
  # once before running this, so Hyprland generated its own default config.
  if grep -q 'hypr/hyprland\.\(lua\|conf\)' <<<"$pending"; then
    echo
    info "hyprland.lua there is Hyprland's own autogenerated default — it writes"
    info "one on first launch when no config exists. Replacing it is expected."
  fi
  echo
  info "They will be MOVED (not deleted) to a timestamped backup under"
  info "~/.config/, so you can put any of them back afterwards."
  echo

  if [[ $NO_MIGRATE -eq 1 ]]; then
    warn "--no-migrate given; leaving them alone."
  elif [[ $MIGRATE -eq 1 ]]; then
    do_migrate
  elif [[ -t 0 && -t 1 ]]; then
    # Interactive: ask. Read from the terminal directly so this still works when
    # stdin is a pipe (e.g. `curl ... | bash` style invocations).
    reply=""
    read -r -p "  $(printf '%s' "${C_ACC}?${C_RST}") Back them up and continue? [Y/n] " reply </dev/tty || reply="n"
    echo
    case "${reply,,}" in
      ""|y|yes) do_migrate ;;
      *)        warn "Left alone at your request." ;;
    esac
  else
    warn "Not a terminal, so not moving anything without asking."
    warn "Re-run with --migrate to back these up automatically."
  fi

  if [[ -n "$uncovered" ]]; then
    echo
    warn "Note: these are outside what this script will touch —"
    block "$(conflict_targets "$uncovered")"
    warn "move them by hand before re-running."
  fi
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

# Re-check after the migration step. Anything still here was either declined,
# or is outside MIGRATE_PATHS and therefore not ours to move.
conflicts="$(detect_conflicts)"
if [[ -z "$conflicts" ]]; then
  ok "No conflicts."
elif [[ $DRY_RUN -eq 1 ]]; then
  # Nothing was moved, so of course they are still there. Say that plainly
  # rather than reporting it as a blocker.
  info "Still present (a real run would clear the migratable ones):"
  block "$(conflict_targets "$conflicts")"
else
  echo
  warn "Still blocked by:"
  block "$(conflict_targets "$conflicts")"
  # Use a real blocked path in the example, not a hardcoded one that may have
  # nothing to do with what is actually in the way.
  # Herestring rather than a pipe: `head -1` closes early, and with a large
  # enough upstream that raises SIGPIPE which `set -o pipefail` would turn into
  # an abort — inside the very block that is trying to explain the problem.
  all_targets="$(conflict_targets "$conflicts")"
  first="$(head -1 <<<"$all_targets")"
  warn "Move each aside and re-run, e.g.:"
  warn "   mv ${first} ${first}.bak"
  die "Aborting so nothing of yours is lost."
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
rule()  { printf '%s\n' "${C_DIM}  ────────────────────────────────────────────────────────────${C_RST}"; }
head2() { printf '\n  %s\n' "${C_HI}$*${C_RST}"; }
item()  { printf '  %s %s\n' "${C_DIM}·${C_RST}" "$*"; }

printf '\n'; rule
printf '\n  %s %s\n' "${C_OK}✓${C_RST}" "${C_HI}Installed.${C_RST}"

# NOTE: do not write this as `fc-list | grep -q`. `grep -q` exits on the first
# match, fc-list then dies of SIGPIPE (141), and `set -o pipefail` turns the
# whole pipeline into a failure — so the check reports "missing" even when the
# font is installed. Capture first, match second.
font_families="$(fc-list : family 2>/dev/null || true)"
if grep -qi 'JetBrainsMono Nerd Font Propo' <<<"$font_families"; then
  printf '  %s %s\n' "${C_OK}✓${C_RST}" "Font: JetBrainsMono Nerd Font Propo found."
else
  printf '  %s %s\n' "${C_WRN}!${C_RST}" "${C_WRN}Font missing:${C_RST} JetBrainsMono Nerd Font ${C_HI}Propo${C_RST}"
  printf '      %s\n' "Every waybar and swaync icon will render as a blank box."
  printf '      %s\n' "Fix:  sudo pacman -S ttf-jetbrains-mono-nerd"
fi

head2 "Live already"
item "Configs are symlinked — Hyprland, waybar, swaync, rofi, kitty, zsh."
item "${C_TXT}SUPER+R${C_RST} restarts waybar and swaync."

head2 "Needs a re-login"
item "GTK and Qt apps read their theme once, at startup."
item "env.lua sets QT_QPA_PLATFORMTHEME and the scale factors — those only"
item "reach applications launched by a fresh session."

head2 "Worth doing first"
item "${C_TXT}monitors.lua${C_RST} is hardcoded to one eDP-1 at 2560x1440@165Hz, scale 1.6."
item "Run ${C_TXT}hyprctl monitors${C_RST} and edit it to match your display."
item "VS Code, Zen, Telegram, OBS and other apps with their own theme engines"
item "are not covered — see the README."

printf '\n'; rule

# ---------------------------------------------------------------- log out ---
# Almost everything above needs a fresh session to take effect, so offer it
# rather than leaving the user wondering why half the theme did not apply.
# Default is NO: logging out drops whatever else they have open.
if [[ $NO_LOGOUT -eq 1 ]]; then
  :
elif [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  printf '\n  %s %s\n\n' "${C_ACC}·${C_RST}" "Log out and back in to apply the rest."
elif [[ -t 0 && -t 1 ]]; then
  printf '\n  %s %s\n' "${C_WRN}!${C_RST}" "Logging out will close everything you have open."
  reply=""
  read -r -p "  $(printf '%s' "${C_ACC}?${C_RST}") Log out of Hyprland now? [y/N] " reply </dev/tty || reply="n"
  echo
  case "${reply,,}" in
    y|yes)
      printf '  %s %s\n\n' "${C_ACC}·${C_RST}" "Logging out..."
      # Do not let a failed dispatch abort the script under `set -e` — the
      # install already succeeded, and a bare hyprctl error would look like it
      # had not.
      if ! hyprctl dispatch exit 2>/dev/null; then
        warn "Could not reach Hyprland. Log out by hand (SUPER+M)."
      fi
      ;;
    *)
      printf '  %s %s\n\n' "${C_ACC}·${C_RST}" "Log out when you are ready — ${C_TXT}SUPER+M${C_RST} opens the logout menu."
      ;;
  esac
else
  printf '\n  %s %s\n\n' "${C_ACC}·${C_RST}" "Log out and back in to apply the rest."
fi
