#!/usr/bin/env bash
# brightness.sh up|down [step%] — change backlight and show the shell's OSD.
# sysfs gives no change notification, so the OSD is told the new value here.
set -u
dev="intel_backlight"
step="${2:-10}"
case "${1:-}" in
    up)   brightnessctl -q -d "$dev" set "${step}%+" ;;
    down) brightnessctl -q -d "$dev" set "${step}%-" ;;
    *) echo "usage: $0 up|down [step]" >&2; exit 1 ;;
esac
cur=$(brightnessctl -d "$dev" get); max=$(brightnessctl -d "$dev" max)
pct=$(( cur * 100 / max ))
command -v qs >/dev/null 2>&1 && qs ipc call osd brightness "$pct" >/dev/null 2>&1
