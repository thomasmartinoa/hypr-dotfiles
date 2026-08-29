require("modules/env")
require("modules/autostart")
require("modules/binds")
require("modules/monitors")
require("modules/decorations")
require("modules/windowrules")

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
