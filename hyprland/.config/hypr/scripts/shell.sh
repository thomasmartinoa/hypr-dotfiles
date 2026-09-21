#!/usr/bin/env bash
# shell.sh — start or restart the desktop shell (bar + notifications).
#
#   shell.sh start      at session start (autostart.lua)
#   shell.sh restart    SUPER+R, and after a theme switch
#
# HYPR_SHELL picks the bar: "quickshell" (default) or "waybar" (the classic
# config kept as a fallback). Set it in modules/autostart.lua.
set -u
which="${HYPR_SHELL:-quickshell}"

stop() {
    pkill -x qs 2>/dev/null
    pkill -x waybar 2>/dev/null
    pkill -x swaync 2>/dev/null
}

start() {
    setsid -f swaync >/dev/null 2>&1
    case "$which" in
        waybar) setsid -f waybar >/dev/null 2>&1 ;;
        *)      setsid -f qs >/dev/null 2>&1 ;;
    esac
}

case "${1:-start}" in
    start)   start ;;
    restart) stop; sleep 0.4; start ;;
    stop)    stop ;;
    *) echo "usage: $0 start|restart|stop" >&2; exit 1 ;;
esac
