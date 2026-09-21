import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Commons
import qs.Bar
import qs.Services

// App launcher — the rofi drun window, rebuilt: 800px card, the
// "Applications" chip + search, two columns of ten 44px rows with icons,
// a light bar marking the selection. Type to filter, arrows/Tab move,
// Enter launches, Escape closes.
Variants {
    model: Quickshell.screens
    PanelWindow {
        id: win
        required property var modelData
        screen: modelData
        visible: Apps.open
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: Apps.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        WlrLayershell.namespace: "hypr-launcher"
        color: "transparent"

        property int selected: 0
        readonly property int cols: 2
        readonly property int rowsShown: 10
        onVisibleChanged: if (visible) { selected = 0; input.text = ""; input.forceActiveFocus() }
        Connections { target: Apps; function onResultsChanged() { win.selected = 0 } }

        MouseArea { anchors.fill: parent; onClicked: Apps.open = false }

        Rectangle {
            id: card
            anchors.centerIn: parent
            width: 800
            height: 30 + 42 + 10 + win.rowsShown * 44 + (win.rowsShown - 1) * 10 + 30
            radius: Theme.radius
            color: Qt.rgba(Theme.c.bg0.r, Theme.c.bg0.g, Theme.c.bg0.b, 0.74)
            border.width: 1; border.color: Theme.c.borderStrong

            // inputbar
            Rectangle {
                id: bar
                x: 30; y: 30; width: parent.width - 60; height: 42
                radius: Theme.radius
                color: Qt.rgba(Theme.c.bg1.r, Theme.c.bg1.g, Theme.c.bg1.b, 0.97)
                Rectangle {
                    id: prompt
                    width: pl.implicitWidth + 24; height: parent.height; radius: Theme.radius
                    color: Theme.c.accentLight
                    Label { id: pl; anchors.centerIn: parent; text: "Applications"; font.pixelSize: 13; color: Theme.c.bg0 }
                }
                TextInput {
                    id: input
                    anchors.left: prompt.right; anchors.leftMargin: 12
                    anchors.right: parent.right; anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.font; font.pixelSize: 13
                    color: Theme.c.accentBright
                    focus: true
                    onTextChanged: Apps.query = text
                    Label { visible: !input.text; anchors.verticalCenter: parent.verticalCenter; text: "Search..."; font.pixelSize: 13; color: Theme.c.accentMid }
                    Keys.onPressed: (e) => {
                        const n = Apps.results.length
                        if (e.key === Qt.Key_Escape) { Apps.open = false; e.accepted = true; return }
                        if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) { Apps.launch(Apps.results[win.selected]); e.accepted = true; return }
                        if (n === 0) return
                        if (e.key === Qt.Key_Down || (e.key === Qt.Key_Tab)) { win.selected = (win.selected + 1) % n; e.accepted = true }
                        else if (e.key === Qt.Key_Up || e.key === Qt.Key_Backtab) { win.selected = (win.selected + n - 1) % n; e.accepted = true }
                        else if (e.key === Qt.Key_Right) { win.selected = Math.min(n - 1, win.selected + win.rowsShown); e.accepted = true }
                        else if (e.key === Qt.Key_Left) { win.selected = Math.max(0, win.selected - win.rowsShown); e.accepted = true }
                    }
                }
            }

            // listview: rofi fills column-major (down the first column, then the next)
            GridView {
                id: grid
                x: 30; y: bar.y + bar.height + 10
                width: parent.width - 60
                height: win.rowsShown * 44 + (win.rowsShown - 1) * 10
                clip: true
                flow: GridView.FlowTopToBottom
                cellWidth: (width - 10) / win.cols + 5
                cellHeight: 54
                model: Apps.results
                currentIndex: win.selected
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)
                delegate: Item {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool sel: index === win.selected
                    width: grid.cellWidth; height: grid.cellHeight
                    Rectangle {
                        width: parent.width - 10; height: 44
                        radius: Theme.radiusSm
                        color: row.sel ? Theme.c.bg3 : Theme.c.bg2
                        Rectangle { visible: row.sel; width: 3; height: parent.height; radius: 1; color: Theme.c.accentBright }
                        IconImage {
                            x: 16; anchors.verticalCenter: parent.verticalCenter
                            implicitSize: 30
                            source: row.modelData.icon ? Quickshell.iconPath(row.modelData.icon, true) : ""
                            Label { visible: parent.source === ""; anchors.centerIn: parent; text: "󰀻"; font.pixelSize: 18; color: Theme.c.accentMid }
                        }
                        Label {
                            x: 58; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 70; elide: Text.ElideRight
                            text: row.modelData.name; font.pixelSize: 13
                            color: row.sel ? Theme.c.accentBright : Theme.c.fg
                        }
                        MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onEntered: win.selected = row.index; onClicked: Apps.launch(row.modelData) }
                    }
                }
            }
        }
    }
}
