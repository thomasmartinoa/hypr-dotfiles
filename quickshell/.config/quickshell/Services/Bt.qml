pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth

// Bluetooth power. The adapter cannot be powered on while rfkill has it
// soft-blocked — bluetoothd reports PowerState "off-blocked" and silently
// refuses, which is the state this laptop boots in — so unblock first.
Singleton {
    id: root
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool on: adapter ? adapter.enabled : false

    function power(want) {
        if (!adapter) return
        if (want) unblock.running = true
        else adapter.enabled = false
    }
    function toggle() { power(!on) }

    Process {
        id: unblock
        command: ["rfkill", "unblock", "bluetooth"]
        onExited: if (root.adapter) root.adapter.enabled = true
    }

    IpcHandler {
        target: "bluetooth"
        function toggle(): bool { root.toggle(); return root.on }
        function on(): void { root.power(true) }
        function off(): void { root.power(false) }
        function status(): string { return !root.adapter ? "no adapter" : root.on ? "on" : "off" }
    }
}
