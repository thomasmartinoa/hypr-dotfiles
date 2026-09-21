import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Commons

Pill {
    id: tray
    round: true
    interactive: false
    visible: SystemTray.items.values.length > 0
    padH: pillMode ? 12 : 6
    Repeater {
        model: SystemTray.items
        Item {
            id: entry
            required property var modelData
            width: 16; height: 16
            IconImage {
                anchors.fill: parent
                source: entry.modelData.icon
                opacity: entry.modelData.status === Status.Passive ? 0.5 : 1
            }
            QsMenuAnchor {
                id: menu
                menu: entry.modelData.menu
                anchor.item: entry
                anchor.edges: Edges.Bottom
                anchor.gravity: Edges.Bottom
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                cursorShape: Qt.PointingHandCursor
                onClicked: (e) => {
                    if (e.button === Qt.RightButton || entry.modelData.onlyMenu) {
                        if (entry.modelData.hasMenu) menu.open()
                    } else if (e.button === Qt.MiddleButton) entry.modelData.secondaryActivate()
                    else entry.modelData.activate()
                }
                onWheel: (w) => entry.modelData.scroll(w.angleDelta.y, false)
            }
        }
    }
}
