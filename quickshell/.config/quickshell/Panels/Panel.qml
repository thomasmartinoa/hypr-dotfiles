import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.Commons
import qs.Services

// Popup hanging under a bar widget. Themed card; closes when focus leaves
// it (click anywhere else, or Escape).
PopupWindow {
    id: popup
    required property string name
    required property Item anchorItem
    default property alias content: column.data
    property alias backdrop: backdropItem.data   // drawn under the content, clipped to the card
    property int panelWidth: 320
    property int pad: 14
    property alias spacing: column.spacing

    readonly property bool open: Panels.open === name && Panels.item === anchorItem
    visible: open
    color: "transparent"
    implicitWidth: panelWidth
    implicitHeight: card.implicitHeight

    // open away from the bar's edge, so a bottom bar drops its panels upward
    // and a side bar opens them inward instead of off the screen
    readonly property int gap: Theme.barStyle === "pill" ? 10 : 12
    readonly property int awayFromBar: Config.position === "bottom" ? Edges.Top
                                     : Config.position === "left"   ? Edges.Right
                                     : Config.position === "right"  ? Edges.Left
                                                                    : Edges.Bottom
    anchor.item: anchorItem
    anchor.edges: awayFromBar
    anchor.gravity: awayFromBar
    anchor.margins.top:    Config.position === "top"    ? gap : 0
    anchor.margins.bottom: Config.position === "bottom" ? gap : 0
    anchor.margins.left:   Config.position === "left"   ? gap : 0
    anchor.margins.right:  Config.position === "right"  ? gap : 0
    anchor.adjustment: Config.vertical ? PopupAdjustment.SlideY : PopupAdjustment.SlideX

    Component.onCompleted: Panels.register(name, anchorItem)

    HyprlandFocusGrab {
        windows: [popup, anchorItem.QsWindow.window]
        active: popup.open
        onCleared: if (popup.open) Panels.close()
    }

    Rectangle {
        id: card
        width: parent.width
        implicitHeight: column.implicitHeight + popup.pad * 2
        color: Theme.c.bg0
        border.width: 1
        border.color: Theme.c.border
        radius: Theme.radius
        Behavior on color { ColorAnimation { duration: 150 } }

        ClippingRectangle {
            id: backdropItem
            anchors.fill: parent
            anchors.margins: 1
            radius: Math.max(0, Theme.radius - 1)
            color: "transparent"
            visible: children.length > 0
        }
        Column {
            id: column
            x: popup.pad; y: popup.pad
            width: parent.width - popup.pad * 2
            spacing: 10
        }
        Keys.onEscapePressed: Panels.close()
        focus: true
    }
}
