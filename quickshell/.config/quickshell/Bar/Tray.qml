import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Commons
import qs.Services
import qs.Panels

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
            TrayMenu {
                id: menu
                name: "tray:" + (entry.modelData.id || entry.modelData.title)
                anchorItem: entry
                handle: entry.modelData.menu
                title: entry.modelData.title || entry.modelData.tooltipTitle || entry.modelData.id
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                cursorShape: Qt.PointingHandCursor
                onClicked: (e) => {
                    if (e.button === Qt.RightButton || entry.modelData.onlyMenu) {
                        if (entry.modelData.hasMenu) Panels.toggle(menu.name, entry)
                    } else if (e.button === Qt.MiddleButton) entry.modelData.secondaryActivate()
                    else entry.modelData.activate()
                }
                onWheel: (w) => entry.modelData.scroll(w.angleDelta.y, false)
            }
        }
    }
}
