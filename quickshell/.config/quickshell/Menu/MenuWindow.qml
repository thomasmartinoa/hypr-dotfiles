import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Bar
import qs.Services

// The menu overlay, kept minimal: one search line (a dim breadcrumb in
// front of it when inside a section), compact single-line rows, nothing
// else. ↑↓ / Tab move, Enter opens or runs, → opens, Backspace/← on an
// empty box goes up, Esc closes. Searching lists every leaf; the section a
// result belongs to is shown dimly on the right.
Variants {
    model: Quickshell.screens
    PanelWindow {
        id: win
        required property var modelData
        screen: modelData
        visible: Menu.open
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: Menu.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        WlrLayershell.namespace: "hypr-menu"
        color: "transparent"

        readonly property int rowH: 34
        readonly property int rowsMax: 10
        readonly property var rows: Menu.rows
        readonly property int rowsShown: Math.max(2, Math.min(rowsMax, rows.length))
        onVisibleChanged: if (visible) { input.text = ""; input.forceActiveFocus() }
        Connections { target: Menu
            function onPathChanged() { input.text = "" }
            function onInputRowChanged() { input.text = "" }
            function onQueryChanged() { if (input.text !== Menu.query) input.text = Menu.query } }

        MouseArea { anchors.fill: parent; onClicked: Menu.close() }

        Rectangle {
            id: card
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -40
            width: 520
            height: 10 + 36 + 6 + win.rowsShown * win.rowH + 10
            Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            radius: Theme.radius
            color: Theme.alpha(Theme.c.bg0, 0.8)
            border.width: 1; border.color: Theme.c.border

            // search line: [breadcrumb ›] input
            Item {
                id: bar
                x: 10; y: 10; width: parent.width - 20; height: 36
                Label {
                    id: crumb
                    anchors.left: parent.left; anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Menu.crumb !== "Menu"
                    text: Menu.crumb + "  ›"
                    font.pixelSize: 12; color: Theme.c.accentMid
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Menu.up() }
                }
                TextInput {
                    id: input
                    anchors.left: crumb.visible ? crumb.right : parent.left
                    anchors.leftMargin: 8
                    anchors.right: parent.right; anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.font; font.pixelSize: 13; color: Theme.c.accentBright
                    focus: true
                    onTextChanged: { if (!Menu.inputRow) { Menu.query = text; Menu.selected = 0 } }
                    Label { visible: !input.text; anchors.verticalCenter: parent.verticalCenter
                            text: Menu.inputRow ? Menu.placeholder : "Search"; font.pixelSize: 13; color: Theme.c.accentDim }
                    Keys.onPressed: (e) => {
                        const n = win.rows.length
                        if (e.key === Qt.Key_Escape) { if (Menu.inputRow || input.text !== "") Menu.up(); else Menu.close(); e.accepted = true; return }
                        if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                            if (Menu.inputRow) Menu.submitInput(input.text); else if (n) Menu.activate(win.rows[Menu.selected])
                            e.accepted = true; return
                        }
                        if ((e.key === Qt.Key_Backspace || e.key === Qt.Key_Left) && input.text === "") { Menu.up(); e.accepted = true; return }
                        if (e.key === Qt.Key_Right && !Menu.inputRow && n && win.rows[Menu.selected].sub) { Menu.activate(win.rows[Menu.selected]); e.accepted = true; return }
                        if (n === 0 || Menu.inputRow) return
                        if (e.key === Qt.Key_Down || e.key === Qt.Key_Tab) { Menu.selected = (Menu.selected + 1) % n; e.accepted = true }
                        else if (e.key === Qt.Key_Up || e.key === Qt.Key_Backtab) { Menu.selected = (Menu.selected + n - 1) % n; e.accepted = true }
                    }
                }
            }
            Rectangle { x: 10; y: bar.y + bar.height; width: parent.width - 20; height: 1; color: Theme.c.bg3 }

            ListView {
                id: list
                x: 10; y: bar.y + bar.height + 6
                width: parent.width - 20
                height: win.rowsShown * win.rowH
                clip: true; spacing: 0
                model: win.rows
                currentIndex: Menu.selected
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool sel: index === Menu.selected
                    width: list.width; height: win.rowH
                    radius: Theme.radiusSm
                    color: sel ? Theme.c.bg2 : "transparent"
                    Label {
                        id: ic
                        x: 10; anchors.verticalCenter: parent.verticalCenter; width: 18
                        text: row.modelData.icon; font.pixelSize: 13
                        color: row.sel ? Theme.c.accentBright : Theme.c.accentMid
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Label {
                        anchors.left: ic.right; anchors.leftMargin: 10
                        anchors.right: right.left; anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                        text: row.modelData.label; font.pixelSize: 12
                        color: row.sel ? Theme.c.accentBright : Theme.c.fg
                    }
                    Row {
                        id: right
                        anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter
                        spacing: 10
                        Label { visible: Menu.query !== "" && row.modelData.crumb !== ""; text: row.modelData.crumb; font.pixelSize: 11; color: Theme.c.accentDim
                                elide: Text.ElideRight; width: Math.min(implicitWidth, 150) }
                        Label { visible: row.modelData.value !== ""; text: row.modelData.value; font.pixelSize: 11; color: Theme.c.accentMid
                                elide: Text.ElideRight; width: Math.min(implicitWidth, 170) }
                        Label { visible: row.modelData.checked === true; text: "󰄬"; font.pixelSize: 13; color: Theme.c.accentBright }
                        Label { visible: row.modelData.sub; text: "󰅂"; font.pixelSize: 13; color: Theme.c.accentDim }
                    }
                    MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onEntered: Menu.selected = row.index; onClicked: Menu.activate(row.modelData) }
                }
                Label { visible: win.rows.length === 0 && !Menu.inputRow; anchors.centerIn: parent; text: "nothing found"; font.pixelSize: 12; color: Theme.c.accentDim }
                Label { visible: !!Menu.inputRow; anchors.centerIn: parent; text: "Enter to set"; font.pixelSize: 12; color: Theme.c.accentDim }
            }
        }
    }
}
