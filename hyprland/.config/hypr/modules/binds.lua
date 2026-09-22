---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "kitty"
local fileManager = "thunar"
local menu = "~/.config/rofi/launchers/launcher.sh"
local browser = "zen-browser"

local mainMod = "SUPER"

---------------------
---- KEYBINDINGS ----
---------------------

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close()) 
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("~/.config/hypr/scripts/powermenu.sh"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("~/.config/hypr/scripts/launcher.sh"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) 
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) 
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("~/.config/hypr/scripts/lock.sh"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("~/.config/hypr/scripts/shell.sh restart"))   -- restart bar + notifications
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("qs ipc call bar toggle"))             -- bar skin: pill <-> minimal
hl.bind(mainMod .. " + CTRL + I", hl.dsp.exec_cmd("~/.config/hypr/scripts/caffeine.sh toggle")) -- stay awake toggle
hl.bind(mainMod .. " + CTRL + SHIFT + space", hl.dsp.exec_cmd("hypr-theme-menu theme"))      -- theme picker
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("hypr-theme-menu wallpaper"))               -- wallpaper picker
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("hypr-theme toggle"))                -- dark <-> light
hl.bind(mainMod .. " + CTRL + space", hl.dsp.exec_cmd("hypr-wall next"))                 -- next wallpaper
hl.bind(mainMod .. " + SHIFT + CTRL + A", hl.dsp.exec_cmd("hypr-agent launch"))          -- default coding agent


hl.bind(
	mainMod .. " + Print",
	hl.dsp.exec_cmd(
		[[grim - | tee ~/Pictures/screenshot/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png | wl-copy && notify-send "Screenshot Saved happy alle"]]
	)
)

hl.bind(
	mainMod .. " + X",
	hl.dsp.exec_cmd(
		[[grim -g "$(slurp)" - | tee ~/Pictures/screenshot/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png | wl-copy && notify-send "Screenshot Saved happy alle"]]
	)
)

hl.bind(
	mainMod .. " + SHIFT + Print",
	hl.dsp.exec_cmd(
		[[grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" - | tee ~/Pictures/screenshot/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png | wl-copy && notify-send "Screenshot" "Active window saved and copied"]]
	)
)

hl.bind(
	mainMod .. " + SHIFT + X",
	hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy && notify-send "Screenshot" "Copied to clipboard"]])
)

-- hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Workspaces 1-10, and move-window-to-workspace.
for i = 1, 10 do
	local key = i % 10 -- workspace 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end


hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))


hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))


hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })


hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness.sh up"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness.sh down"),
	{ locked = true, repeating = true }
)

-- Requires playerctl.  (was: bindl = locked only)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }))


hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("~/.config/hypr/scripts/clipboard.sh"))
