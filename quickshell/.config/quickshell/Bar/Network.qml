import QtQuick
import Quickshell
import Quickshell.Networking
import qs.Commons

Pill {
    id: net
    // Pick the connected device: wired first, else wifi.
    readonly property var devices: Networking.devices.values
    property var dev: null
    property var network: null
    function refresh() {
        let wired = null, wifi = null
        for (const d of devices) {
            if (!d.connected) continue
            if (d.type === DeviceType.Wired && !wired) wired = d
            if (d.type === DeviceType.Wifi && !wifi) wifi = d
        }
        dev = wired || wifi
        let n = null
        if (dev) for (const x of dev.networks.values) if (x.connected) { n = x; break }
        network = n
    }
    onDevicesChanged: refresh()
    Timer { interval: 5000; running: true; repeat: true; onTriggered: net.refresh() }
    Component.onCompleted: refresh()

    readonly property bool wired: dev && dev.type === DeviceType.Wired
    readonly property int strength: (network && network.signalStrength !== undefined) ? network.signalStrength : 100
    // pill skin shows the full-strength glyph like the old bar did; minimal shows real strength
    readonly property string icon: !dev ? "󰤭" : wired ? "󰈀" : pillMode ? "󰤨"
                                   : strength > 75 ? "󰤨" : strength > 50 ? "󰤥" : strength > 25 ? "󰤢" : "󰤟"
    readonly property string text: !dev ? "offline" : wired ? (dev.address || "wired") : (network ? network.name : "wifi")

    onClicked: Quickshell.execDetached(["nm-connection-editor"])

    Label { text: net.icon; color: net.dev ? Theme.c.accentLight : Theme.c.accentDim }
    Label {
        visible: net.pillMode
        text: net.text.length > 16 ? net.text.substring(0, 15) + "…" : net.text
        color: net.dev ? Theme.c.accentLight : Theme.c.accentDim
    }
}
