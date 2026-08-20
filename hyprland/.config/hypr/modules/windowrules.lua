-- ~/.config/hypr/modules/windowrules.lua
-- Ported 1:1 from modules/windowrules.conf.
--
-- The .conf already used the newer 0.56 `match:namespace X, prop val` form, so
-- this is a small step. The one real change: in hyprlang each property needed
-- its own `layerrule =` line. In Lua one call carries every property for a
-- given match, so the four swaync lines collapse to two.
--
-- `namespace` is a RE2 regex, unanchored. Anchoring with ^...$ is stricter and
-- costs nothing. Check live namespaces with: hyprctl layers


-------------------
---- LAYER RULES --
-------------------

-- SwayNotificationCenter
hl.layer_rule({
    match        = { namespace = "^swaync-control-center$" },
    blur         = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    match        = { namespace = "^swaync-notification-window$" },
    blur         = true,
    ignore_alpha = 0.4,
})

-- Rofi
hl.layer_rule({
    match     = { namespace = "^rofi$" },
    blur      = true,
    animation = "popin 65%",
})


--------------------
---- WINDOW RULES --
--------------------

-- There are currently NO window rules on this system at all (finding HYP-11).
-- Nothing to port. The block below is a suggested starting set — leave it
-- commented until the faithful port is confirmed working, then enable one rule
-- at a time. Rules are evaluated top to bottom and the LAST match wins;
-- named rules are all evaluated before anonymous ones.

-- Stop video players and games from letting the screen lock mid-playback.
-- This is the single most useful rule missing today.
-- hl.window_rule({
--     name  = "idle-inhibit-fullscreen",
--     match = { fullscreen = true },
--     idle_inhibit = "fullscreen",
-- })

-- Ignore maximize requests from all apps.
-- hl.window_rule({
--     name  = "suppress-maximize-events",
--     match = { class = ".*" },
--     suppress_event = "maximize",
-- })

-- Fix XWayland drag artefacts (upstream's recommended rule).
-- hl.window_rule({
--     name  = "fix-xwayland-drags",
--     match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
--     no_focus = true,
-- })

-- Float and centre common dialog-style windows.
-- hl.window_rule({
--     name  = "float-dialogs",
--     match = { class = "^(pavucontrol|nm-connection-editor|blueman-manager|thunar)$" },
--     float  = true,
--     center = true,
--     size   = { 900, 600 },
-- })

-- Full opacity for anything playing video, so inactive_opacity = 0.7 does not
-- dim a film you are watching in the background.
-- hl.window_rule({
--     name  = "opaque-video",
--     match = { content = "video" },
--     opacity = "1.0 override 1.0 override",
-- })
