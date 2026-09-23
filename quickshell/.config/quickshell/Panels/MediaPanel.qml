import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.Commons
import qs.Bar

// Now-playing card: a record spinning with the cover art as its label and a
// tonearm that drops on while playing; seek bar, transport, shuffle/loop, and
// a player switcher when more than one MPRIS player is around.
Panel {
    id: p
    name: "media"
    panelWidth: 300

    property var player: null
    signal pick(var player)

    readonly property bool playing: player && player.playbackState === MprisPlaybackState.Playing
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
    Timer { interval: 1000; repeat: true; running: p.open && p.playing; onTriggered: if (p.player) p.player.positionChanged() }
    onOpenChanged: if (open && player) player.positionChanged()

    // the record -----------------------------------------------------
    Item {
        width: parent.width
        height: 176

        Item {
            id: record
            width: 164; height: 164
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -10

            Rectangle {   // vinyl
                anchors.fill: parent
                radius: width / 2
                color: Theme.light ? Theme.c.fg : Theme.c.bg2
                border.width: 1
                border.color: Theme.c.borderStrong
            }
            Repeater {   // grooves
                model: 6
                Rectangle {
                    required property int index
                    readonly property real d: record.width - 14 - index * 11
                    anchors.centerIn: parent
                    width: d; height: d; radius: d / 2
                    color: "transparent"
                    border.width: 1
                    border.color: Theme.alpha(Theme.light ? Theme.c.bg0 : Theme.c.fg, 0.07)
                }
            }

            Item {   // label — the part that visibly turns
                id: label
                width: 86; height: 86
                anchors.centerIn: parent
                NumberAnimation on rotation {
                    from: 0; to: 360; duration: 9000
                    loops: Animation.Infinite
                    running: true
                    paused: !(p.open && p.playing)
                }
                ClippingRectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Theme.c.bg3
                    Image {
                        id: art
                        anchors.fill: parent
                        source: p.player ? p.player.trackArtUrl : ""
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(172, 172)
                        asynchronous: true
                        cache: true
                    }
                    Label {
                        visible: art.status !== Image.Ready
                        anchors.centerIn: parent
                        text: "\u{f075a}"
                        font.pixelSize: Theme.fs(30)
                        color: Theme.c.accentBright
                    }
                    Rectangle {   // a stripe on the fallback label so it reads as turning
                        visible: art.status !== Image.Ready
                        width: parent.width; height: 6
                        y: parent.height * 0.18
                        color: Theme.alpha(Theme.c.fg, 0.12)
                    }
                }
                Rectangle {   // spindle hole
                    anchors.centerIn: parent
                    width: 10; height: 10; radius: 5
                    color: Theme.c.bg0
                    border.width: 1
                    border.color: Theme.c.borderStrong
                }
            }
        }

        Item {   // tonearm, pivoting at its base off the record's top-right
            id: arm
            x: record.x + record.width - 6
            y: record.y - 2
            width: 12; height: 112
            transformOrigin: Item.Top
            rotation: p.playing ? 19 : -6
            Behavior on rotation { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
            Rectangle {   // pivot
                width: 12; height: 12; radius: 6
                color: Theme.c.bg3
                border.width: 1; border.color: Theme.c.borderStrong
            }
            Rectangle {   // arm
                x: 5; y: 8
                width: 2; height: 94
                color: Theme.c.accentMid
            }
            Rectangle {   // head
                x: 2; y: 98
                width: 8; height: 14; radius: 2
                color: Theme.c.accentLight
            }
        }
    }

    // track --------------------------------------------------------------
    Column {
        width: parent.width
        spacing: 2
        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: p.player ? (p.player.trackTitle || p.player.identity || "Unknown") : "Nothing playing"
            font.pixelSize: Theme.fs(14); font.weight: Font.Bold
            color: Theme.c.accentBright
        }
        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            visible: text !== ""
            text: p.player ? [p.player.trackArtist, p.player.trackAlbum].filter(x => x).join(" · ") : ""
            font.pixelSize: Theme.fs(12)
            color: Theme.c.accentMid
        }
    }

    // seek bar -----------------------------------------------------------
    Column {
        width: parent.width
        spacing: 2
        visible: p.player && p.player.lengthSupported && p.player.length > 0
        Slider {
            value: p.player && p.player.length > 0 ? p.player.position / p.player.length : 0
            onMoved: (v) => { if (p.player && p.player.canSeek) p.player.position = v * p.player.length }
        }
        Item {
            width: parent.width; height: 14
            Label { anchors.left: parent.left; text: p.player ? p.time(p.player.position) : ""; font.pixelSize: Theme.fs(10); color: Theme.c.accentDim }
            Label { anchors.right: parent.right; text: p.player ? p.time(p.player.length) : ""; font.pixelSize: Theme.fs(10); color: Theme.c.accentDim }
        }
    }

    // transport ----------------------------------------------------------
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 14

        component Btn: Rectangle {
            id: b
            property string glyph: ""
            property bool enabledState: true
            property bool on: false
            property bool big: false
            signal tap()
            width: big ? 46 : 34; height: width
            anchors.verticalCenter: parent.verticalCenter
            radius: width / 2
            opacity: enabledState ? 1 : 0.35
            color: big ? (bm.containsMouse ? Theme.c.accentLight : Theme.c.fg)
                       : (bm.containsMouse ? Theme.c.bg3 : "transparent")
            border.width: big ? 0 : (bm.containsMouse ? 1 : 0)
            border.color: Theme.c.border
            Behavior on color { ColorAnimation { duration: 120 } }
            Label {
                anchors.centerIn: parent
                text: b.glyph
                font.pixelSize: Theme.fs(b.big ? 22 : 17)
                color: b.big ? Theme.c.bg0 : b.on ? Theme.c.accentBright : Theme.c.accentMid
            }
            MouseArea { id: bm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        enabled: b.enabledState; onClicked: b.tap() }
        }

        Btn {
            visible: p.player && p.player.shuffleSupported
            glyph: p.player && p.player.shuffle ? "\u{f049d}" : "\u{f049e}"
            on: p.player && p.player.shuffle
            onTap: p.player.shuffle = !p.player.shuffle
        }
        Btn {
            glyph: "\u{f04ae}"
            enabledState: p.player && p.player.canGoPrevious
            onTap: p.player.previous()
        }
        Btn {
            big: true
            glyph: p.playing ? "\u{f03e4}" : "\u{f040a}"
            enabledState: p.player && p.player.canTogglePlaying
            onTap: p.player.togglePlaying()
        }
        Btn {
            glyph: "\u{f04ad}"
            enabledState: p.player && p.player.canGoNext
            onTap: p.player.next()
        }
        Btn {
            visible: p.player && p.player.loopSupported
            readonly property int ls: p.player ? p.player.loopState : MprisLoopState.None
            glyph: ls === MprisLoopState.Track ? "\u{f0458}" : ls === MprisLoopState.Playlist ? "\u{f0456}" : "\u{f0457}"
            on: ls !== MprisLoopState.None
            onTap: p.player.loopState = ls === MprisLoopState.None ? MprisLoopState.Playlist
                                      : ls === MprisLoopState.Playlist ? MprisLoopState.Track : MprisLoopState.None
        }
    }

    // player switcher ----------------------------------------------------
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
                width: chipText.implicitWidth + 18; height: 24
                radius: Theme.radius
                color: current ? Theme.c.bg3 : cm.containsMouse ? Theme.c.bg2 : "transparent"
                border.width: 1
                border.color: current ? Theme.c.borderStrong : Theme.c.border
                Label {
                    id: chipText
                    anchors.centerIn: parent
                    text: chip.modelData.identity || chip.modelData.desktopEntry || "player"
                    font.pixelSize: Theme.fs(11)
                    color: chip.current ? Theme.c.accentBright : Theme.c.accentMid
                }
                MouseArea { id: cm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: p.pick(chip.modelData) }
            }
        }
    }
}
