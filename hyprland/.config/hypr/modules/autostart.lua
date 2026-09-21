

-- Which bar: "quickshell" (the shell in ~/.config/quickshell) or "waybar"
-- (the classic config, kept as a fallback). scripts/shell.sh reads this.
hl.env("HYPR_SHELL", "quickshell")

hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/hypr/scripts/shell.sh start")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    --hl.exec_cmd("systemctl --user start hyprpolkitagent")
   -- hl.exec_cmd("xdg-desktop-portal-hyprland")
    hl.exec_cmd("batsignal -b")
    hl.exec_cmd("wl-paste --watch cliphist store")
end)
