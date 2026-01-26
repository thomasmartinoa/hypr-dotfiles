#!/bin/bash

# Kill existing waybar instances
killall -q waybar &
killall -q swaync &

# Wait for processes to shut down
sleep 0.5

# Launch waybar
swaync &
waybar &

disown
