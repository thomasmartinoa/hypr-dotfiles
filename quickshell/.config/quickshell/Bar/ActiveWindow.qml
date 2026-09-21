import QtQuick
import Quickshell.Io
import Quickshell.Hyprland
import qs.Commons

// Focused window title (minimal skin); hidden on a vertical bar.
// Hyprland.activeToplevel is only set after the first focus change, so fall
// back to the toplevel flagged `activated` and re-evaluate on focus events.
Pill {
    id: aw
    interactive: false
    property string titleText: ""
    function refresh() {
        const t = Hyprland.activeToplevel || Hyprland.toplevels.values.find(x => x.activated) || null
        if (t) titleText = t.title || ""
        else query.running = true            // before any focus event: ask hyprctl once
    }
    Process {
        id: query
        command: ["hyprctl", "activewindow", "-j"]
        stdout: StdioCollector { onStreamFinished: { try { aw.titleText = JSON.parse(text).title || "" } catch (e) { aw.titleText = "" } } }
    }
    Connections {
        target: Hyprland
        function onActiveToplevelChanged() { aw.refresh() }
        function onRawEvent(ev) { if (ev.name === "activewindow" || ev.name === "activewindowv2" || ev.name === "windowtitlev2") aw.refresh() }
    }
    Timer { interval: 2000; running: true; repeat: true; onTriggered: aw.refresh() }
    Component.onCompleted: { Hyprland.refreshToplevels(); refresh() }
    visible: titleText !== "" && !vertical
    Label {
        text: aw.titleText.length > 48 ? aw.titleText.substring(0, 47) + "…" : aw.titleText
        color: Theme.c.accentMid
    }
}
