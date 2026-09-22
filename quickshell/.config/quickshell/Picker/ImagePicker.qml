import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Bar
import qs.Services

// The picker — Omarchy's carousel: the selected item expanded in the
// middle, the rest as tall dimmed slices to either side, all sliding as
// the selection moves. Themes are previewed live in their own colours
// (ThemePreview); wallpapers are just the image.
// ← → (h l), Home/End, scroll; Enter applies; Esc; type to filter. No
// text under it — the picture is the whole UI.
Variants {
    model: Quickshell.screens
    PanelWindow {
        id: win
        required property var modelData
        screen: modelData
        visible: Themes.open
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: Themes.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        WlrLayershell.namespace: "hypr-picker"
        color: Theme.alpha(Theme.c.bg0, 0.72)

        readonly property bool themeMode: Themes.pickerMode === "theme"
        property string filter: ""
        property int selected: 0
        readonly property var items: {
            const q = filter.toLowerCase()
            if (themeMode) return Themes.themes.filter(t => q === "" || t.name.toLowerCase().indexOf(q) !== -1 || t.id.indexOf(q) !== -1)
            return Themes.wallpapers.filter(p => q === "" || p.split("/").pop().toLowerCase().indexOf(q) !== -1).map(p => ({ path: p }))
        }
        // the catalogue is re-read on open; until it lands, land on the current item
        property bool snapToCurrent: false
        function snap() { selected = Math.max(0, items.findIndex(t => t.current || t.path === Wallpaper.path)) }
        onItemsChanged: {
            if (snapToCurrent && filter === "") snap()
            else if (selected >= items.length) selected = Math.max(0, items.length - 1)
        }
        onVisibleChanged: if (visible) { filter = ""; snapToCurrent = true; snap() } else snapToCurrent = false
        onFilterChanged: if (filter !== "") snapToCurrent = false

        // geometry (Omarchy: 768x475 expanded, 108x432 slices); scaled to the screen
        readonly property real k: Math.min(1, (screen.width - 160) / 1400, (screen.height - 200) / 640)
        readonly property int bigW: Math.round(768 * k)
        readonly property int bigH: Math.round(475 * k)
        readonly property int sliceW: Math.round(108 * k)
        readonly property int sliceH: Math.round(432 * k)
        readonly property int gap: Math.round(10 * k)
        readonly property int step: sliceW + gap
        readonly property int sidesEach: Math.max(1, Math.floor((screen.width - 120 - bigW) / 2 / step))

        function activate() {
            const it = items[selected]; if (!it) return
            if (themeMode) Themes.apply(it.id); else Themes.applyWallpaper(it.path)
        }
        function move(d) { const n = items.length; if (n) selected = Math.max(0, Math.min(n - 1, selected + d)) }

        MouseArea { anchors.fill: parent; onClicked: Themes.close(); onWheel: (w) => win.move(w.angleDelta.y > 0 ? -1 : 1) }

        Item {
            anchors.fill: parent
            focus: Themes.open
            Keys.onPressed: (e) => {
                if (e.key === Qt.Key_Escape) { if (win.filter !== "") win.filter = ""; else Themes.close(); return }
                if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) { win.activate(); return }
                if (e.key === Qt.Key_Left  || (e.key === Qt.Key_H && win.filter === "")) { win.move(-1); return }
                if (e.key === Qt.Key_Right || (e.key === Qt.Key_L && win.filter === "") || e.key === Qt.Key_Tab) { win.move(1); return }
                if (e.key === Qt.Key_Home) { win.selected = 0; return }
                if (e.key === Qt.Key_End) { win.selected = Math.max(0, win.items.length - 1); return }
                if (e.key === Qt.Key_Backspace) { win.filter = win.filter.slice(0, -1); return }
                if (e.text && e.text.length === 1 && e.text >= " ") { win.filter += e.text; win.selected = 0 }
            }

            // carousel
            Item {
                id: carousel
                anchors.horizontalCenter: parent.horizontalCenter
                y: (parent.height - win.bigH) / 2
                width: win.bigW + 2 * win.sidesEach * win.step
                height: win.bigH
                readonly property real bigX: (width - win.bigW) / 2

                Repeater {
                    model: win.items
                    Item {
                        id: cell
                        required property var modelData
                        required property int index
                        readonly property int rel: index - win.selected
                        readonly property bool sel: rel === 0
                        readonly property bool shown: Math.abs(rel) <= win.sidesEach
                        visible: shown || xAnim.running
                        x: sel ? carousel.bigX
                           : rel < 0 ? carousel.bigX + rel * win.step
                                     : carousel.bigX + win.bigW + win.gap + (rel - 1) * win.step
                        y: (carousel.height - height) / 2
                        width: sel ? win.bigW : win.sliceW
                        height: sel ? win.bigH : win.sliceH
                        z: sel ? 2 : 1
                        Behavior on x { NumberAnimation { id: xAnim; duration: 220; easing.type: Easing.OutCubic } }
                        Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                        Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                        Rectangle {
                            anchors.fill: parent
                            radius: Theme.radius
                            color: Theme.c.bg1
                            border.width: cell.sel ? 3 : 1
                            border.color: cell.sel ? Theme.c.accentBright : Theme.c.border
                            clip: true
                            // the content is always drawn at the expanded size and cropped, so
                            // a slice is a strip of the same picture
                            Item {
                                id: content
                                width: win.bigW; height: win.bigH
                                x: (parent.width - width) / 2
                                y: (parent.height - height) / 2
                                Loader {
                                    anchors.fill: parent
                                    sourceComponent: win.themeMode ? themePreview : wallPreview
                                }
                                Component { id: themePreview; ThemePreview { theme: cell.modelData } }
                                Component {
                                    id: wallPreview
                                    Image {
                                        source: "file://" + cell.modelData.path
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        sourceSize: Qt.size(1024, 640)
                                        cache: true
                                    }
                                }
                            }
                            Rectangle { anchors.fill: parent; color: Theme.alpha(Theme.c.bg0, cell.sel ? 0 : 0.42)
                                        Behavior on color { ColorAnimation { duration: 220 } } }
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: { if (cell.sel) win.activate(); else win.selected = cell.index }
                        }
                    }
                }
            }

            // nothing under the carousel; only the filter shows while you type
            Label {
                visible: win.filter !== ""
                anchors.top: carousel.bottom; anchors.topMargin: 18
                anchors.horizontalCenter: parent.horizontalCenter
                text: "\u{f0349}  " + win.filter
                font.pixelSize: 13; color: Theme.c.fg
            }
        }
    }
}
