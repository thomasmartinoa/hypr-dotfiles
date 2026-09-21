import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons

// One bar per screen. Two skins, switched live by Theme.barStyle:
//   pill     floating modules with borders, 5/6px off the screen edge
//            (a faithful port of the waybar config this replaces)
//   minimal  a flat 26px strip, Omarchy layout
Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win
        required property var modelData
        screen: modelData

        readonly property bool pill: Theme.barStyle === "pill"

        anchors { top: true; left: true; right: true }
        margins { top: pill ? 5 : 0; left: pill ? 6 : 0; right: pill ? 6 : 0 }
        implicitHeight: pill ? 37 : 26
        color: pill ? "transparent" : Theme.c.bg0
        WlrLayershell.namespace: "hypr-bar"

        Behavior on color { ColorAnimation { duration: 150 } }

        // left ------------------------------------------------------------
        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: win.pill ? 8 : 8     // measured against waybar
            spacing: win.pill ? 8 : 2
            Clock { visible: win.pill }
            Workspaces {}
        }

        // centre ----------------------------------------------------------
        Row {
            anchors.centerIn: parent
            spacing: 6
            Clock { visible: !win.pill }
            Tray { visible: win.pill }
        }

        // right -----------------------------------------------------------
        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: win.pill ? 2 : 8
            spacing: win.pill ? 8 : 2
            Tray { visible: !win.pill }
            Bluetooth { visible: !win.pill }    // pill skin: the tray applet covers it
            Audio {}
            Network {}
            Battery {}
            CaffeineWidget {}
            Bell {}
        }
    }
}
