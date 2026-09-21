import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

// A user module from shell.json "modules": runs `exec` every `interval`
// seconds and shows what it prints — plain text, or waybar-style JSON
// {"text": "...", "tooltip": "...", "class": "active|warning|..."}.
// `onClick` runs on click. Your old waybar scripts work unchanged.
Pill {
    id: cw
    property string moduleId: ""
    readonly property var def: Config.moduleDef(moduleId) || ({})
    property string text: ""
    property string cls: ""
    interactive: !!def.onClick
    visible: text !== ""
    onClicked: if (def.onClick) Quickshell.execDetached(["bash", "-c", def.onClick])
    Process {
        id: p
        command: ["bash", "-c", String(cw.def.exec || "true")]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text.trim()
                try { const j = JSON.parse(t); cw.text = String(j.text || ""); cw.cls = String(j.class || "") }
                catch (e) { cw.text = t; cw.cls = "" }
            }
        }
    }
    Timer { interval: Math.max(1, Number(cw.def.interval) || 30) * 1000; running: true; repeat: true; triggeredOnStart: true; onTriggered: p.running = true }
    Label {
        text: cw.text
        color: cw.cls === "active" ? Theme.c.accentBright : cw.cls === "warning" ? Theme.c.accentMid : cw.cls === "off" || cw.cls === "inactive" ? Theme.c.accentDim : Theme.c.accentLight
    }
}
