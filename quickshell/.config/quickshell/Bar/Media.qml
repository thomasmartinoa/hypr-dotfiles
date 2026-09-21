import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.Commons

// Now playing (MPRIS). left = play/pause · middle = next · scroll = prev/next
Pill {
    id: media
    readonly property var player: Mpris.players.values.find(p => p.playbackState === MprisPlaybackState.Playing)
                                  || Mpris.players.values.find(p => p.trackTitle) || null
    readonly property bool playing: player && player.playbackState === MprisPlaybackState.Playing
    readonly property string text: player ? [player.trackArtist, player.trackTitle].filter(x => x).join(" – ") : ""
    visible: player !== null
    onClicked: if (player && player.canTogglePlaying) player.togglePlaying()
    onMiddleClicked: if (player && player.canGoNext) player.next()
    onScrolled: (d) => { if (!player) return; if (d > 0 && player.canGoPrevious) player.previous(); else if (d < 0 && player.canGoNext) player.next() }
    Label { text: media.playing ? "󰐊" : "󰏤"; color: media.playing ? Theme.c.accentBright : Theme.c.accentMid }
    Label {
        visible: !media.vertical
        text: media.text.length > 40 ? media.text.substring(0, 39) + "…" : media.text
        color: Theme.c.accentLight
    }
}
