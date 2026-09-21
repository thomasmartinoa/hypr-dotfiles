pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Mirrors ~/.config/hypr/scripts/caffeine.sh: on when its systemd-inhibit
// lock is held. Polled, because the lock can also be toggled from the
// keybind; the toggle here re-checks immediately.
Singleton {
    id: root
    property bool on: false
    readonly property string script: Quickshell.env("HOME") + "/.config/hypr/scripts/caffeine.sh"

    function refresh() { check.running = true }
    function toggle() { toggler.running = true }

    Process {
        id: check
        command: ["bash", "-c", "pgrep -f '^systemd-inhibit .*--who=caffeine( |$)' >/dev/null && echo on || echo off"]
        stdout: StdioCollector { onStreamFinished: root.on = text.trim() === "on" }
    }
    Process {
        id: toggler
        command: [root.script, "toggle"]
        onExited: root.refresh()
    }
    Timer { interval: 3000; running: true; repeat: true; onTriggered: root.refresh() }
    Component.onCompleted: refresh()
}
