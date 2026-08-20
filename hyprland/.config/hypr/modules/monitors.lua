-- ~/.config/hypr/modules/monitors.lua
-- Ported 1:1 from modules/monitors.conf.
--
-- Was: monitor=,2560x1440@165.00,auto,1.60
--
-- The five comma-separated fields become named keys. An empty `output` is the
-- catch-all rule that applies to every monitor.

hl.monitor({
    output   = "",
    mode     = "2560x1440@165.00",
    position = "auto",
    scale    = 1.60,
})


-- RECOMMENDED, once the faithful port boots.
--
-- The catch-all above tries to force 2560x1440@165 onto ANY monitor that gets
-- plugged in, including an external one that cannot do that mode. Hyprland
-- falls back gracefully, but naming the panel is more honest and leaves the
-- external path free:
--
-- hl.monitor({ output = "eDP-1", mode = "2560x1440@165.00", position = "0x0",  scale = 1.60 })
-- hl.monitor({ output = "",      mode = "preferred",        position = "auto", scale = "auto" })
--
-- `hyprctl monitors all` lists every connected and disconnected output.
