import QtQuick
import qs.Commons

// Maps a layout entry (an id from shell.json) to a widget. Unknown ids are
// looked up in shell.json "modules" as command modules.
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
        default:             return Config.moduleDef(widgetId) ? command : null
        }
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
