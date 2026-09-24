import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Bar
import qs.Services

// Clipboard history — the rofi clipboard menu rebuilt: 620px card, "clip"
// prompt + search, eight 38px rows with 26px thumbnails. Enter copies,
// Delete removes the entry, Escape closes.
Variants {
    model: Quickshell.screens
    PanelWindow {
        id: win
        required property var modelData
        screen: modelData
        visible: Clip.open
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: Clip.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        WlrLayershell.namespace: "hypr-clipboard"
        color: "transparent"

        property int selected: 0
        readonly property int rowsShown: 8
        readonly property var items: {
            const q = input.text.toLowerCase()
            return Clip.entries.filter(e => q === "" || e.preview.toLowerCase().indexOf(q) !== -1)
        }
        onVisibleChanged: if (visible) { selected = 0; input.text = ""; input.forceActiveFocus() }
        onItemsChanged: if (selected >= items.length) selected = Math.max(0, items.length - 1)

        MouseArea { anchors.fill: parent; onClicked: Clip.open = false }

        Rectangle {
            id: card
            anchors.centerIn: parent
            width: 620
            height: 14 + 30 + 6 + win.rowsShown * 38 + (win.rowsShown - 1) * 2 + 14
            radius: Theme.radius
            color: Theme.alpha(Theme.c.bg0, 0.74)
            border.width: 1; border.color: Theme.alpha(Theme.c.accentLight, 0.17)

            Item {
                id: bar
                x: 14; y: 14; width: parent.width - 28; height: 30
                Label { id: prompt; anchors.verticalCenter: parent.verticalCenter; x: 6; text: "clip"; font.pixelSize: Theme.fs(13); color: Theme.c.accentBright }
                TextInput {
                    id: input
                    anchors.left: prompt.right; anchors.leftMargin: 14
                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.font; font.pixelSize: Theme.fs(13); color: Theme.c.accentBright
                    focus: true
                    Label { visible: !input.text; anchors.verticalCenter: parent.verticalCenter; text: "search clipboard"; font.pixelSize: Theme.fs(13); color: Theme.c.accentMid }
                    Keys.onPressed: (e) => {
                        const n = win.items.length
                        if (e.key === Qt.Key_Escape) { Clip.open = false; e.accepted = true; return }
                        if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) { if (n) Clip.copy(win.items[win.selected]); e.accepted = true; return }
                        if (e.key === Qt.Key_Delete) { if (n) Clip.remove(win.items[win.selected]); e.accepted = true; return }
                        if (n === 0) return
                        if (e.key === Qt.Key_Down || e.key === Qt.Key_Tab) { win.selected = (win.selected + 1) % n; e.accepted = true }
                        else if (e.key === Qt.Key_Up || e.key === Qt.Key_Backtab) { win.selected = (win.selected + n - 1) % n; e.accepted = true }
                    }
                }
            }

            ListView {
                id: list
                x: 14; y: bar.y + bar.height + 6
                width: parent.width - 28
                height: win.rowsShown * 38 + (win.rowsShown - 1) * 2
                clip: true
                spacing: 2
                model: win.items
                currentIndex: win.selected
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool sel: index === win.selected
                    width: list.width; height: 38
                    radius: Theme.radius
                    color: sel ? Theme.c.bg2 : "transparent"
                    Image {
                        id: thumb
                        visible: row.modelData.image
                        x: 8; anchors.verticalCenter: parent.verticalCenter
                        width: 26; height: 26
                        fillMode: Image.PreserveAspectFit
                        source: row.modelData.image && row.modelData.thumb ? "file://" + row.modelData.thumb : ""
                        asynchronous: true
                    }
                    Label {
                        x: row.modelData.image ? 44 : 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - x - 8; elide: Text.ElideRight
                        text: row.modelData.preview.replace(/\s+/g, " ")
                        font.pixelSize: Theme.fs(13)
                        color: row.sel ? Theme.c.accentBright : Theme.c.fg
                    }
                    // click only: hovering never moves the selection
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: Clip.copy(row.modelData) }
                }
                Label { visible: win.items.length === 0; anchors.centerIn: parent; text: "clipboard is empty"; font.pixelSize: Theme.fs(12); color: Theme.c.accentMid }
            }
        }
    }
}
