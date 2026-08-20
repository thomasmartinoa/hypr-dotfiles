-- ~/.config/hypr/modules/decorations.lua
-- Ported 1:1 from modules/decorations.conf.
--
-- Blocks become nested Lua tables inside hl.config({...}). You may call
-- hl.config() as many times as you like; each call merges into what is
-- already set.


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 7,

        border_size = 1,

        -- `col.active_border` becomes a nested `col = { active_border = ... }`.
        -- A single colour is a plain string. A gradient would be
        --   { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 }
        col = {
            active_border   = "rgba(ffffffaa)",
            inactive_border = "rgba(595959aa)",
        },

        resize_on_border = false,
        allow_tearing    = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 4,
        rounding_power = 4,

        -- CAREFUL. The .conf declared active_opacity/inactive_opacity TWICE:
        -- 1.0/1.0 near the top, then 0.7/0.9 twenty lines further down. Last
        -- one wins, so the values actually running are the ones below —
        -- verified live with `hyprctl getoption decoration:active_opacity`
        -- => 0.900000 and decoration:inactive_opacity => 0.700000.
        -- That is finding HYP-06. Only one pair survives here.
        active_opacity   = 0.9,
        inactive_opacity = 0.7,
        dim_inactive     = false,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled           = true,
            size              = 6,
            passes            = 4,
            ignore_opacity    = true,
            new_optimizations = true,
            vibrancy          = 0.1696,
            -- xray           = false,
        },
    },

    -- `enabled = yes, please :)` was a hyprlang joke that parsed as a boolean.
    -- Lua wants a real boolean.
    animations = {
        enabled = true,
    },
})


-------------------
---- ANIMATION ----
-------------------

-- `bezier = NAME, x0, y0, x1, y1` splits into hl.curve() with a points table.
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1} } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1} } })

-- `animation = NAME, ONOFF, SPEED, CURVE, [STYLE]` becomes named fields.
-- The animation name is `leaf`; the curve goes in `bezier` (or `spring`).
hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })

-- Springs are first-class in the Lua API and were not available before. If you
-- ever want the newer upstream feel for window motion:
--   hl.curve("easy", { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })
--   hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })


-------------------------
---- WORKSPACE RULES ----
-------------------------

-- "Smart gaps" / "no gaps when only" — was commented out in the .conf, kept
-- commented here. `workspace = w[tv1], gapsout:0` becomes:
--
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({ name = "no-gaps-wtv1", match = { float = false, workspace = "w[tv1]" }, border_size = 0, rounding = 0 })
-- hl.window_rule({ name = "no-gaps-f1",   match = { float = false, workspace = "f[1]"   }, border_size = 0, rounding = 0 })


-----------------
---- LAYOUTS ----
-----------------

hl.config({
    dwindle = {
        -- `pseudotile = true` was removed in 0.55. Pseudotile is per-window
        -- now, toggled by SUPER+P in binds.lua.
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
    },
})
