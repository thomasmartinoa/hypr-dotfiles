-- ~/.config/hypr/hyprland.lua
-- Entry point. Ported 1:1 from hyprland.conf (Hyprland 0.56.2, 2026-08-17).
--
-- Load order is identical to the old `source =` order. Each require() runs in
-- its own Lua scope, so a runtime error in one module does NOT kill the others.
require("modules/env")
require("modules/autostart")
require("modules/binds")
require("modules/monitors")
require("modules/decorations")
require("modules/windowrules")

-----------------
---- XWAYLAND ---
-----------------

-- Render X11 apps at native pixel resolution instead of upscaling a 1x bitmap.
-- Paired with GDK_SCALE / XCURSOR_SIZE in modules/env.lua.
hl.config({
	xwayland = {
		force_zero_scaling = true,
	},
})

--------------------
---- PERMISSIONS ---
--------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Permission changes require a Hyprland restart; they are not applied on the fly.
--
-- NOTE: the shipped /usr/share/hypr/hyprland.lua still shows the old positional
-- form `hl.permission("...", "screencopy", "allow")`. The wiki documents the
-- table form below. Use the table form.
--
-- hl.config({ ecosystem = { enforce_permissions = true } })
--
-- hl.permission({ binary = "/usr/(bin|local/bin)/grim",                        type = "screencopy", mode = "allow" })
-- hl.permission({ binary = "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" })
-- hl.permission({ binary = "/usr/(bin|local/bin)/hyprpm",                      type = "plugin",     mode = "allow" })

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

		sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

		touchpad = {
			natural_scroll = true,
		},
	},
})

-- 3-finger horizontal swipe switches workspaces.
-- (Replaces the old `gesture = 3, horizontal, workspace`.)
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- The old config carried the upstream example's per-device block for a device
-- called "epic-mouse-v1", which does not exist on archnitro. Left commented.
-- Check real device names with: hyprctl devices
--
-- hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })
