#!/usr/bin/env bash
# clipboard.sh — the shell's clipboard history, or the rofi menu without it.
if command -v qs >/dev/null 2>&1 && pgrep -x qs >/dev/null 2>&1; then
    qs ipc call clipboard toggle >/dev/null 2>&1 && exit 0
fi
exec "$HOME/.config/rofi/scripts/clipboard.sh"
