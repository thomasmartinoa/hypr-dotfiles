pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// The current wallpaper. ~/.config/hypr-theme/current/background is the
// symlink hypr-wall maintains; on start we show whatever it points at, and
// hypr-wall pushes every change over IPC so the windows can crossfade.
Singleton {
    id: root
    readonly property string link: Quickshell.env("HOME") + "/.config/hypr-theme/current/background"
    property string path: link
    property int generation: 0        // bumps on every set, even to the same path

    function set(p) {
        path = p && p.length > 0 ? p : link
        generation++
    }

    IpcHandler {
        target: "wallpaper"
        function set(path: string): string { root.set(path); return root.path }
        function get(): string { return root.path }
        function reload(): void { root.set(root.link) }
    }
}
