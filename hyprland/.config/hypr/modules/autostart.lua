

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("awww-daemon & awww img ~/.config/hypr/wallpapers/montain_main.png")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    --hl.exec_cmd("systemctl --user start hyprpolkitagent")
   -- hl.exec_cmd("xdg-desktop-portal-hyprland")
    hl.exec_cmd("batsignal -b")
    hl.exec_cmd("wl-paste --watch cliphist store")
end)
