#!/usr/bin/env bash
# launcher.sh — the shell's app launcher, or rofi when the shell is not running.
if command -v qs >/dev/null 2>&1 && pgrep -x qs >/dev/null 2>&1; then
    qs ipc call launcher toggle >/dev/null 2>&1 && exit 0
fi
exec "$HOME/.config/rofi/launchers/launcher.sh"
