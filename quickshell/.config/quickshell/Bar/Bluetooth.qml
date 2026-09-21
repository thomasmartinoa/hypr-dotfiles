import QtQuick
import Quickshell.Bluetooth
import qs.Commons
import qs.Services
import qs.Panels

Pill {
    id: bt
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool on: adapter && adapter.enabled
    readonly property bool connected: Bluetooth.devices.values.some(d => d.connected)
    visible: adapter !== null
    onClicked: Panels.toggle("bluetooth", bt)
    Label {
        text: !bt.on ? "󰂲" : bt.connected ? "󰂱" : "󰂯"
        color: !bt.on ? Theme.c.accentDim : bt.connected ? Theme.c.accentBright : Theme.c.accentLight
    }
    BluetoothPanel { anchorItem: bt }
}
