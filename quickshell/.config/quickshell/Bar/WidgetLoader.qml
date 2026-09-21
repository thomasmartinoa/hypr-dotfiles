import QtQuick
import Quickshell
import qs.Commons

// Maps a layout entry (an id from shell.json) to a widget. Unknown ids are
// looked up in shell.json "modules": a "qml" file (plugin widget) or an
// "exec" command module.
Loader {
    id: loader
    property string widgetId: ""
    sourceComponent: {
        switch (widgetId) {
        case "clock":        return clock
        case "workspaces":   return workspaces
        case "tray":         return tray
        case "audio":        return audio
        case "network":      return network
        case "battery":      return battery
        case "bluetooth":    return bluetooth
        case "caffeine":     return caffeine
        case "bell":         return bell
        case "activewindow": return activewindow
        case "media":        return media
        case "sysmon":       return sysmon
        case "keyboard":     return keyboard
        case "spacer":       return spacer
        default: {
            const d = Config.moduleDef(widgetId)
            if (!d) return null
            return d.qml ? null : command
        }
        }
    }
    // a "qml" module points at a file with any Item as its root (a Pill works well)
    source: {
        const d = Config.moduleDef(widgetId)
        if (!d || !d.qml) return ""
        return "file://" + String(d.qml).replace(/^~/, Quickshell.env("HOME"))
    }
    Component { id: clock;        Clock {} }
    Component { id: workspaces;   Workspaces {} }
    Component { id: tray;         Tray {} }
    Component { id: audio;        Audio {} }
    Component { id: network;      Network {} }
    Component { id: battery;      Battery {} }
    Component { id: bluetooth;    Bluetooth {} }
    Component { id: caffeine;     CaffeineWidget {} }
    Component { id: bell;         Bell {} }
    Component { id: activewindow; ActiveWindow {} }
    Component { id: media;        Media {} }
    Component { id: sysmon;       SysMon {} }
    Component { id: keyboard;     KeyboardLayout {} }
    Component { id: spacer;       Item { width: 12; height: 12 } }
    Component { id: command;      CommandWidget { moduleId: loader.widgetId } }
}
