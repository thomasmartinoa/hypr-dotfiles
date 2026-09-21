#!/usr/bin/env bash
# caffeine.sh — keep the machine awake until you say otherwise.
#
# Holds a systemd-logind inhibitor for BOTH idle and sleep:
#   idle  -> hypridle treats the session as active, so none of its listeners
#            fire (no dim, no lock, no screen-off, no suspend)
#   sleep -> logind refuses to suspend from any source (lid, wlogout, etc.)
#
# Usage: caffeine.sh [toggle|on|off|status]
#   status prints JSON for the waybar custom/caffeine module.
#
# Same idea as Omarchy's stay-awake toggle, but using logind instead of
# killing hypridle, so the brightness/keyboard listeners keep working.

WHO="caffeine"
SIGNAL=9   # waybar "signal": 9  ->  pkill -RTMIN+9 waybar

inhibit_pid() {
    pgrep -f -- "^systemd-inhibit .*--who=$WHO( |$)" | head -n1
}

is_on() {
    [[ -n "$(inhibit_pid)" ]]
}

refresh_bar() {
    pkill -RTMIN+"$SIGNAL" waybar 2>/dev/null
}

turn_on() {
    is_on && return
    # setsid: own session so it survives the caller (waybar/hyprland bind)
    # and so we can kill the whole group later.
    setsid -f systemd-inhibit \
        --what=idle:sleep \
        --who="$WHO" \
        --why="User asked to stay awake" \
        --mode=block \
        sleep infinity >/dev/null 2>&1
    notify-send -a caffeine "Caffeine on" "Idle lock and suspend paused" 2>/dev/null
}

turn_off() {
    local pid
    pid="$(inhibit_pid)"
    [[ -n "$pid" ]] || return
    kill -- "-$pid" 2>/dev/null || kill "$pid" 2>/dev/null
    notify-send -a caffeine "Caffeine off" "Idle lock and suspend back to normal" 2>/dev/null
}

status() {
    if is_on; then
        printf '{"text":"󰅶","class":"on","tooltip":"Caffeine: ON — idle lock & suspend paused\\nclick to allow idle"}\n'
    else
        printf '{"text":"󰾪","class":"off","tooltip":"Caffeine: off — idling normally\\nclick to stay awake"}\n'
    fi
}

case "${1:-toggle}" in
    toggle) if is_on; then turn_off; else turn_on; fi; refresh_bar ;;
    on)     turn_on;  refresh_bar ;;
    off)    turn_off; refresh_bar ;;
    status) status ;;
    *) echo "usage: $0 [toggle|on|off|status]" >&2; exit 1 ;;
esac
