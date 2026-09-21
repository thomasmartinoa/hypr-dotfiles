#!/usr/bin/env bash
# powermenu.sh — the shell's power menu, or wlogout as the fallback.
if command -v qs >/dev/null 2>&1 && pgrep -x qs >/dev/null 2>&1; then
    qs ipc call powermenu toggle >/dev/null 2>&1 && exit 0
fi
exec "$HOME/.config/wlogout/launch.sh"
