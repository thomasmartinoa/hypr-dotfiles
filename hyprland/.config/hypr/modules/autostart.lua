-- ~/.config/hypr/modules/autostart.lua
-- Ported 1:1 from modules/autostart.conf.
--
-- `exec-once` no longer exists. Autostart is an event subscription on
-- "hyprland.start". hl.exec_cmd() spawns asynchronously — no `&` or `disown`
-- needed, and the callback returns immediately.

hl.on("hyprland.start", function()
    -- Was: exec-once = waybar & hyprpaper
    -- hyprpaper is NOT installed on this machine (finding HYP-03), so the
    -- second half of that line has always failed silently. The wallpaper is
    -- painted by awww-daemon below. Ported faithfully; see the note underneath.
    hl.exec_cmd("waybar")

    hl.exec_cmd("awww-daemon & awww img ~/hypr-dotfiles/wallpaper/montain_main.png")
   -- hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    --hl.exec_cmd("systemctl --user start hyprpolkitagent")
   -- hl.exec_cmd("xdg-desktop-portal-hyprland")   -- see HYP-02: normally dbus-activated
    hl.exec_cmd("batsignal -b")
    hl.exec_cmd("wl-paste --watch cliphist store")
end)

-- RECOMMENDED once you have confirmed the faithful port boots:
-- replace the first line above with just
--     hl.exec_cmd("waybar")
-- Because hl.exec_cmd is already async, `waybar & hyprpaper` gains nothing
-- and only invokes a binary that does not exist.
