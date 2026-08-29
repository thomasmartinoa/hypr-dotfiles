#!/bin/sh

if pgrep -x wlogout >/dev/null 2>&1; then
    pkill -x wlogout
    exit 0
fi

exec wlogout --buttons-per-row 5 --column-spacing 0 --row-spacing 0
