import QtQuick
import Quickshell.Io
import Quickshell.Hyprland
import qs.Commons

// Focused window title (minimal skin); hidden on a vertical bar.
//
// Hyprland's `activewindow` event is the truth here: it fires with an empty
// payload when focus leaves every window — switching to an empty workspace,
// closing the last one. The toplevel list keeps its stale `activated` flag in
// that case, and `Hyprland.activeToplevel` is null only until the first focus
// event, which is why the title used to linger. hyprctl is the fallback for
// the state before any event arrives.
Pill {
    id: aw
    interactive: false
    property string titleText: ""

    function fromPayload(data) {          // "class,title" — "," means nothing is focused
        const s = String(data || "")
        const i = s.indexOf(",")
        titleText = i < 0 ? "" : s.slice(i + 1)
    }
    Process {
        id: query
        command: ["hyprctl", "activewindow", "-j"]
        stdout: StdioCollector { onStreamFinished: { try { aw.titleText = JSON.parse(text).title || "" } catch (e) { aw.titleText = "" } } }
    }
    Connections {
        target: Hyprland
        function onRawEvent(ev) {
            if (ev.name === "activewindow") { aw.fromPayload(ev.data); return }
            if (ev.name === "windowtitlev2") {          // the focused window renamed itself
                const t = Hyprland.activeToplevel
                const d = String(ev.data)
                if (t && d.indexOf(String(t.address)) === 0) aw.fromPayload(d)
                return
            }
            // a close or a workspace change can leave nothing focused without
            // an activewindow event of its own; re-read to be sure
            if (ev.name === "closewindow" || ev.name === "workspacev2" || ev.name === "focusedmonv2") query.running = true
        }
    }
    Timer { interval: 15000; running: true; repeat: true; onTriggered: query.running = true }   // re-sync if an event is ever missed
    Component.onCompleted: query.running = true

    visible: titleText !== "" && !vertical
    Label {
        text: aw.titleText.length > 48 ? aw.titleText.substring(0, 47) + "…" : aw.titleText
        color: Theme.c.accentMid
    }
}
