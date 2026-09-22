pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Shell settings — ~/.config/hypr-theme/shell.json. Written by the bar's
// gestures (drag to an edge, double-click for transparency), by
// `qs ipc call bar ...`, or by hand; watched, so hand edits apply live.
// Anything missing from the file falls back to the defaults below.
Singleton {
    id: root
    readonly property string file: Quickshell.env("HOME") + "/.config/hypr-theme/shell.json"

    readonly property var defaults: ({
        version: 1,
        bar: {
            position: "top",                 // top | bottom | left | right
            transparent: false,              // minimal skin only
            skin: "",                        // pill | minimal | "" = the theme's choice
            hidden: false,                   // Menu › Toggle › Bar
            battery: true,                   // show the percentage next to the battery glyph
            layout: {
                // the classic bar, exactly as waybar had it
                pill: {
                    left:   ["clock", "workspaces"],
                    center: ["tray"],
                    right:  ["agents", "audio", "network", "battery", "caffeine", "bell"]
                },
                // Omarchy-style bar
                minimal: {
                    left:   ["workspaces", "activewindow"],
                    center: ["media", "clock"],
                    right:  ["tray", "spacer", "sysmon", "spacer", "agents", "spacer", "nightlight", "bluetooth", "audio", "network", "battery", "caffeine", "bell"]
                }
            },
            // user modules referenced by id from a layout:
            //   "vpn":   { "exec": "~/bin/vpn-status", "interval": 5, "onClick": "nm-connection-editor" }
            //            (prints text or waybar JSON: {"text":"󰌆","class":"active"})
            //   "agent": { "qml": "~/.config/hypr-theme/plugins/agent.qml" }   (any QML Item; import qs.Bar for Pill)
            modules: {}
        },
        // apparent text size in px (hypr-text-size); every size in the shell
        // is derived from it through Theme.fs()
        font: { size: 12, family: "" },   // "" = the rice's own font
        // coding agents (hypr-agent): which one SUPER+SHIFT+CTRL+A and the bar launch
        agents: { default: "" }
    })

    property var data: JSON.parse(JSON.stringify(defaults))
    readonly property var bar: data.bar
    readonly property string position: (bar && bar.position) || "top"
    readonly property bool vertical: position === "left" || position === "right"
    readonly property bool transparent: !!(bar && bar.transparent)
    readonly property bool hidden: !!(bar && bar.hidden)
    readonly property int fontSize: (data.font && data.font.size >= 8 && data.font.size <= 24) ? data.font.size : 12
    readonly property string fontFamily: (data.font && data.font.family) ? data.font.family : ""
    readonly property string skin: (bar && (bar.skin === "pill" || bar.skin === "minimal")) ? bar.skin : ""
    readonly property bool batteryPercent: !(bar && bar.battery === false)

    function layoutFor(style, section) {
        const l = bar && bar.layout && bar.layout[style]
        const d = defaults.bar.layout[style]
        return (l && l[section]) || (d && d[section]) || []
    }
    function moduleDef(id) { return (bar && bar.modules && bar.modules[id]) || null }

    function merge(base, over) {
        if (typeof over !== "object" || over === null || Array.isArray(over)) return over === undefined ? base : over
        const out = JSON.parse(JSON.stringify(base))
        for (const k in over) out[k] = (k in out) ? merge(out[k], over[k]) : over[k]
        return out
    }
    function parse() {
        try {
            const j = JSON.parse(view.text())
            data = merge(defaults, j)
        } catch (e) {
            console.warn("Config: " + file + ": " + e + " — using defaults")
            data = JSON.parse(JSON.stringify(defaults))
        }
    }
    function save() {
        view.setText(JSON.stringify(data, null, 2) + "\n")
    }
    function set(path, value) {       // set("bar.position", "left")
        const keys = path.split(".")
        let o = data
        for (let i = 0; i < keys.length - 1; i++) { if (typeof o[keys[i]] !== "object" || o[keys[i]] === null) o[keys[i]] = {}; o = o[keys[i]] }
        o[keys[keys.length - 1]] = value
        data = JSON.parse(JSON.stringify(data))   // rebind
        save()
    }
    function setPosition(p) { if (["top", "bottom", "left", "right"].indexOf(p) !== -1) set("bar.position", p) }
    function toggleTransparent() { set("bar.transparent", !transparent) }

    FileView {
        id: view
        path: root.file
        watchChanges: true
        blockWrites: false
        onFileChanged: reload()
        onLoaded: root.parse()
        onLoadFailed: (err) => { /* no file yet: defaults, and write them so the user has something to edit */ root.save() }
    }
}
