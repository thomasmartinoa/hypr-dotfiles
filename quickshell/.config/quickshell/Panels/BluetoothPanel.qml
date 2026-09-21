import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.Commons
import qs.Bar
import qs.Services

Panel {
    id: p
    name: "bluetooth"

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool on: adapter && adapter.enabled
    readonly property var devices: {
        const all = Bluetooth.devices.values.filter(d => d.name || d.deviceName)
        all.sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || (a.name || "").localeCompare(b.name || ""))
        return all
    }
    onOpenChanged: if (adapter) adapter.discovering = open && on

    function icon(d) {
        const i = String(d.icon || "")
        if (i.indexOf("headset") >= 0 || i.indexOf("headphone") >= 0) return "󰋋"
        if (i.indexOf("audio") >= 0) return "󰓃"
        if (i.indexOf("phone") >= 0) return "󰄜"
        if (i.indexOf("mouse") >= 0) return "󰍽"
        if (i.indexOf("keyboard") >= 0) return "󰌌"
        if (i.indexOf("computer") >= 0) return "󰇅"
        return "󰂯"
    }
    function state(d) {
        if (d.pairing) return "pairing…"
        if (d.state === BluetoothDeviceState.Connecting) return "connecting…"
        if (d.state === BluetoothDeviceState.Disconnecting) return "disconnecting…"
        if (d.connected) return d.batteryAvailable ? Math.round(d.battery * 100) + "%" : "connected"
        return d.paired ? "paired" : ""
    }

    PanelHeader {
        title: "Bluetooth"
        showToggle: true
        toggle.on: p.on
        onToggled: (on) => { if (p.adapter) p.adapter.enabled = on }
    }

    Column {
        width: parent.width; spacing: 2
        visible: p.on
        Label { visible: p.devices.length === 0; text: p.adapter && p.adapter.discovering ? "Searching…" : "No devices"; font.pixelSize: 12; color: Theme.c.accentMid; padding: 6 }
        Repeater {
            model: p.devices.slice(0, 10)
            PanelRow {
                required property var modelData
                icon: p.icon(modelData)
                title: modelData.name || modelData.deviceName
                subtitle: p.state(modelData)
                active: modelData.connected
                busy: modelData.pairing || modelData.state === BluetoothDeviceState.Connecting
                onClicked: {
                    if (modelData.connected) modelData.disconnect()
                    else if (modelData.paired) modelData.connect()
                    else modelData.pair()
                }
                onRightClicked: if (modelData.paired) modelData.forget()
            }
        }
    }
    Label { visible: !p.on; text: "Bluetooth is off"; font.pixelSize: 12; color: Theme.c.accentMid; padding: 6 }

    Row {
        width: parent.width; spacing: 8; layoutDirection: Qt.RightToLeft
        PanelButton { text: "Manager"; icon: "󰒓"; onClicked: { Quickshell.execDetached(["blueman-manager"]); Panels.close() } }
    }
}
