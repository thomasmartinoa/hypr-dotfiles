import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

// CPU, memory and GPU use; click opens btop. The numbers come from
// Services/sysmon.sh (one process per poll); the GPU half only appears when
// a card reports its load — a sleeping laptop dGPU is left alone.
Pill {
    id: sm
    property int cpu: 0
    property int mem: 0
    property int gpu: -1
    property var last: null
    onClicked: Quickshell.execDetached(["kitty", "--class", "btop", "-e", "btop"])
    Process {
        id: rd
        command: ["bash", Quickshell.shellPath("Services/sysmon.sh")]
        stdout: StdioCollector {
            onStreamFinished: {
                let sawGpu = false
                for (const line of text.trim().split("\n")) {
                    const f = line.split(" ")
                    if (f[0] === "cpu") {
                        const idle = +f[1], total = +f[2]
                        if (sm.last) {
                            const dt = total - sm.last.total, di = idle - sm.last.idle
                            if (dt > 0) sm.cpu = Math.round(100 * (1 - di / dt))
                        }
                        sm.last = { total: total, idle: idle }
                    } else if (f[0] === "mem") sm.mem = +f[1]
                    else if (f[0] === "gpu") { sm.gpu = +f[1]; sawGpu = true }
                }
                if (!sawGpu) sm.gpu = -1
            }
        }
    }
    Timer { interval: 3000; running: true; repeat: true; triggeredOnStart: true; onTriggered: rd.running = true }
    readonly property color hot: Theme.hued ? Theme.c.warning : Theme.c.accentBright
    Label { text: "󰍛"; color: sm.cpu > 85 ? sm.hot : Theme.c.accentLight }
    Label { visible: !sm.vertical; text: sm.cpu + "%"; color: Theme.c.accentLight }
    Label { visible: !sm.vertical; text: "󰘚"; color: sm.mem > 85 ? sm.hot : Theme.c.accentLight }
    Label { visible: !sm.vertical; text: sm.mem + "%"; color: Theme.c.accentLight }
    Label { visible: !sm.vertical && sm.gpu >= 0; text: "󰢮"; color: sm.gpu > 85 ? sm.hot : Theme.c.accentLight }
    Label { visible: !sm.vertical && sm.gpu >= 0; text: sm.gpu + "%"; color: Theme.c.accentLight }
}
