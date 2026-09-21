import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Bar
import qs.Services

// Volume / brightness overlay, bottom centre of the focused screen.
Variants {
    model: Quickshell.screens
    PanelWindow {
        id: win
        required property var modelData
        screen: modelData
        visible: Osd.visible
        anchors.bottom: true
        margins.bottom: 60
        implicitWidth: 260
        implicitHeight: 48
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "hypr-osd"
        mask: Region {}      // click-through

        Rectangle {
            anchors.fill: parent
            radius: Theme.radius
            color: Theme.c.bg0
            border.width: 1
            border.color: Theme.c.border
            opacity: Osd.visible ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }

            readonly property string icon: Osd.kind === "brightness" ? "󰃠"
                                         : Osd.kind === "mic" ? (Osd.muted ? "󰍭" : "󰍬")
                                         : Osd.muted ? "󰝟" : Osd.value < 0.34 ? "󰕿" : Osd.value < 0.67 ? "󰖀" : "󰕾"
            Row {
                anchors.centerIn: parent
                spacing: 12
                Label { text: parent.parent.icon; font.pixelSize: 18; width: 22; color: Osd.muted ? Theme.c.accentDim : Theme.c.accentBright }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 150; height: 6; radius: 3; color: Theme.c.bg3
                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, Osd.value)); height: parent.height; radius: 3
                        color: Osd.muted ? Theme.c.accentDim : Theme.c.fg
                        Behavior on width { NumberAnimation { duration: 80 } }
                    }
                }
                Label { text: Math.round(Osd.value * 100) + "%"; width: 36; horizontalAlignment: Text.AlignRight
                        font.pixelSize: 12; color: Theme.c.accentMid }
            }
        }
    }
}
