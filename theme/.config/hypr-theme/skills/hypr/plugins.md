# The shell — bar, widgets, panels, overlays, plugins

One Quickshell process (`~/.config/hypr/scripts/shell.sh start|restart`),
config at `~/.config/quickshell` = repo `quickshell/.config/quickshell`.

```
shell.qml                 mounts everything: WallpaperWindow Bar OsdWindow NotificationPopups
                          LockScreen PowerMenu ImagePicker Launcher Clipboard
Commons/Theme.qml         colours from current/colors.json: Theme.c.bg0..bg4, fg, accentBright,
                          accentLight, accentMid, accentDim, border, borderStrong;
                          Theme.radius (4), radiusSm, font, fontSize, light, barStyle, alpha(col, a)
Commons/Config.qml        shell.json: Config.position/vertical/transparent, layoutFor(), moduleDef(),
                          set("a.b", v) — writes the file, everything rebinds
Services/*.qml            singletons (pragma Singleton) with IpcHandler: Notifs, Panels, Themes,
                          Wallpaper, Lock, Idle, Caffeine, Osd, Apps, Clip, Agents
Bar/Bar.qml               per-screen PanelWindow, gestures (drag to edge, double-click transparent)
Bar/Pill.qml              the module container: pill skin (bordered) / minimal skin (flat)
Bar/WidgetLoader.qml      id → widget map (add new built-in widgets here)
Bar/<Widget>.qml          Clock Workspaces Tray Audio Network Bluetooth Battery Caffeine Bell
                          ActiveWindow Media SysMon KeyboardLayout Agents CommandWidget Label
Panels/Panel.qml          popup under a widget; PanelHeader PanelRow PanelButton Slider Toggle
Panels/<X>Panel.qml       Audio Network Bluetooth Power Calendar Agents
Launcher/ Clipboard/ Picker/ Lock/ Power/ Notifications/ Osd/ Wallpaper/   overlays
```

## Bar layout — no code

`~/.config/hypr-theme/shell.json` → `bar.layout.<pill|minimal>.<left|center|right>` are
lists of widget ids; hot-reloads. Built-ins: `clock workspaces tray audio network
bluetooth battery caffeine bell activewindow media sysmon keyboard agents spacer`.
Anything else is looked up in `bar.modules`:

```json
"modules": {
  "vpn":   { "exec": "~/bin/vpn-status", "interval": 5, "onClick": "nm-connection-editor" },
  "moon":  { "qml": "~/.config/hypr-theme/plugins/moon.qml" }
}
```

`exec` prints text or waybar JSON `{"text":"󰌆","class":"active","tooltip":"…"}` —
old waybar scripts work unchanged. `qml` is any Item; the file is loaded from
outside the repo (user plugin dir `theme/.config/hypr-theme/plugins/`, stowed).

## Write a widget (plugin file or built-in)

Minimal plugin, `~/.config/hypr-theme/plugins/hello.qml`:

```qml
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons        // Theme, Config
import qs.Bar            // Pill, Label
import qs.Services       // Panels, Notifs, …
import qs.Panels         // Panel, PanelHeader, PanelRow, PanelButton

Pill {
    id: w
    property string value: ""
    Process { id: p; command: ["sh", "-c", "cat /sys/class/power_supply/BAT1/power_now"]
              running: true
              stdout: StdioCollector { onStreamFinished: w.value = (parseInt(text) / 1e6).toFixed(1) + " W" } }
    Timer { interval: 5000; running: true; repeat: true; onTriggered: p.running = true }
    onClicked: Panels.toggle("hello", w)          // a panel, or Quickshell.execDetached([...])
    Label { text: "󱐋"; color: Theme.c.accentLight }
    Label { visible: w.pillMode && !w.vertical; text: w.value; color: Theme.c.fg }
    Panel { name: "hello"; anchorItem: w
            PanelHeader { title: "Power draw" }
            PanelRow { icon: "󱐋"; title: w.value; subtitle: "battery discharge" } }
}
```

Rules of the house:
- **Pill**: put `Label`s (or small Items) inside; it handles padding, both skins,
  vertical bars, hover, `clicked/rightClicked/middleClicked/scrolled`. Hide text
  in the minimal/vertical bar with `visible: pillMode && !vertical` like the
  built-ins. Never hardcode colours — `Theme.c.*`; sizes come from the skin.
- **Glyphs** are Nerd Font (JetBrainsMono Nerd Font Propo). Private-use glyphs
  vanish in shell heredocs: write them as `"\u{f0a7a}"` escapes in QML, or edit
  with the Edit tool.
- **Panels** open via `Panels.toggle(name, anchor)`; one open at a time; they
  register for `qs ipc call panels open <name>`.
- **Services** (state, IPC, timers, processes) belong in `Services/<Name>.qml`
  (`pragma Singleton`, add `singleton Name 1.0 Name.qml` to `Services/qmldir`).
  Built-in widgets go in `Bar/` + `Bar/qmldir` + a `case` in `WidgetLoader.qml`
  + the default layouts in `Commons/Config.qml` (and README's widget list).
- **Overlays** (fullscreen things like launcher/picker) are a `Variants { model:
  Quickshell.screens; PanelWindow { WlrLayershell.layer: Overlay; keyboardFocus:
  Exclusive when open; namespace: "hypr-<name>" } }`; give the namespace a
  blur `hl.layer_rule` in `modules/windowrules.lua` like the others.
- **Config**: read `Config.data.<yours>`; defaults in `Config.defaults`; write with
  `Config.set("path", value)`. Never write shell.json from a script while the
  shell also writes it, except with `jq` on the whole file (hypr-agent does).

QML pitfalls learned here (don't relearn them):
`id` is reserved (use `widgetId`); `var` arrays come back as copies — update by
id and reassign; `Theme.c.x` are strings, use `Theme.alpha()` for translucency;
`Grid` pads implicit size for declared rows/columns; flipping `anchors` at
runtime overrides size bindings — position with x/y; `Loader` pins the first
size; `Screen.devicePixelRatio` rounds fractional scale — use
`Hyprland.monitorFor(screen).scale`; `Hyprland.activeToplevel` is null until a
focus event; "Cannot override FINAL property" after an edit is stale hot-reload
cache → `shell.sh restart`.

## Apply and verify

Save → hot-reload; check `qs log` for `WARN`/`ERROR` mentioning your file.
New files, qmldir edits or persistent weirdness → `shell.sh restart` (wait ~3 s).
Then screenshot the bar in **both skins** (`qs ipc call bar toggle`) and both
themes, and the panel open (`qs ipc call panels open <name>`) — verify.md.

## The menu (SUPER+SPACE)

`~/.config/hypr-theme/menu.jsonc` defines the tree (the header documents every
field); `menu.local.jsonc` next to it overlays by id and is hot-reloaded, so a
new entry for something you built is one line:

```jsonc
{ "toggle.vpn": {"icon":"󰌆","label":"VPN","checked":"vpn","action":"~/bin/vpn toggle","keep":true} }
```

`checked`/`value`/`when` read state keys from the shell (`theme light bar.*
caffeine dnd laptop widget.<id>`) or from `hypr-menu-data` (`state()` in
`theme/.local/bin/hypr-menu-data`; add a key there for a new toggle). Dynamic
row lists are `provider`s in the same script. `qs ipc call menu run <id>`
runs an entry from a keybind; `menu open <id>` opens a section. Rendering is
`Services/Menu.qml` + `Menu/MenuWindow.qml`. Long-running or interactive
actions go through `hypr-float <cmd>` (floating terminal); config edits through
`hypr-edit <file>` (validates Hyprland Lua on close).
