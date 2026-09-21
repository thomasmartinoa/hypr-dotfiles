import QtQuick
import Quickshell
import Quickshell.Networking
import qs.Commons
import qs.Bar
import qs.Services

Panel {
    id: p
    name: "network"

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) || null
    readonly property var wired: Networking.devices.values.find(d => d.type === DeviceType.Wired) || null
    property var networks: []
    property var pskFor: null      // network waiting for a password

    function refresh() {
        if (!wifi) { networks = []; return }
        const seen = {}
        const out = []
        for (const n of wifi.networks.values) {
            if (!n.name || seen[n.name]) continue
            seen[n.name] = true
            out.push(n)
        }
        out.sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength))
        networks = out
    }
    onOpenChanged: {
        if (wifi) wifi.scannerEnabled = open
        if (open) refresh(); else pskFor = null
    }
    Timer { interval: 2000; running: p.open; repeat: true; onTriggered: p.refresh() }

    function strengthIcon(s) { return s > 75 ? "󰤨" : s > 50 ? "󰤥" : s > 25 ? "󰤢" : "󰤟" }
    function tap(n) {
        if (n.connected) { n.disconnect(); return }
        if (n.known || n.security === WifiSecurityType.None) { n.connect(); return }
        pskFor = n
    }

    PanelHeader {
        title: "Wi-Fi"
        showToggle: true
        toggle.on: Networking.wifiEnabled
        onToggled: (on) => Networking.wifiEnabled = on
    }

    PanelRow {
        visible: p.wired && p.wired.connected
        icon: "󰈀"; title: "Wired"; subtitle: p.wired ? (p.wired.address || "") : ""; active: true; trailing: "connected"
    }

    Column {
        width: parent.width; spacing: 2
        visible: Networking.wifiEnabled
        Label { visible: p.networks.length === 0; text: "Scanning…"; font.pixelSize: 12; color: Theme.c.accentMid; padding: 6 }
        Repeater {
            model: p.networks.slice(0, 10)
            Column {
                required property var modelData
                width: parent.width
                PanelRow {
                    icon: p.strengthIcon(modelData.signalStrength)
                    title: modelData.name
                    subtitle: modelData.connected ? "connected" : modelData.known ? "saved" : ""
                    trailing: modelData.security === WifiSecurityType.None ? "" : "󰌾"
                    active: modelData.connected
                    busy: modelData.stateChanging
                    onClicked: p.tap(modelData)
                    onRightClicked: if (modelData.known) modelData.forget()
                }
                // password prompt for an unknown secured network
                Rectangle {
                    visible: p.pskFor === modelData
                    width: parent.width; height: 34; radius: Theme.radius
                    color: Theme.c.bg1; border.width: 1; border.color: Theme.c.border
                    TextInput {
                        id: psk
                        anchors.fill: parent; anchors.margins: 8
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        font.family: Theme.font; font.pixelSize: 12; color: Theme.c.fg
                        focus: p.pskFor === modelData
                        Label { anchors.verticalCenter: parent.verticalCenter; visible: !psk.text; text: "password, Enter to connect"; font.pixelSize: 11; color: Theme.c.accentDim }
                        onAccepted: { modelData.connectWithPsk(text); text = ""; p.pskFor = null }
                        Keys.onEscapePressed: p.pskFor = null
                    }
                }
            }
        }
    }

    Row {
        width: parent.width; spacing: 8; layoutDirection: Qt.RightToLeft
        PanelButton { text: "Settings"; icon: "󰒓"; onClicked: { Quickshell.execDetached(["nm-connection-editor"]); Panels.close() } }
    }
}
