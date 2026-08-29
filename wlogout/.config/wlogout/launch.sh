#!/bin/sh
# wlogout launcher — toggles, and pins the grid to a single row.
#
# `-b 5` is not optional: buttons-per-row is a CLI flag, not a config key,
# and wlogout's default of 3 would wrap five buttons into a 3x2 grid with a
# dead sixth cell. style.css margins are measured against the 5-column cell,
# so launching plain `wlogout` will look wrong.

if pgrep -x wlogout >/dev/null 2>&1; then
    pkill -x wlogout
    exit 0
fi

exec wlogout --buttons-per-row 5 --column-spacing 0 --row-spacing 0
