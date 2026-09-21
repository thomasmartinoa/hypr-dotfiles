#!/usr/bin/env bash
# hypr-theme-root-sync — the one privileged step of a theme switch.
#
# Installed by install.sh as /usr/local/bin/hypr-theme-root-sync (root-owned,
# not a symlink) with a sudoers rule that lets the desktop user run exactly
# this file without a password. hypr-theme calls it after every `set`.
#
# It copies the rendered theme to the two places the user cannot write:
#   /root/.config/…              pkexec GUIs (grub-customizer) run as root and
#                                read root's GTK config, so they need the
#                                same palette + settings.ini or they stay dark.
#   /usr/share/sddm/themes/…     the login screen runs as the sddm user.
#
# It takes no arguments and copies only fixed, known files from the calling
# user's ~/.config/hypr-theme/current/ — nothing user-supplied reaches a path.

set -euo pipefail

user="${SUDO_USER:-}"
[[ -n "$user" && "$user" != root ]] || { echo "run via sudo from a normal user" >&2; exit 1; }
home="$(getent passwd "$user" | cut -d: -f6)"
[[ -d "$home" ]] || { echo "no home for $user" >&2; exit 1; }

cur="$home/.config/hypr-theme/current"
[[ -f "$cur/palette.css" ]] || { echo "no rendered theme at $cur — run: hypr-theme set <name>" >&2; exit 1; }

put() { # put <src> <dst>  (644, root-owned, dirs created)
    [[ -f "$1" ]] || return 0
    install -D -m 644 -- "$1" "$2"
}

# ---- root's GTK config (pkexec apps) ----
put "$cur/palette.css"        /root/.config/hypr-theme/current/palette.css
put "$cur/gtk3-settings.ini"  /root/.config/gtk-3.0/settings.ini
put "$cur/gtk4-settings.ini"  /root/.config/gtk-4.0/settings.ini
put "$cur/gtkrc-2.0"          /root/.gtkrc-2.0
put "$cur/kdeglobals"         /root/.config/kdeglobals
# gtk.css is not generated; it lives in the dotfiles and imports the palette
# by the relative path ../hypr-theme/current/palette.css, which is why the
# palette above goes to that exact spot under /root.
put "$home/.config/gtk-3.0/gtk.css" /root/.config/gtk-3.0/gtk.css
put "$home/.config/gtk-4.0/gtk.css" /root/.config/gtk-4.0/gtk.css

# ---- login screen ----
sddm=/usr/share/sddm/themes/hyprmono
if [[ -d "$sddm" ]]; then
    put "$cur/sddm-theme.conf" "$sddm/theme.conf"
    # current/background is a symlink set by hypr-wall (always a PNG, the
    # theme's theme.conf references background.png).
    if [[ -e "$cur/background" ]]; then
        put "$(readlink -f "$cur/background")" "$sddm/background.png"
    fi
fi

echo "synced theme for root and sddm"
