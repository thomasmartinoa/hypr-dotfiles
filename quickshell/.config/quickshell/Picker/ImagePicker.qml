import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Bar
import qs.Services

// Fullscreen image grid — themes (a tile per theme: its wallpaper with a
// mock bar and palette swatches drawn in its colours) or wallpapers.
// Arrows / hjkl move, Enter applies, Escape closes, typing filters.
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
        color: Theme.alpha(Theme.c.bg0, 0.7)

        readonly property bool themeMode: Themes.pickerMode === "theme"
        property string filter: ""
        property int selected: 0
        readonly property var items: {
            const q = filter.toLowerCase()
            if (themeMode) return Themes.themes.filter(t => q === "" || t.name.toLowerCase().indexOf(q) !== -1 || t.id.indexOf(q) !== -1)
            return Themes.wallpapers.filter(p => q === "" || p.toLowerCase().indexOf(q) !== -1).map(p => ({ path: p }))
        }
        readonly property int cols: 3
        readonly property int tileW: 300
        readonly property int tileH: 200
        onVisibleChanged: if (visible) { filter = ""; selected = Math.max(0, items.findIndex(t => t.current)) }

        function activate(i) {
            const it = items[i]; if (!it) return
            if (themeMode) Themes.apply(it.id); else Themes.applyWallpaper(it.path)
        }

        MouseArea { anchors.fill: parent; onClicked: Themes.close() }

        Item {
            anchors.fill: parent
            focus: Themes.open
            Keys.onPressed: (e) => {
                const n = win.items.length
                if (e.key === Qt.Key_Escape) { if (win.filter !== "") win.filter = ""; else Themes.close(); return }
                if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) { win.activate(win.selected); return }
                if (e.key === Qt.Key_Left  || (e.key === Qt.Key_H && win.filter === "")) { win.selected = (win.selected + n - 1) % Math.max(1, n); return }
                if (e.key === Qt.Key_Right || (e.key === Qt.Key_L && win.filter === "")) { win.selected = (win.selected + 1) % Math.max(1, n); return }
                if (e.key === Qt.Key_Up    || (e.key === Qt.Key_K && win.filter === "")) { win.selected = Math.max(0, win.selected - win.cols); return }
                if (e.key === Qt.Key_Down  || (e.key === Qt.Key_J && win.filter === "")) { win.selected = Math.min(n - 1, win.selected + win.cols); return }
                if (e.key === Qt.Key_Backspace) { win.filter = win.filter.slice(0, -1); return }
                if (e.text && e.text.length === 1 && e.text >= " ") { win.filter += e.text; win.selected = 0 }
            }

            Rectangle {
                id: card
                anchors.centerIn: parent
                width: win.cols * win.tileW + (win.cols + 1) * 16
                height: Math.min(parent.height - 80, head.height + 16 + grid.contentHeight + 32)
                radius: Theme.radius
                color: Theme.c.bg0
                border.width: 1; border.color: Theme.c.border

                Item {
                    id: head
                    x: 16; y: 12; width: parent.width - 32; height: 40
                    Label { anchors.verticalCenter: parent.verticalCenter; text: win.themeMode ? "Themes" : "Wallpapers"
                            font.pixelSize: 15; font.weight: Font.Bold; color: Theme.c.accentBright }
                    Label { anchors.verticalCenter: parent.verticalCenter; anchors.right: parent.right
                            text: win.filter !== "" ? "󰍉  " + win.filter : "type to filter · Enter to apply · Esc"
                            font.pixelSize: 12; color: win.filter !== "" ? Theme.c.fg : Theme.c.accentDim }
                }

                GridView {
                    id: grid
                    x: 16; y: head.y + head.height + 8
                    width: parent.width - 32
                    height: parent.height - y - 16
                    clip: true
                    cellWidth: win.tileW + 16
                    cellHeight: win.tileH + 44
                    model: win.items
                    currentIndex: win.selected
                    onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)
                    delegate: Item {
                        id: tile
                        required property var modelData
                        required property int index
                        readonly property bool sel: index === win.selected
                        readonly property bool isTheme: win.themeMode
                        readonly property var c: isTheme ? modelData.colors : null
                        readonly property string img: isTheme ? (modelData.backgrounds[0] || "") : modelData.path
                        width: grid.cellWidth; height: grid.cellHeight

                        Rectangle {
                            id: frame
                            width: win.tileW; height: win.tileH
                            radius: Theme.radius
                            color: Theme.c.bg1
                            border.width: tile.sel ? 2 : 1
                            border.color: tile.sel ? Theme.c.accentBright : Theme.c.border
                            clip: true
                            Image {
                                anchors.fill: parent; anchors.margins: 2
                                source: tile.img !== "" ? "file://" + tile.img : ""
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                sourceSize: Qt.size(600, 400)
                                cache: true
                            }
                            // theme tiles: a mock bar + palette swatches in the theme's own colours
                            Item {
                                visible: tile.isTheme
                                anchors.fill: parent; anchors.margins: 2
                                Rectangle {
                                    x: 10; y: 10; width: parent.width - 20; height: 18; radius: 3
                                    color: tile.c ? tile.c.bg0 : "black"
                                    border.width: 1; border.color: tile.c ? tile.c.bg3 : "gray"
                                    Row {
                                        x: 6; anchors.verticalCenter: parent.verticalCenter; spacing: 4
                                        Rectangle { width: 26; height: 10; radius: 2; color: tile.c ? tile.c.bg2 : "gray" }
                                        Rectangle { width: 14; height: 10; radius: 2; color: tile.c ? tile.c.fg : "white" }
                                        Rectangle { width: 14; height: 10; radius: 2; color: tile.c ? tile.c.bg2 : "gray" }
                                    }
                                    Row {
                                        anchors.right: parent.right; anchors.rightMargin: 6; anchors.verticalCenter: parent.verticalCenter; spacing: 4
                                        Repeater { model: 3; Rectangle { width: 10; height: 10; radius: 2; color: tile.c ? tile.c.bg2 : "gray" } }
                                    }
                                }
                                Row {
                                    anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.margins: 10; spacing: 4
                                    Repeater {
                                        model: tile.c ? [tile.c.bg0, tile.c.bg2, tile.c.accent_dim, tile.c.accent_mid, tile.c.accent_light, tile.c.accent_bright] : []
                                        Rectangle { required property string modelData; width: 16; height: 16; radius: 3; color: modelData
                                                    border.width: 1; border.color: Qt.rgba(0.5, 0.5, 0.5, 0.5) }
                                    }
                                }
                                Label {
                                    anchors.bottom: parent.bottom; anchors.right: parent.right; anchors.margins: 10
                                    text: tile.modelData.mode; font.pixelSize: 11
                                    color: tile.c ? tile.c.fg : "white"
                                    Rectangle { anchors.fill: parent; anchors.margins: -4; z: -1; radius: 3; color: tile.c ? tile.c.bg0 : "black"; opacity: 0.85 }
                                }
                            }
                            Label {
                                visible: tile.isTheme && tile.modelData.current
                                x: 10; y: 34; text: "current"; font.pixelSize: 10; color: Theme.c.bg0
                                Rectangle { anchors.fill: parent; anchors.margins: -4; z: -1; radius: 3; color: Theme.c.fg }
                            }
                        }
                        Label {
                            anchors.top: frame.bottom; anchors.topMargin: 8
                            width: frame.width; elide: Text.ElideMiddle
                            text: tile.isTheme ? tile.modelData.name : tile.img.split("/").pop()
                            font.pixelSize: 12; font.weight: tile.sel ? Font.Bold : Font.Medium
                            color: tile.sel ? Theme.c.accentBright : Theme.c.fg
                        }
                        MouseArea {
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onEntered: win.selected = tile.index
                            onClicked: win.activate(tile.index)
                        }
                    }
                }
            }
        }
    }
}
