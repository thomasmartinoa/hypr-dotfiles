-------------------
---- LAYER RULES --
-------------------

-- SwayNotificationCenter
hl.layer_rule({
	match = { namespace = "^swaync-control-center$" },
	blur = true,
	ignore_alpha = 0.5,
})

hl.layer_rule({
	match = { namespace = "^swaync-notification-window$" },
	blur = true,
	ignore_alpha = 0.4,
})

-- Rofi
hl.layer_rule({
	match = { namespace = "^rofi$" },
	blur = true,
	animation = "popin 65%",
})

--------------------
---- WINDOW RULES --
--------------------

hl.window_rule({
	name = "idle-inhibit-fullscreen",
	match = { fullscreen = true },
	idle_inhibit = "fullscreen",
})