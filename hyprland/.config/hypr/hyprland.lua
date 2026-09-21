require("modules/env")
require("modules/autostart")
require("modules/binds")
require("modules/monitors")
require("modules/decorations")
require("modules/windowrules")

-- Theme colours (borders, shadow) rendered by `hypr-theme set <name>`.
-- Loaded last so they override anything in the modules. pcall: a fresh
-- install has no current/ yet, and a missing theme must not break Hyprland.
pcall(dofile, os.getenv("HOME") .. "/.config/hypr-theme/current/hyprland.lua")

-----------------
---- XWAYLAND ---
-----------------

hl.config({
	xwayland = {
		force_zero_scaling = true,
	},
})
---------------
---- INPUT ----
---------------
hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		numlock_by_default = true,

		follow_mouse = 1,

		sensitivity = 0, 

		touchpad = {
			natural_scroll = true,
		},
	},
})


hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })
