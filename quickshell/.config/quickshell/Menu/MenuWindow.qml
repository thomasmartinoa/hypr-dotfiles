import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Bar
import qs.Services

// The menu overlay: the launcher's card, a breadcrumb chip, a search box
// that searches every leaf from anywhere, and ten rows. ↑↓ / Tab move,
// Enter opens or runs, Backspace on an empty box goes up, 1–9 jump, Esc.
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

        readonly property int rowsMax: 11
        readonly property var rows: Menu.rows
        // the card fits its rows (at least three), like a menu should
        readonly property int rowsShown: Math.max(3, Math.min(rowsMax, rows.length))
        onVisibleChanged: if (visible) { input.text = ""; input.forceActiveFocus() }
        Connections { target: Menu
            function onPathChanged() { input.text = "" }
            function onInputRowChanged() { input.text = "" }
            function onQueryChanged() { if (input.text !== Menu.query) input.text = Menu.query } }

        MouseArea { anchors.fill: parent; onClicked: Menu.close() }

        Rectangle {
            id: card
            anchors.centerIn: parent
            width: 620
            height: 14 + 30 + 6 + win.rowsShown * 38 + (win.rowsShown - 1) * 2 + 14
            Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            radius: Theme.radius
            color: Theme.alpha(Theme.c.bg0, 0.74)
            border.width: 1; border.color: Theme.alpha(Theme.c.accentLight, 0.17)

            Item {
                id: bar
                x: 14; y: 14; width: parent.width - 28; height: 30
                Rectangle {
                    id: chip
                    anchors.verticalCenter: parent.verticalCenter
                    width: crumb.implicitWidth + 20; height: 26; radius: Theme.radiusSm
                    color: Theme.c.accentLight
                    Label { id: crumb; anchors.centerIn: parent; text: Menu.crumb; font.pixelSize: 12; font.weight: Font.DemiBold; color: Theme.c.bg0 }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Menu.up() }
                }
                TextInput {
                    id: input
                    anchors.left: chip.right; anchors.leftMargin: 12
                    anchors.right: parent.right; anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.font; font.pixelSize: 13; color: Theme.c.accentBright
                    focus: true
                    onTextChanged: { if (!Menu.inputRow) { Menu.query = text; card.selectedReset() } }
                    Label { visible: !input.text; anchors.verticalCenter: parent.verticalCenter; text: Menu.placeholder; font.pixelSize: 13; color: Theme.c.accentMid }
                    Keys.onPressed: (e) => {
                        const n = win.rows.length
                        if (e.key === Qt.Key_Escape) { if (Menu.inputRow || input.text !== "") Menu.up(); else Menu.close(); e.accepted = true; return }
                        if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                            if (Menu.inputRow) Menu.submitInput(input.text); else if (n) Menu.activate(win.rows[Menu.selected])
                            e.accepted = true; return
                        }
                        if (e.key === Qt.Key_Backspace && input.text === "") { Menu.up(); e.accepted = true; return }
                        if (e.key === Qt.Key_Right && !Menu.inputRow && n && win.rows[Menu.selected].sub) { Menu.activate(win.rows[Menu.selected]); e.accepted = true; return }
                        if (e.key === Qt.Key_Left && !Menu.inputRow && input.text === "") { Menu.up(); e.accepted = true; return }
                        if (n === 0 || Menu.inputRow) return
                        if (e.key === Qt.Key_Down || e.key === Qt.Key_Tab) { Menu.selected = (Menu.selected + 1) % n; e.accepted = true }
                        else if (e.key === Qt.Key_Up || e.key === Qt.Key_Backtab) { Menu.selected = (Menu.selected + n - 1) % n; e.accepted = true }
                        else if (input.text === "" && e.key >= Qt.Key_1 && e.key <= Qt.Key_9) {
                            const i = e.key - Qt.Key_1
                            if (i < n) { Menu.selected = i; Menu.activate(win.rows[i]) }
                            e.accepted = true
                        }
                    }
                }
            }
            function selectedReset() { Menu.selected = 0 }

            ListView {
                id: list
                x: 14; y: bar.y + bar.height + 6
                width: parent.width - 28
                height: win.rowsShown * 38 + (win.rowsShown - 1) * 2
                clip: true; spacing: 2
                model: win.rows
                currentIndex: Menu.selected
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool sel: index === Menu.selected
                    width: list.width; height: 38
                    radius: Theme.radius
                    color: sel ? Theme.c.bg2 : "transparent"
                    Rectangle { visible: row.sel; width: 3; height: parent.height; radius: 1; color: Theme.c.accentBright }
                    Label {
                        id: num
                        visible: Menu.query === "" && row.index < 9
                        x: 12; anchors.verticalCenter: parent.verticalCenter
                        text: row.index + 1; font.pixelSize: 10; color: Theme.c.accentDim
                    }
                    Label {
                        id: ic
                        x: 30; anchors.verticalCenter: parent.verticalCenter; width: 22
                        text: row.modelData.icon; font.pixelSize: 15
                        color: row.sel ? Theme.c.accentBright : Theme.c.accentMid
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Column {
                        anchors.left: ic.right; anchors.leftMargin: 10
                        anchors.right: right.left; anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0
                        Label { width: parent.width; elide: Text.ElideRight; text: row.modelData.label; font.pixelSize: 13
                                color: row.sel ? Theme.c.accentBright : Theme.c.fg }
                        Label { visible: row.modelData.crumb !== "" && Menu.query !== ""; width: parent.width; elide: Text.ElideRight
                                text: row.modelData.crumb; font.pixelSize: 10; color: Theme.c.accentMid }
                    }
                    Row {
                        id: right
                        anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter
                        spacing: 8
                        Label { visible: row.modelData.value !== ""; text: row.modelData.value; font.pixelSize: 11; color: Theme.c.accentMid
                                elide: Text.ElideRight; width: Math.min(implicitWidth, 220) }
                        Label { visible: row.modelData.checked === true; text: "󰄬"; font.pixelSize: 14; color: Theme.c.accentBright }
                        Label { visible: row.modelData.checked === false && row.modelData.value === ""; text: ""; width: 0 }
                        Label { visible: row.modelData.sub; text: "󰅂"; font.pixelSize: 14; color: Theme.c.accentDim }
                        Label { visible: row.modelData.input !== ""; text: "󰌌"; font.pixelSize: 13; color: Theme.c.accentDim }
                    }
                    MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onEntered: Menu.selected = row.index; onClicked: Menu.activate(row.modelData) }
                }
                Label { visible: win.rows.length === 0 && !Menu.inputRow; anchors.centerIn: parent; text: "nothing matches"; font.pixelSize: 12; color: Theme.c.accentMid }
                Label { visible: !!Menu.inputRow; anchors.centerIn: parent; width: parent.width - 40; wrapMode: Text.Wrap; horizontalAlignment: Text.AlignHCenter
                        text: Menu.inputRow ? "type, then Enter  ·  Esc back" : ""; font.pixelSize: 12; color: Theme.c.accentMid }
            }
        }
    }
}
