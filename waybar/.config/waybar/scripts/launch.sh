#!/bin/bash


killall -q waybar &
killall -q swaync &


sleep 0.5


swaync &
waybar &

disown
