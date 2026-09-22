import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

// CPU and memory use; click opens btop.
Pill {
    id: sm
    property int cpu: 0
    property int mem: 0
    property var last: null
    onClicked: Quickshell.execDetached(["kitty", "--class", "btop", "-e", "btop"])
    Process {
        id: rd
        command: ["bash", "-c", "head -1 /proc/stat; grep -E '^(MemTotal|MemAvailable)' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                const c = lines[0].split(/\s+/).slice(1).map(Number)
                const idle = c[3] + c[4], total = c.reduce((a, b) => a + b, 0)
                if (sm.last) {
                    const dt = total - sm.last.total, di = idle - sm.last.idle
                    if (dt > 0) sm.cpu = Math.round(100 * (1 - di / dt))
                }
                sm.last = { total: total, idle: idle }
                let tot = 0, avail = 0
                for (const l of lines.slice(1)) {
                    const m = l.match(/^(\w+):\s+(\d+)/)
                    if (!m) continue
                    if (m[1] === "MemTotal") tot = +m[2]; else if (m[1] === "MemAvailable") avail = +m[2]
                }
                if (tot > 0) sm.mem = Math.round(100 * (1 - avail / tot))
            }
        }
    }
    Timer { interval: 3000; running: true; repeat: true; triggeredOnStart: true; onTriggered: rd.running = true }
    readonly property color hot: Theme.hued ? Theme.c.warning : Theme.c.accentBright
    Label { text: "󰍛"; color: sm.cpu > 85 ? sm.hot : Theme.c.accentLight }
    Label { visible: !sm.vertical; text: sm.cpu + "%"; color: Theme.c.accentLight }
    Label { visible: !sm.vertical; text: "󰘚"; color: sm.mem > 85 ? sm.hot : Theme.c.accentLight }
    Label { visible: !sm.vertical; text: sm.mem + "%"; color: Theme.c.accentLight }
}
