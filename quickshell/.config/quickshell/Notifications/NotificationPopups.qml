import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Services

// Popup stack, top-right, under the bar.
PanelWindow {
    id: win
    visible: Notifs.popups.length > 0
    anchors { top: true; right: true }
    margins { top: Theme.barStyle === "pill" ? 44 : Theme.barStyle === "floating" ? 37 : 32; right: 8 }
    implicitWidth: 380
    implicitHeight: Math.min(stack.implicitHeight, screen.height - 100)
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "hypr-notifications"

    Column {
        id: stack
        width: parent.width
        spacing: 8
        Repeater {
            model: Notifs.popups
            NotificationCard {
                required property var modelData
                entry: modelData
                compact: true
                // slide in
                opacity: 0; x: 20
                Component.onCompleted: { opacity = 1; x = 0 }
                Behavior on opacity { NumberAnimation { duration: 180 } }
                Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            }
        }
    }
}
