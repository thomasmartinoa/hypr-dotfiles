import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Commons

// Active keyboard layout (short code). Follows Hyprland's activelayout
// event; click switches to the next layout on the main keyboard.
Pill {
    id: kb
    property string layout: ""
    function short(name) {
        const m = { "English (US)": "US", "English (UK)": "UK", "German": "DE", "French": "FR", "Russian": "RU", "Spanish": "ES" }
        return m[name] || name.split(" ")[0].substring(0, 3).toUpperCase()
    }
    Connections {
        target: Hyprland
        function onRawEvent(ev) { if (ev.name === "activelayout") { const p = ev.data.split(","); kb.layout = kb.short(p[p.length - 1]) } }
    }
    Process {
        id: rd
        command: ["bash", "-c", "hyprctl devices -j | jq -r '[.keyboards[] | select(.main)][0].active_keymap // \"\"'"]
        stdout: StdioCollector { onStreamFinished: { const t = text.trim(); if (t) kb.layout = kb.short(t) } }
        Component.onCompleted: running = true
    }
    onClicked: Quickshell.execDetached(["bash", "-c", "hyprctl switchxkblayout $(hyprctl devices -j | jq -r '[.keyboards[] | select(.main)][0].name') next"])
    Label { text: "󰌌"; color: Theme.c.accentLight }
    Label { visible: !kb.vertical && kb.layout !== ""; text: kb.layout; color: Theme.c.accentLight }
}
