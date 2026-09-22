#!/usr/bin/env bash
# brightness.sh up|down [step%]   change the screen backlight and show the shell's OSD
# brightness.sh dim|restore       idle dimming (saves, then restores the level)
# brightness.sh kbd-off|kbd-restore   keyboard backlight, if there is one
#
# Devices are detected, not hardcoded: the first backlight that is not the
# NVIDIA stub (it reports a constant 100%), and any *kbd_backlight LED.
set -u
dev="$(brightnessctl -l -m -c backlight 2>/dev/null | cut -d, -f1 | grep -v -i nvidia | head -n1)"
[[ -n "$dev" ]] || dev="$(brightnessctl -l -m -c backlight 2>/dev/null | cut -d, -f1 | head -n1)"
kbd="$(brightnessctl -l -m -c leds 2>/dev/null | cut -d, -f1 | grep kbd_backlight | head -n1)"
step="${2:-10}"
case "${1:-}" in
    up|down)
        [[ -n "$dev" ]] || exit 0
        [[ $1 == up ]] && brightnessctl -q -d "$dev" set "${step}%+" || brightnessctl -q -d "$dev" set "${step}%-"
        cur=$(brightnessctl -d "$dev" get); max=$(brightnessctl -d "$dev" max)
        command -v qs >/dev/null 2>&1 && qs ipc call osd brightness "$(( cur * 100 / max ))" >/dev/null 2>&1 ;;
    dim)         [[ -n "$dev" ]] && brightnessctl -q -d "$dev" -s set 10% ;;
    restore)     [[ -n "$dev" ]] && brightnessctl -q -d "$dev" -r ;;
    kbd-off)     [[ -n "$kbd" ]] && brightnessctl -q -d "$kbd" -s set 0 ;;
    kbd-restore) [[ -n "$kbd" ]] && brightnessctl -q -d "$kbd" -r ;;
    *) echo "usage: $0 up|down [step] | dim|restore | kbd-off|kbd-restore" >&2; exit 1 ;;
esac
exit 0
