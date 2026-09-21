pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// The rice's palette, live. hypr-theme renders ~/.config/hypr-theme/current/
// colors.json on every switch; this watches it, so every shell surface
// recolours the moment the theme changes. `qs ipc call theme reload` is the
// explicit nudge hypr-theme sends (the file is replaced atomically, which
// can outrun the watcher).
Singleton {
    id: root

    readonly property string file: Quickshell.env("HOME") + "/.config/hypr-theme/current/colors.json"

    property string name: "HyprMono"
    property string mode: "dark"
    readonly property bool light: mode === "light"

    // Bar skin: "pill" (the classic look) or "minimal" (flat, Omarchy-like).
    // A theme sets its preference in colors.toml; `qs ipc call bar style X`
    // overrides it for this session.
    property string themeBarStyle: "pill"
    property string barOverride: ""
    readonly property string barStyle: barOverride !== "" ? barOverride : themeBarStyle

    // Defaults = HyprMono dark, so the shell renders before the file loads.
    property var c: ({
        bg0: "#0a0a0a", bg1: "#141414", bg2: "#1e1e1e", bg3: "#282828", bg4: "#333333",
        fg: "#e8e8e8",
        accentBright: "#ffffff", accentLight: "#e0e0e0", accentMid: "#a0a0a0", accentDim: "#606060",
        active: "#ffffff", hover: "#cccccc", warning: "#b0b0b0", critical: "#808080",
        grey0: "#404040", grey1: "#707070", grey2: "#a0a0a0"
    })

    readonly property string font: "JetBrainsMono Nerd Font Propo"
    // GTK's "12px" in the old waybar css rendered at ~15 logical px; match it.
    readonly property int fontSize: barStyle === "pill" ? 15 : 13

    function parse() {
        try {
            const j = JSON.parse(view.text())
            if (j.colors) root.c = j.colors
            if (j.mode) root.mode = j.mode
            if (j.name) root.name = j.name
            if (j.bar) root.themeBarStyle = j.bar
        } catch (e) {
            console.warn("Theme: could not parse " + root.file + ": " + e)
        }
    }

    FileView {
        id: view
        path: root.file
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.parse()
        onLoadFailed: (err) => console.warn("Theme: " + root.file + " not readable (" + err + "), using defaults")
    }

    IpcHandler {
        target: "theme"
        function reload(): void { view.reload() }
        function current(): string { return root.name + " (" + root.mode + ")" }
    }

    IpcHandler {
        target: "bar"
        function style(name: string): string {
            if (name === "pill" || name === "minimal") root.barOverride = name
            else if (name === "auto" || name === "") root.barOverride = ""
            return root.barStyle
        }
        function toggle(): string {
            root.barOverride = root.barStyle === "pill" ? "minimal" : "pill"
            return root.barStyle
        }
    }
}
