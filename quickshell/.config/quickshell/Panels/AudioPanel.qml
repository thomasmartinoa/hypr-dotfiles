import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.Commons
import qs.Bar

Panel {
    id: p
    name: "audio"

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)
    readonly property var sources: Pipewire.nodes.values.filter(n => !n.isSink && !n.isStream && n.audio && n.type === PwNodeType.AudioSource)
    PwObjectTracker { objects: [p.sink, p.source] }

    function label(n) { return n ? (n.nickname || n.description || n.name) : "—" }

    PanelHeader { title: "Sound" }

    // output --------------------------------------------------------
    Column {
        width: parent.width; spacing: 6
        Row {
            width: parent.width; spacing: 8
            Label { text: p.sink && p.sink.audio.muted ? "󰝟" : "󰕾"; width: 20; font.pixelSize: Theme.fs(15)
                    color: p.sink && p.sink.audio.muted ? Theme.c.accentDim : Theme.c.accentLight
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: if (p.sink) p.sink.audio.muted = !p.sink.audio.muted } }
            Label { text: "Output"; font.pixelSize: Theme.fs(12); color: Theme.c.accentMid; width: parent.width - 100 }
            Label { text: p.sink ? Math.round(p.sink.audio.volume * 100) + "%" : ""; font.pixelSize: Theme.fs(12); color: Theme.c.accentMid
                    width: 40; horizontalAlignment: Text.AlignRight }
        }
        Slider { value: p.sink ? p.sink.audio.volume : 0; dimmed: p.sink && p.sink.audio.muted
                 onMoved: (v) => { if (p.sink) p.sink.audio.volume = v } }
    }
    Column {
        width: parent.width; spacing: 2
        Repeater {
            model: p.sinks
            PanelRow {
                required property var modelData
                icon: modelData === p.sink ? "󰓃" : "󰓃"
                title: p.label(modelData)
                active: modelData === p.sink
                trailing: active ? "default" : ""
                onClicked: Pipewire.preferredDefaultAudioSink = modelData
            }
        }
    }

    Rectangle { width: parent.width; height: 1; color: Theme.c.bg3 }

    // input ---------------------------------------------------------
    Column {
        width: parent.width; spacing: 6
        Row {
            width: parent.width; spacing: 8
            Label { text: p.source && p.source.audio.muted ? "󰍭" : "󰍬"; width: 20; font.pixelSize: Theme.fs(15)
                    color: p.source && p.source.audio.muted ? Theme.c.accentDim : Theme.c.accentLight
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: if (p.source) p.source.audio.muted = !p.source.audio.muted } }
            Label { text: "Input"; font.pixelSize: Theme.fs(12); color: Theme.c.accentMid; width: parent.width - 100 }
            Label { text: p.source ? Math.round(p.source.audio.volume * 100) + "%" : ""; font.pixelSize: Theme.fs(12); color: Theme.c.accentMid
                    width: 40; horizontalAlignment: Text.AlignRight }
        }
        Slider { value: p.source ? p.source.audio.volume : 0; dimmed: p.source && p.source.audio.muted
                 onMoved: (v) => { if (p.source) p.source.audio.volume = v } }
    }
    Column {
        width: parent.width; spacing: 2
        Repeater {
            model: p.sources
            PanelRow {
                required property var modelData
                icon: "󰍬"
                title: p.label(modelData)
                active: modelData === p.source
                trailing: active ? "default" : ""
                onClicked: Pipewire.preferredDefaultAudioSource = modelData
            }
        }
    }

    Row {
        width: parent.width; spacing: 8; layoutDirection: Qt.RightToLeft
        PanelButton { text: "Mixer"; icon: "󰕬"; onClicked: { Quickshell.execDetached(["pavucontrol"]); Panels.close() } }
    }
}
