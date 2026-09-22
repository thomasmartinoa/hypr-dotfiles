pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Clipboard history via cliphist (wl-paste --watch cliphist store runs at
// login). The list is read by Services/cliplist.py — one process for all
// entries, ~50ms — and kept up to date as the clipboard changes. Image
// entries get a thumbnail rendered with ffmpeg into ~/.cache/cliphist-thumbs
// — the same cache the rofi script used.
Singleton {
    id: root
    property bool open: false
    property var entries: []        // { id, preview, image, thumb, meta }
    readonly property string cache: Quickshell.env("HOME") + "/.cache/cliphist-thumbs"

    function refresh() { list.running = true }
    function toggle() { if (!open) refresh(); open = !open }

    function copy(e)   { Quickshell.execDetached(["bash", "-c", "cliphist decode " + e.id + " | wl-copy"]); open = false }
    function remove(e) { Quickshell.execDetached(["bash", "-c", "cliphist list | grep -m1 '^" + e.id + "\\t' | cliphist delete; rm -f " + cache + "/" + e.id + ".png"]); refreshLater.restart() }
    function wipe()    { Quickshell.execDetached(["bash", "-c", "cliphist wipe; rm -rf " + cache]); refreshLater.restart() }
    Timer { id: refreshLater; interval: 300; onTriggered: root.refresh() }

    Process {
        id: list
        // one JSON object per line: id, preview, and for images the thumbnail path (rendered if missing)
        command: ["python3", Quickshell.shellPath("Services/cliplist.py"), "80"]
        environment: ({ C: root.cache })
        stdout: StdioCollector {
            onStreamFinished: {
                const out = []
                for (const line of text.split("\n")) { if (!line.trim()) continue; try { out.push(JSON.parse(line)) } catch (e) {} }
                root.entries = out
            }
        }
    }

    // Keep the list warm: every clipboard change re-reads it (shortly after,
    // so `wl-paste --watch cliphist store` has stored it), so opening the
    // history is instant instead of waiting for cliphist.
    Process {
        id: watch
        running: true
        command: ["wl-paste", "--watch", "echo", "changed"]
        stdout: SplitParser { onRead: changed.restart() }
    }
    Timer { id: changed; interval: 150; onTriggered: root.refresh() }
    Component.onCompleted: refresh()

    IpcHandler {
        target: "clipboard"
        function toggle(): void { root.toggle() }
        function open(): void { root.refresh(); root.open = true }
        function close(): void { root.open = false }
    }
}
