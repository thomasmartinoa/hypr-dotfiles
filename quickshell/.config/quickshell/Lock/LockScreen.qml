import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Bar
import qs.Services

// The lock screen: the same picture as the login screen — blurred
// wallpaper, big clock, "Hello, user", the grey box with dots.
WlSessionLock {
    id: lock
    locked: Lock.locked

    WlSessionLockSurface {
        id: surf
        color: Theme.c.bg0

        readonly property real s: Math.min(height / 1080, width / 1920)
        readonly property color onWall: Theme.light ? "#141414" : "#ffffff"
        function oc(a) { return Qt.rgba(onWall.r, onWall.g, onWall.b, a) }

        Image {
            id: wall
            anchors.fill: parent
            anchors.margins: -64
            source: "file://" + Wallpaper.path + "?g=" + Wallpaper.generation
            fillMode: Image.PreserveAspectCrop
            cache: false
            visible: false
        }
        MultiEffect {
            anchors.fill: wall
            source: wall
            blurEnabled: true; blur: 1.0; blurMax: 48
            brightness: Theme.light ? 0.05 : -0.18
            contrast: -0.1
        }

        // clock
        SystemClock { id: clock; precision: SystemClock.Minutes }
        Column {
            anchors.top: parent.top; anchors.topMargin: 90 * surf.s
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6 * surf.s
            Label { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatTime(clock.date, "h:mmAP")
                    font.pixelSize: 130 * surf.s; font.weight: Font.Light; color: surf.oc(0.8) }
            Label { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDate(clock.date, "dddd, d MMMM")
                    font.pixelSize: 22 * surf.s; color: surf.oc(0.5) }
        }

        // greeting + password
        Item {
            anchors.centerIn: parent
            width: 340 * surf.s; height: 220 * surf.s

            Label { anchors.horizontalCenter: parent.horizontalCenter; y: 0
                    text: "Hello, " + Quickshell.env("USER"); font.pixelSize: 32 * surf.s; color: surf.oc(0.8) }

            Rectangle {
                id: field
                anchors.horizontalCenter: parent.horizontalCenter
                y: 75 * surf.s
                width: 340 * surf.s; height: 62 * surf.s; radius: 4 * surf.s
                color: Theme.light ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(64/255, 64/255, 64/255, 0.4)
                border.width: 2 * surf.s
                border.color: Lock.error !== "" ? surf.oc(0.9) : Qt.rgba(Theme.c.accentMid.r, Theme.c.accentMid.g, Theme.c.accentMid.b, 0.8)
                opacity: Lock.busy ? 0.5 : 1

                SequentialAnimation {
                    id: shake
                    NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: -10 * surf.s; duration: 40 }
                    NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to:  10 * surf.s; duration: 70 }
                    NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to:  -6 * surf.s; duration: 60 }
                    NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to:   0;          duration: 50 }
                }
                Connections { target: Lock; function onErrorChanged() { if (Lock.error !== "") { shake.restart(); pw.text = "" } } }

                Row {
                    anchors.centerIn: parent
                    spacing: field.height * 0.2
                    Repeater {
                        model: Math.min(pw.text.length, 24)
                        Rectangle { width: field.height * 0.2; height: width; radius: width / 2; color: Theme.light ? Theme.c.fg : "#c8c8c8" }
                    }
                }
                Rectangle {
                    anchors.centerIn: parent; width: 2 * surf.s; height: field.height * 0.4
                    color: surf.oc(0.4); visible: pw.text.length === 0 && !Lock.busy
                    SequentialAnimation on opacity { loops: Animation.Infinite; running: true
                        NumberAnimation { to: 0; duration: 500 } NumberAnimation { to: 1; duration: 500 } }
                }
                TextInput {
                    id: pw
                    anchors.fill: parent; anchors.margins: 10 * surf.s
                    echoMode: TextInput.Password; passwordCharacter: " "
                    color: "transparent"; cursorVisible: false; cursorDelegate: Item {}
                    font.family: Theme.font; font.pixelSize: 24 * surf.s
                    enabled: !Lock.busy
                    focus: true
                    onAccepted: Lock.tryPassword(text)
                    Keys.onEscapePressed: text = ""
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                y: field.y + field.height + 14 * surf.s
                font.pixelSize: 15 * surf.s
                color: surf.oc(Lock.error !== "" ? 0.85 : 0.45)
                text: Lock.busy ? "Checking…" : Lock.error
            }
        }
        // re-focus after anything
        MouseArea { anchors.fill: parent; z: -1; onClicked: pw.forceActiveFocus() }
        Component.onCompleted: pw.forceActiveFocus()
    }
}
