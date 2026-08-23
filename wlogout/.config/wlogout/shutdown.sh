#!/bin/sh

# Reset the shader to the default shader
echo "$HOME/.config/hypr/shaders/default-shader.frag" > "$HOME/.desktop-environment/shader.info"

# Shutdown
systemctl poweroff
