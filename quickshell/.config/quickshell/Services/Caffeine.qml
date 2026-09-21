pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Stay awake. The shell's idle timers watch `on`; a systemd-logind sleep
// inhibitor is held as well so nothing else (lid, other tools) suspends.
// ~/.config/hypr/scripts/caffeine.sh is a thin wrapper over the IPC.
Singleton {
    id: root
    property bool on: false

    function toggle() { on = !on }

    Process {
        id: inhibit
        running: root.on
        command: ["systemd-inhibit", "--what=sleep:idle", "--who=caffeine", "--why=User asked to stay awake", "--mode=block", "sleep", "infinity"]
    }
    onOnChanged: Quickshell.execDetached(["notify-send", "-a", "caffeine", on ? "Caffeine on" : "Caffeine off",
                                          on ? "Idle lock and suspend paused" : "Idle lock and suspend back to normal"])

    IpcHandler {
        target: "caffeine"
        function toggle(): bool { root.toggle(); return root.on }
        function on(): void { root.on = true }
        function off(): void { root.on = false }
        function status(): string { return root.on ? "on" : "off" }
    }
}
