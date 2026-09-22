pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

// Theme catalogue from `hypr-theme json`, plus the picker's state.
// A theme is any folder in ~/.config/hypr-theme/themes with a colors.toml,
// so anything you or an agent drop there shows up.
Singleton {
    id: root
    property var themes: []
    property string pickerMode: ""      // "" | "theme" | "wallpaper"
    readonly property bool open: pickerMode !== ""

    function refresh() { list.running = true }
    function openPicker(mode) { refresh(); pickerMode = mode }
    function close() { pickerMode = "" }
    function apply(id) { Quickshell.execDetached([Quickshell.env("HOME") + "/.local/bin/hypr-theme", "set", id]); close() }
    function applyWallpaper(path) { Quickshell.execDetached([Quickshell.env("HOME") + "/.local/bin/hypr-wall", "set", path]); close() }

    readonly property var current: themes.find(t => t.current) || null
    readonly property var wallpapers: {
        // the current theme's backgrounds first, then the other themes'
        const cur = current ? current.backgrounds : []
        const rest = []
        for (const t of themes) if (!t.current) for (const b of t.backgrounds) rest.push(b)
        return cur.concat(rest)
    }

    Process {
        id: list
        command: [Quickshell.env("HOME") + "/.local/bin/hypr-theme", "json"]
        stdout: StdioCollector { onStreamFinished: { try { root.themes = JSON.parse(text) } catch (e) { console.warn("Themes: " + e) } } }
    }
    Component.onCompleted: refresh()
    // a theme switch re-renders colors.json (Theme reloads it) → re-read the catalogue
    Connections { target: Theme; function onNameChanged() { root.refresh() } function onModeChanged() { root.refresh() } }

    IpcHandler {
        target: "picker"
        function theme(): void { root.openPicker("theme") }
        function wallpaper(): void { root.openPicker("wallpaper") }
        function close(): void { root.close() }
        function toggle(mode: string): void { if (root.pickerMode === mode) root.close(); else root.openPicker(mode) }
    }
}
