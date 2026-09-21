import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Commons
import qs.Services

// Popup hanging under a bar widget. Themed card; closes when focus leaves
// it (click anywhere else, or Escape).
PopupWindow {
    id: popup
    required property string name
    required property Item anchorItem
    default property alias content: column.data
    property int panelWidth: 320

    readonly property bool open: Panels.open === name && Panels.item === anchorItem
    visible: open
    color: "transparent"
    implicitWidth: panelWidth
    implicitHeight: card.implicitHeight

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: Theme.barStyle === "pill" ? 4 : 6
    anchor.adjustment: PopupAdjustment.SlideX

    Component.onCompleted: if (!Panels.registry[name]) Panels.register(name, anchorItem)

    HyprlandFocusGrab {
        windows: [popup, anchorItem.QsWindow.window]
        active: popup.open
        onCleared: if (popup.open) Panels.close()
    }

    Rectangle {
        id: card
        width: parent.width
        implicitHeight: column.implicitHeight + 28
        color: Theme.c.bg0
        border.width: 1
        border.color: Theme.c.bg3
        radius: 10
        Behavior on color { ColorAnimation { duration: 150 } }

        Column {
            id: column
            x: 14; y: 14
            width: parent.width - 28
            spacing: 10
        }
        Keys.onEscapePressed: Panels.close()
        focus: true
    }
}
