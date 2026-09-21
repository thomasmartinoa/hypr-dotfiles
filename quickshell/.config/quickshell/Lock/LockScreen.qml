import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import qs.Commons
import qs.Bar
import qs.Services

// The lock screen — a faithful port of hyprlock.conf. hyprlock measures in
// physical pixels (font_size in points at physical DPI), so every size here
// is that value divided by the screen's device pixel ratio.
WlSessionLock {
    id: lock
    locked: Lock.locked

    WlSessionLockSurface {
        id: surf
        color: Theme.c.bg0

        // Qt rounds the Wayland scale (1.6 reports as 2); Hyprland has the real one.
        readonly property var hyprMon: screen ? Hyprland.monitorFor(screen) : null
        readonly property real dpr: hyprMon && hyprMon.scale > 0 ? hyprMon.scale : (screen ? screen.devicePixelRatio : 1)
        function px(physical) { return physical / dpr }              // hyprlock size / position
        function pt(size) { return size * 4 / 3 / dpr }               // hyprlock font_size (points)
        readonly property color onWall: Theme.light ? "#141414" : "#ffffff"
        function oc(a) { return Qt.rgba(onWall.r, onWall.g, onWall.b, a) }

        // background: blur_passes = 4, brightness 0.8172, contrast 0.8916.
        // A quarter-resolution source + max blur gives hyprlock's haze.
        Image {
            id: wall
            anchors.fill: parent
            anchors.margins: -64
            source: "file://" + Wallpaper.path + "?g=" + Wallpaper.generation
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(Math.round(width / 8), Math.round(height / 8))
            cache: false
            visible: false
        }
        MultiEffect {
            anchors.fill: wall
            source: wall
            blurEnabled: true; blur: 1.0; blurMax: 64
            brightness: Theme.light ? 0.02 : -0.02
            contrast: -0.11
            saturation: 0.17
        }

        // TIME — label: font_size 100, position 0,-90, valign top
        SystemClock { id: clock; precision: SystemClock.Minutes }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            y: surf.px(90)
            text: Qt.formatTime(clock.date, "h:mmAP")
            font.pixelSize: surf.pt(100)
            font.weight: Font.Normal
            color: surf.oc(0.8)
        }

        // USER — label: font_size 25, position 0,0, centre
        Label {
            anchors.centerIn: parent
            text: "Hello, " + Quickshell.env("USER")
            font.pixelSize: surf.pt(25)
            color: surf.oc(0.8)
        }

        // INPUT FIELD — size 340,62, rounding 5, outline 2, position 0,-75
        Rectangle {
            id: field
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: surf.px(75)
            width: surf.px(340); height: surf.px(62); radius: surf.px(5)
            color: Theme.light ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(64/255, 64/255, 64/255, 0.4)
            border.width: Math.max(1, surf.px(2))
            border.color: Lock.error !== "" ? surf.oc(0.9)
                        : Theme.light ? Qt.rgba(Theme.c.accentMid.r, Theme.c.accentMid.g, Theme.c.accentMid.b, 0.8)
                        : Qt.rgba(207/255, 207/255, 207/255, 0.6)
            opacity: Lock.busy ? 0.5 : 1

            SequentialAnimation {
                id: shake
                NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: -surf.px(10); duration: 40 }
                NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to:  surf.px(10); duration: 70 }
                NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: -surf.px(6);  duration: 60 }
                NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to:  0;           duration: 50 }
            }
            Connections { target: Lock; function onErrorChanged() { if (Lock.error !== "") { shake.restart(); pw.text = "" } } }

            // dots_size 0.2, dots_spacing 1.0, dots_center
            Row {
                anchors.centerIn: parent
                spacing: field.height * 0.2
                Repeater {
                    model: Math.min(pw.text.length, 24)
                    Rectangle { width: field.height * 0.2; height: width; radius: width / 2
                                color: Theme.light ? Theme.c.fg : "#c8c8c8" }
                }
            }
            TextInput {
                id: pw
                anchors.fill: parent; anchors.margins: surf.px(10)
                echoMode: TextInput.Password; passwordCharacter: " "
                color: "transparent"; cursorVisible: false; cursorDelegate: Item {}
                font.family: Theme.font; font.pixelSize: surf.pt(18)
                enabled: !Lock.busy
                focus: true
                onAccepted: Lock.tryPassword(text)
                Keys.onEscapePressed: text = ""
            }
        }

        // fail / checking text under the field (hyprlock shows it in the field; keep it small)
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: field.bottom; anchors.topMargin: surf.px(14)
            font.pixelSize: surf.pt(12)
            color: surf.oc(Lock.error !== "" ? 0.85 : 0.45)
            text: Lock.busy ? "Checking…" : Lock.error
        }

        // CURRENT SONG — label: font_size 16, position 0,80, valign bottom
        readonly property var player: Mpris.players.values.find(p => p.playbackState === MprisPlaybackState.Playing) || Mpris.players.values[0] || null
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom; anchors.bottomMargin: surf.px(80)
            font.pixelSize: surf.pt(16)
            color: Qt.rgba(200/255, 200/255, 200/255, 0.75)
            visible: text !== ""
            text: surf.player && surf.player.trackTitle ? surf.player.trackTitle + "    " + (surf.player.trackArtist || "") : ""
        }

        MouseArea { anchors.fill: parent; z: -1; onClicked: pw.forceActiveFocus() }
        Component.onCompleted: pw.forceActiveFocus()
    }
}
