import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.Commons
import qs.Services
import qs.Panels

// Now playing (MPRIS). left = player card · middle = play/pause · scroll = prev/next
Pill {
    id: media
    property var pinned: null   // chosen in the card's player switcher
    readonly property var player: (pinned && Mpris.players.values.includes(pinned)) ? pinned
                                  : Mpris.players.values.find(p => p.playbackState === MprisPlaybackState.Playing)
                                  || Mpris.players.values.find(p => p.trackTitle) || null
    readonly property bool playing: player && player.playbackState === MprisPlaybackState.Playing
    readonly property string text: player ? [player.trackArtist, player.trackTitle].filter(x => x).join(" – ") : ""
    visible: player !== null
    onClicked: Panels.toggle("media", media)
    onMiddleClicked: if (player && player.canTogglePlaying) player.togglePlaying()
    onScrolled: (d) => { if (!player) return; if (d > 0 && player.canGoPrevious) player.previous(); else if (d < 0 && player.canGoNext) player.next() }

    Item {
        width: 16; height: 16
        ClippingRectangle {
            anchors.fill: parent
            visible: thumb.status === Image.Ready
            radius: width / 2
            color: "transparent"
            opacity: media.playing ? 1 : 0.5
            Image {
                id: thumb
                anchors.fill: parent
                source: media.player ? media.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(48, 48)
                asynchronous: true
            }
        }
        Label {
            anchors.centerIn: parent
            visible: thumb.status !== Image.Ready
            text: media.playing ? "󰐊" : "󰏤"
            color: media.playing ? Theme.c.accentBright : Theme.c.accentMid
        }
    }
    Label {
        visible: !media.vertical
        text: media.text.length > 40 ? media.text.substring(0, 39) + "…" : media.text
        color: Theme.c.accentLight
    }

    MediaPanel { anchorItem: media; player: media.player; onPick: (pl) => media.pinned = pl }
}
