-- Minimal Hyprland config for the SDDM Wayland greeter (Omarchy does the
-- same). SDDM starts the greeter itself once the compositor is up, so this
-- only has to make one fullscreen window look right. Installed to
-- /usr/share/sddm/hyprland.lua by install.sh.

hl.config({
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		force_default_wallpaper = 0,
	},

	-- The greeter is the only window; no gaps, no border.
	general = {
		gaps_in = 0,
		gaps_out = 0,
		border_size = 0,
	},

	decoration = {
		rounding = 0,
		blur = { enabled = false },
		shadow = { enabled = false },
	},

	animations = {
		enabled = false,
	},

	input = {
		kb_layout = "us",
		numlock_by_default = true,
	},
})

hl.env("XCURSOR_SIZE", "24")
