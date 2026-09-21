pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Subscribes to swaync (`swaync-client -swb` streams one JSON line per
// state change) — the same feed waybar's bell used. Goes away in the
// notifications phase when the shell owns notifications itself.
Singleton {
    id: root
    property int count: 0
    property bool dnd: false
    property bool inhibited: false
    property bool cc: false
    readonly property bool running: sub.running

    function toggle()    { Quickshell.execDetached(["swaync-client", "-t", "-sw"]) }
    function toggleDnd() { Quickshell.execDetached(["swaync-client", "-d", "-sw"]) }

    Process {
        id: sub
        command: ["swaync-client", "-swb"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                try {
                    const j = JSON.parse(line)
                    const alt = String(j.alt || "")
                    root.count = parseInt(j.text || "0") || 0
                    root.dnd = alt.indexOf("dnd") !== -1
                    root.inhibited = alt.indexOf("inhibited") !== -1
                    root.cc = String(j.class || "").indexOf("cc-open") !== -1
                } catch (e) {}
            }
        }
        // swaync restarts on theme switch; resubscribe.
        onExited: restart.start()
    }
    Timer { id: restart; interval: 1500; onTriggered: sub.running = true }
}
