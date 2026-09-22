import QtQuick
import Quickshell
import qs.Commons
import qs.Bar
import qs.Panels
import qs.Services

// The bell's panel: history, clear all, do not disturb.
Panel {
    id: p
    name: "notifications"
    panelWidth: 380

    PanelHeader {
        title: Notifs.count > 0 ? "Notifications · " + Notifs.count : "Notifications"
        showToggle: true
        toggle.on: Notifs.dnd
        onToggled: (on) => Notifs.dnd = on
        Label { anchors.right: parent.right; anchors.rightMargin: 48; anchors.verticalCenter: parent.verticalCenter
                text: "Do not disturb"; font.pixelSize: Theme.fs(11); color: Theme.c.accentMid }
    }

    Flickable {
        width: parent.width
        height: Math.min(list.implicitHeight, 520)
        contentHeight: list.implicitHeight
        clip: true
        Column {
            id: list
            width: parent.width
            spacing: 8
            Label { visible: Notifs.count === 0; text: "Nothing here"; font.pixelSize: Theme.fs(12); color: Theme.c.accentMid; padding: 6 }
            Repeater {
                model: Notifs.items
                NotificationCard { required property var modelData; entry: modelData }
            }
        }
    }

    Row {
        width: parent.width; spacing: 8; layoutDirection: Qt.RightToLeft
        PanelButton { visible: Notifs.count > 0; text: "Clear all"; icon: "󰎟"; onClicked: Notifs.clearAll() }
    }
}
