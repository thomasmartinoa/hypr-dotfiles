pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Which popup panel is open, and which bar widget it hangs from. One at a
// time; a Panel shows itself when its name and anchor match.
Singleton {
    id: root
    property string open: ""
    property Item item: null

    function toggle(name, anchor) {
        if (open === name && item === anchor) { close(); return }
        item = anchor
        open = name
    }
    function close() { open = ""; item = null }

    // name -> anchor item, so panels can be opened from IPC / keybinds too.
    // Always the newest instance: changing the bar layout rebuilds its
    // widgets, and a stale entry here points at a destroyed item, which
    // leaves `qs ipc call panels open <name>` opening nothing.
    property var registry: ({})
    function register(name, anchor) { registry[name] = anchor }

    IpcHandler {
        target: "panels"
        function close(): void { root.close() }
        function current(): string { return root.open }
        function open(name: string): string {
            const a = root.registry[name]
            if (!a) return "unknown panel: " + name
            try { void a.width } catch (e) { return "panel not on the bar: " + name }
            root.toggle(name, a)
            return root.open
        }
    }
}
