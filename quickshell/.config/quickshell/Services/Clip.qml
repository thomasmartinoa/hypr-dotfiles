pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Clipboard history via cliphist (wl-paste --watch cliphist store runs at
// login). Image entries get a thumbnail rendered with ffmpeg into
// ~/.cache/cliphist-thumbs — the same cache the rofi script used.
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
        command: ["bash", "-c", `
mkdir -p "$C"; find "$C" -type f -mtime +14 -delete 2>/dev/null
cliphist list | head -n 80 | while IFS=$'\\t' read -r id preview; do
  if [[ "$preview" == *"binary data"* ]]; then
    thumb="$C/$id.png"
    [[ -s "$thumb" ]] || cliphist decode "$id" 2>/dev/null | ffmpeg -y -loglevel error -i - -vf "scale=72:-1" "$thumb" 2>/dev/null
    meta="$preview"
    if [[ "$preview" =~ binary\\ data\\ ([0-9.]+\\ [KMG]iB)\\ ([a-z]+)\\ ([0-9]+x[0-9]+) ]]; then meta="\${BASH_REMATCH[2]}  ·  \${BASH_REMATCH[3]}  ·  \${BASH_REMATCH[1]}"; fi
    printf '{"id":%s,"image":true,"thumb":"%s","preview":%s}\\n' "$id" "$thumb" "$(printf '%s' "$meta" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
  else
    printf '{"id":%s,"image":false,"preview":%s}\\n' "$id" "$(printf '%s' "$preview" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
  fi
done`]
        environment: ({ C: root.cache })
        stdout: StdioCollector {
            onStreamFinished: {
                const out = []
                for (const line of text.split("\n")) { if (!line.trim()) continue; try { out.push(JSON.parse(line)) } catch (e) {} }
                root.entries = out
            }
        }
    }

    IpcHandler {
        target: "clipboard"
        function toggle(): void { root.toggle() }
        function open(): void { root.refresh(); root.open = true }
        function close(): void { root.open = false }
    }
}
