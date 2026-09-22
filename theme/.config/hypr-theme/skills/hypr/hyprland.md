# Hyprland — keybindings, rules, monitors, look, autostart, idle

Hyprland is configured in **Lua** (`hyprland.lua` requires `modules/*`, then
the theme's generated `current/hyprland.lua` last — borders/shadow colours
live there, never in the modules). Classic `.conf` syntax is rejected.

```
modules/env.lua          hl.env(...), PATH prepend ~/.local/bin, Qt/GTK env
modules/autostart.lua    hl.exec_cmd(...) at login: shell.sh start, polkit agent, cliphist watch
modules/binds.lua        hl.bind("SUPER + X", hl.dsp.exec_cmd("cmd")) — one line per key, comment says what
modules/monitors.lua     hl.monitor({...})
modules/decorations.lua  hl.config({ general = {...}, decoration = {...}, animations = {...}, input = {...} })
modules/windowrules.lua  hl.window_rule({ match = {...}, ... }), hl.layer_rule({ match = { namespace = "^hypr-x$" }, blur = true, ignore_alpha = 0.5 })
```

There is no `hyprctl keyword` with the Lua parser ("keyword can't work with
non-legacy parsers"): a live, temporary change is `hyprctl eval 'hl.config({
general = { gaps_in = 0 } })'` and `hyprctl reload` restores the config
(`hypr-toggle gaps|opacity` does exactly this).

After **every** change: `hyprctl reload && hyprctl configerrors` — it must
print nothing. A Lua error leaves Hyprland on the previous config, so the
change silently does not apply; `configerrors` is the only way to know.

## Keybindings

`hyprctl binds -j` shows what is bound now (exec binds show the command in
`arg` only for string commands). Before adding a key, grep `binds.lua` and
tell the user if it replaces something. Form:

```lua
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("notify-send hi"))   -- what it does
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
```

Dispatchers are `hl.dsp.*` (Lua form) — the shell also uses them through
`Hyprland.dispatch("hl.dsp.focus({ workspace = 2 })")` when `Hyprland.usingLua`.
For exotic ones check the Hyprland Lua docs at wiki.hypr.land (syntax changes
between versions — fetch, don't recall). Keep the README keybind table in sync.

## Window / layer rules

`hl.window_rule({ match = { class = "^thunar$" }, float = true, size = { 1000, 700 } })`
— field names follow the current wiki (Window-Rules page); fetch it first.
Layer rules blur the shell's overlays by namespace; a new overlay gets one
(see windowrules.lua for the alpha values that match the old tools).

## Monitors and scale

`hl.monitor({ output = "eDP-1", mode = "2560x1440@165", position = "0x0", scale = 1.6 })`
— `hyprctl monitors all` lists outputs/modes. Fractional scale is why the shell
uses `Hyprland.monitorFor(screen).scale` instead of `devicePixelRatio`.

## Look

`decorations.lua`: gaps 5/7, border 1, rounding 4, active/inactive opacity
0.9/0.7, shadow, blur, animations. Colours are NOT here (theme). Keep the
4px rounding and 1px border: it is the rice's signature across every surface.

## Autostart, idle, lock

The shell starts from `autostart.lua` (`HYPR_SHELL=quickshell`). Idle
timers live in `Services/Idle.qml` (dim/lock/dpms/suspend seconds); caffeine
pauses them (`caffeine.sh toggle`, `qs ipc call caffeine toggle`). Lock is
the shell's `WlSessionLock` (PAM "hyprlock"); `hypridle.conf` only bridges
logind (`loginctl lock-session`, before-sleep) to `lock.sh`. Do not add a
second locker or idle daemon.
