import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.Commons
import qs.Services
import qs.Panels

Pill {
    id: audio
    extraRight: pillMode ? 1 : 0     // Qt draws the glyph ~1px narrower than GTK did
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink && sink.audio
    readonly property real vol: ready ? sink.audio.volume : 0
    readonly property bool muted: ready ? sink.audio.muted : false
    readonly property string icon: muted ? "󰝟" : vol < 0.34 ? "󰕿" : vol < 0.67 ? "󰖀" : "󰕾"

    PwObjectTracker { objects: [audio.sink] }

    onClicked: Panels.toggle("audio", audio)
    onRightClicked: if (ready) sink.audio.muted = !sink.audio.muted
    onScrolled: (d) => { if (ready) sink.audio.volume = Math.max(0, Math.min(1, vol + d * 0.05)) }

    Label { text: audio.icon; color: audio.muted ? Theme.c.accentDim : Theme.c.accentLight }
    Label {
        visible: audio.pillMode
        text: audio.muted ? "mute" : Math.round(audio.vol * 100) + "%"
        color: audio.muted ? Theme.c.accentDim : Theme.c.accentLight
    }

    AudioPanel { anchorItem: audio }
}
