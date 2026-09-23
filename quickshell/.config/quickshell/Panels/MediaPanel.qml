import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.Commons
import qs.Bar
import qs.Services

// Now-playing card: a record spinning with the cover art as its label, a
// tonearm that drops on while playing, the cover blurred into the card as an
// ambient glow; seek, transport, shuffle/loop, player switcher.
Panel {
    id: p
    name: "media"
    panelWidth: 320
    pad: 16
    spacing: 12

    property var player: null
    signal pick(var player)

    readonly property bool playing: player && player.playbackState === MprisPlaybackState.Playing
    readonly property string art: player ? player.trackArtUrl : ""
    // some players (VLC) register twice on the bus; show each once
    readonly property var players: {
        const seen = {}, out = []
        for (const pl of Mpris.players.values) {
            const k = [pl.identity, pl.trackTitle, pl.trackArtist].join("|")
            if (seen[k]) continue
            seen[k] = true; out.push(pl)
        }
        return out
    }

    function time(s) {
        if (!(s > 0)) return "0:00"
        s = Math.floor(s)
        const h = Math.floor(s / 3600), m = Math.floor(s / 60) % 60, sec = s % 60
        return (h ? h + ":" + String(m).padStart(2, "0") : m) + ":" + String(sec).padStart(2, "0")
    }

    // MPRIS doesn't push position updates; poll while the card is visible
    Timer { interval: 500; repeat: true; running: p.open && p.playing; onTriggered: if (p.player) p.player.positionChanged() }
    onOpenChanged: if (open && player) player.positionChanged()

    // ambient glow: the cover, blurred, behind everything ---------------
    backdrop: [
        Image {
            id: glowSrc
            anchors.fill: parent
            source: p.art
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(96, 96)
            asynchronous: true
            visible: false
        },
        MultiEffect {
            anchors.fill: parent
            anchors.margins: -40
            source: glowSrc
            visible: glowSrc.status === Image.Ready
            autoPaddingEnabled: false
            blurEnabled: true; blur: 1.0; blurMax: 64
            saturation: Theme.hued ? 0.15 : -1   // mono themes stay grey
            opacity: Theme.light ? 0.35 : 0.5
            Behavior on opacity { NumberAnimation { duration: 400 } }
        },
        Rectangle {   // fade to the card colour so text stays readable
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.alpha(Theme.c.bg0, 0.30) }
                GradientStop { position: 0.55; color: Theme.alpha(Theme.c.bg0, 0.75) }
                GradientStop { position: 1.0; color: Theme.alpha(Theme.c.bg0, 0.94) }
            }
        }
    ]

    // header: which app ------------------------------------------------
    Item {
        width: parent.width; height: 20
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 7
            IconImage {
                id: appIcon
                anchors.verticalCenter: parent.verticalCenter
                width: 14; height: 14
                source: p.player && p.player.desktopEntry ? Quickshell.iconPath(p.player.desktopEntry, true) : ""
                visible: source != ""
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: (p.playing ? "Now playing" : "Paused") + (p.player && p.player.identity ? "  ·  " + p.player.identity : "")
                font.pixelSize: Theme.fs(10); font.weight: Font.Bold; font.letterSpacing: 0.6
                color: Theme.c.accentMid
            }
        }
        Rectangle {
            visible: p.player && p.player.canRaise
            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
            width: 22; height: 22; radius: Theme.radius
            color: raise.containsMouse ? Theme.alpha(Theme.c.fg, 0.10) : "transparent"
            Label { anchors.centerIn: parent; text: "\u{f03cc}"; font.pixelSize: Theme.fs(12)
                    color: raise.containsMouse ? Theme.c.accentBright : Theme.c.accentMid }
            MouseArea { id: raise; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: { p.player.raise(); Panels.close() } }
        }
    }

    // the record -------------------------------------------------------
    Item {
        width: parent.width
        height: 196

        Item {
            id: record
            width: 184; height: 184
            anchors.centerIn: parent
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "black"
                shadowOpacity: Theme.light ? 0.25 : 0.55
                shadowBlur: 0.9
                shadowVerticalOffset: 4
            }

            Rectangle {   // vinyl
                anchors.fill: parent
                radius: width / 2
                color: Theme.light ? Theme.c.fg : Theme.c.bg1
                border.width: 1
                border.color: Theme.alpha(Theme.light ? Theme.c.bg0 : Theme.c.fg, 0.14)
            }
            Repeater {   // grooves, alternating so they read as texture
                model: 12
                Rectangle {
                    required property int index
                    readonly property real d: record.width - 10 - index * 7.5
                    anchors.centerIn: parent
                    width: d; height: d; radius: d / 2
                    color: "transparent"
                    border.width: 1
                    border.color: Theme.alpha(Theme.light ? Theme.c.bg0 : Theme.c.fg, index % 3 === 0 ? 0.09 : 0.04)
                }
            }
            Shape {   // light catching the grooves — fixed while the record turns
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                    strokeWidth: 0; strokeColor: "transparent"
                    fillGradient: ConicalGradient {
                        id: sheen
                        centerX: record.width / 2; centerY: record.height / 2; angle: 35
                        readonly property color hi: Theme.alpha(Theme.light ? Theme.c.bg0 : Theme.c.fg, 0.13)
                        readonly property color lo: Theme.alpha(Theme.c.fg, 0)
                        GradientStop { position: 0.00; color: sheen.lo }
                        GradientStop { position: 0.08; color: sheen.hi }
                        GradientStop { position: 0.18; color: sheen.lo }
                        GradientStop { position: 0.50; color: sheen.lo }
                        GradientStop { position: 0.58; color: sheen.hi }
                        GradientStop { position: 0.68; color: sheen.lo }
                        GradientStop { position: 1.00; color: sheen.lo }
                    }
                    PathAngleArc { centerX: record.width / 2; centerY: record.height / 2
                                   radiusX: record.width / 2 - 1; radiusY: record.height / 2 - 1
                                   startAngle: 0; sweepAngle: 360 }
                }
            }

            Item {   // label — the part that visibly turns
                id: label
                width: 88; height: 88
                anchors.centerIn: parent
                NumberAnimation on rotation {
                    from: 0; to: 360; duration: 7000
                    loops: Animation.Infinite
                    running: true
                    paused: !(p.open && p.playing)
                }
                ClippingRectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Theme.c.bg3
                    Image {
                        id: cover
                        anchors.fill: parent
                        source: p.art
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(176, 176)
                        asynchronous: true
                        opacity: status === Image.Ready ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                    }
                    Label {
                        visible: cover.status !== Image.Ready
                        anchors.centerIn: parent
                        text: "\u{f075a}"
                        font.pixelSize: Theme.fs(30)
                        color: Theme.c.accentBright
                    }
                    Rectangle {   // a stripe on the fallback label so it reads as turning
                        visible: cover.status !== Image.Ready
                        width: parent.width; height: 6
                        y: parent.height * 0.18
                        color: Theme.alpha(Theme.c.fg, 0.12)
                    }
                }
                Rectangle {   // label rim
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.width: 2
                    border.color: Theme.alpha(Theme.light ? Theme.c.fg : Theme.c.bg0, 0.55)
                }
                Rectangle {   // spindle
                    anchors.centerIn: parent
                    width: 11; height: 11; radius: 5.5
                    color: Theme.c.bg0
                    border.width: 2
                    border.color: Theme.c.accentMid
                }
            }
        }

        Rectangle {   // tonearm base
            id: base
            width: 26; height: 26; radius: 13
            x: record.x + record.width - 8
            y: record.y - 2
            color: Theme.c.bg2
            border.width: 1; border.color: Theme.c.borderStrong
        }
        Item {   // tonearm, pivoting on the base
            x: base.x + base.width / 2 - width / 2
            y: base.y + base.height / 2
            width: 16; height: 136
            transformOrigin: Item.Top
            rotation: p.playing ? 22 : -4
            Behavior on rotation { NumberAnimation { duration: 700; easing.type: Easing.OutBack; easing.overshoot: 0.8 } }

            Rectangle {   // counterweight, behind the pivot
                x: 3; y: -22; width: 10; height: 16; radius: 2
                color: Theme.c.bg3
                border.width: 1; border.color: Theme.c.borderStrong
            }
            Rectangle {   // tube
                x: 6.5; y: -6; width: 3; height: 118; radius: 1.5
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: Theme.c.accentDim }
                    GradientStop { position: 0.5; color: Theme.c.accentLight }
                    GradientStop { position: 1; color: Theme.c.accentDim }
                }
            }
            Rectangle {   // pivot cap
                x: 3; y: -5; width: 10; height: 10; radius: 5
                color: Theme.c.accentMid
            }
            Rectangle {   // headshell
                x: 2; y: 110; width: 12; height: 22; radius: 2
                rotation: 18
                color: Theme.c.accentLight
                border.width: 1; border.color: Theme.c.borderStrong
            }
        }
    }

    // track ------------------------------------------------------------
    Column {
        width: parent.width
        spacing: 3
        Item {   // title, scrolling when it doesn't fit
            id: marquee
            width: parent.width; height: titleText.implicitHeight
            clip: true
            readonly property real overflow: Math.max(0, titleText.implicitWidth - width)
            property real offset: 0
            Label {
                id: titleText
                x: marquee.overflow > 0 ? -marquee.offset : (marquee.width - implicitWidth) / 2
                text: p.player ? (p.player.trackTitle || p.player.identity || "Unknown") : "Nothing playing"
                font.pixelSize: Theme.fs(15); font.weight: Font.Bold
                color: Theme.c.accentBright
                onTextChanged: { marquee.offset = 0; scroll.restart() }
            }
            SequentialAnimation {
                id: scroll
                running: p.open && marquee.overflow > 0
                loops: Animation.Infinite
                PauseAnimation { duration: 2200 }
                NumberAnimation { target: marquee; property: "offset"; to: marquee.overflow; duration: marquee.overflow * 28; easing.type: Easing.InOutSine }
                PauseAnimation { duration: 1400 }
                NumberAnimation { target: marquee; property: "offset"; to: 0; duration: marquee.overflow * 28; easing.type: Easing.InOutSine }
            }
        }
        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            visible: text !== ""
            text: p.player ? (p.player.trackArtist || "") : ""
            font.pixelSize: Theme.fs(12)
            color: Theme.c.accentLight
        }
        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            visible: text !== ""
            text: p.player ? (p.player.trackAlbum || "") : ""
            font.pixelSize: Theme.fs(11)
            color: Theme.c.accentMid
        }
    }

    // seek bar ---------------------------------------------------------
    Column {
        width: parent.width
        spacing: 4
        visible: p.player && p.player.lengthSupported && p.player.length > 0
        Item {
            id: seek
            width: parent.width; height: 14
            readonly property real frac: dragging ? dragFrac
                                       : (p.player && p.player.length > 0 ? Math.min(1, p.player.position / p.player.length) : 0)
            property bool dragging: false
            property real dragFrac: 0
            readonly property bool hot: seekArea.containsMouse || dragging
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width; height: seek.hot ? 5 : 3; radius: height / 2
                color: Theme.alpha(Theme.c.fg, 0.15)
                Behavior on height { NumberAnimation { duration: 120 } }
                Rectangle {
                    width: parent.width * seek.frac; height: parent.height; radius: parent.radius
                    color: Theme.c.accentBright
                }
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                x: seek.width * seek.frac - width / 2
                width: 12; height: 12; radius: 6
                color: Theme.c.accentBright
                scale: seek.hot ? 1 : 0
                Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }
            }
            MouseArea {
                id: seekArea
                anchors.fill: parent
                anchors.topMargin: -4; anchors.bottomMargin: -4
                hoverEnabled: true
                enabled: p.player && p.player.canSeek
                cursorShape: Qt.PointingHandCursor
                function at(x) { return Math.max(0, Math.min(1, x / seek.width)) }
                onPressed: (e) => { seek.dragFrac = at(e.x); seek.dragging = true }
                onPositionChanged: (e) => { if (seek.dragging) seek.dragFrac = at(e.x) }
                onReleased: { if (p.player) p.player.position = seek.dragFrac * p.player.length; seek.dragging = false }
            }
        }
        Item {
            width: parent.width; height: 14
            readonly property real shown: p.player ? seek.frac * p.player.length : 0
            Label { anchors.left: parent.left; text: p.time(parent.shown); font.pixelSize: Theme.fs(10); color: Theme.c.accentMid }
            Label { anchors.right: parent.right; text: p.player ? "-" + p.time(p.player.length - parent.shown) : ""
                    font.pixelSize: Theme.fs(10); color: Theme.c.accentMid }
        }
    }

    // transport --------------------------------------------------------
    Item {
        width: parent.width; height: 56

        component Btn: Rectangle {
            id: b
            property string glyph: ""
            property bool enabledState: true
            property bool on: false
            property bool big: false
            property bool small: false
            signal tap()
            width: big ? 54 : small ? 30 : 38; height: width
            radius: width / 2
            opacity: enabledState ? 1 : 0.35
            color: big ? (bm.containsMouse ? Theme.c.accentLight : Theme.c.accentBright)
                       : (bm.containsMouse ? Theme.alpha(Theme.c.fg, 0.10) : "transparent")
            scale: bm.pressed ? 0.88 : 1
            Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutQuad } }
            Behavior on color { ColorAnimation { duration: 120 } }
            Rectangle {   // soft ring around the play button
                visible: b.big
                anchors.centerIn: parent
                width: parent.width + 8; height: width; radius: width / 2
                color: "transparent"
                border.width: 1
                border.color: Theme.alpha(Theme.c.fg, bm.containsMouse ? 0.30 : 0.14)
            }
            Label {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: b.big && !p.playing ? 2 : 0   // optical centre of ▶
                text: b.glyph
                font.pixelSize: Theme.fs(b.big ? 24 : b.small ? 15 : 19)
                color: b.big ? Theme.c.bg0 : b.on ? Theme.c.accentBright : b.small ? Theme.c.accentMid : Theme.c.accentLight
            }
            Rectangle {   // "on" dot under shuffle/loop
                visible: b.small && b.on
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom; anchors.bottomMargin: 1
                width: 4; height: 4; radius: 2
                color: Theme.c.accentBright
            }
            MouseArea { id: bm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        enabled: b.enabledState; onClicked: b.tap() }
        }

        Row {
            anchors.centerIn: parent
            spacing: 16
            Btn {
                small: true
                anchors.verticalCenter: parent.verticalCenter
                enabledState: p.player && p.player.shuffleSupported
                glyph: "\u{f049d}"
                on: p.player && p.player.shuffleSupported && p.player.shuffle
                onTap: p.player.shuffle = !p.player.shuffle
            }
            Btn {
                anchors.verticalCenter: parent.verticalCenter
                glyph: "\u{f04ae}"
                enabledState: p.player && p.player.canGoPrevious
                onTap: p.player.previous()
            }
            Btn {
                big: true
                anchors.verticalCenter: parent.verticalCenter
                glyph: p.playing ? "\u{f03e4}" : "\u{f040a}"
                enabledState: p.player && p.player.canTogglePlaying
                onTap: p.player.togglePlaying()
            }
            Btn {
                anchors.verticalCenter: parent.verticalCenter
                glyph: "\u{f04ad}"
                enabledState: p.player && p.player.canGoNext
                onTap: p.player.next()
            }
            Btn {
                small: true
                anchors.verticalCenter: parent.verticalCenter
                enabledState: p.player && p.player.loopSupported
                readonly property int ls: p.player && p.player.loopSupported ? p.player.loopState : MprisLoopState.None
                glyph: ls === MprisLoopState.Track ? "\u{f0458}" : "\u{f0456}"
                on: ls !== MprisLoopState.None
                onTap: p.player.loopState = ls === MprisLoopState.None ? MprisLoopState.Playlist
                                          : ls === MprisLoopState.Playlist ? MprisLoopState.Track : MprisLoopState.None
            }
        }
    }

    // player switcher --------------------------------------------------
    Flow {
        width: parent.width
        spacing: 6
        visible: p.players.length > 1
        Repeater {
            model: p.players
            Rectangle {
                id: chip
                required property var modelData
                readonly property bool current: modelData === p.player
                width: chipRow.implicitWidth + 18; height: 26
                radius: Theme.radius
                color: current ? Theme.alpha(Theme.c.fg, 0.12) : cm.containsMouse ? Theme.alpha(Theme.c.fg, 0.06) : "transparent"
                border.width: 1
                border.color: current ? Theme.c.borderStrong : Theme.c.border
                Row {
                    id: chipRow
                    anchors.centerIn: parent
                    spacing: 6
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: chip.modelData.playbackState === MprisPlaybackState.Playing ? "\u{f040a}" : "\u{f03e4}"
                        font.pixelSize: Theme.fs(10)
                        color: chip.current ? Theme.c.accentBright : Theme.c.accentDim
                    }
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: chip.modelData.identity || chip.modelData.desktopEntry || "player"
                        font.pixelSize: Theme.fs(11)
                        color: chip.current ? Theme.c.accentBright : Theme.c.accentMid
                    }
                }
                MouseArea { id: cm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: p.pick(chip.modelData) }
            }
        }
    }
}
