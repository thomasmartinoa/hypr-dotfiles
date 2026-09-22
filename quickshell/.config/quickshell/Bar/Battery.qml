import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.Commons
import qs.Services
import qs.Panels

Pill {
    id: bat
    readonly property var dev: UPower.displayDevice
    visible: dev && dev.isLaptopBattery
    readonly property int pct: dev ? Math.round(dev.percentage * 100) : 0
    readonly property bool charging: dev && dev.state === UPowerDeviceState.Charging
    readonly property bool full: dev && dev.state === UPowerDeviceState.FullyCharged
    readonly property bool idleOnAc: dev && dev.state === UPowerDeviceState.PendingCharge
    readonly property bool plugged: charging || full || idleOnAc
    readonly property var icons: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂀", "󰂂", "󰁹"]
    // same rules as the waybar config: charging glyph, plug only when idle on AC, else the level
    readonly property string icon: charging ? "󰂄" : idleOnAc ? "󰚥" : icons[Math.min(10, Math.floor(pct / 10))]
    // hued themes: green while charging, yellow/red when low (the stock bar look);
    // mono themes tell the levels apart by shade alone
    readonly property color tone: Theme.hued
        ? (charging ? Theme.c.good : plugged ? Theme.c.accentBright
           : pct <= 15 ? Theme.c.critical : pct <= 30 ? Theme.c.warning : Theme.c.accentLight)
        : (plugged ? Theme.c.accentBright
           : pct <= 15 ? Theme.c.accentDim : pct <= 30 ? Theme.c.accentMid : Theme.c.accentLight)

    onClicked: Panels.toggle("power", bat)

    Label {
        id: ic
        text: bat.icon
        color: bat.tone
        SequentialAnimation on opacity {
            running: !bat.plugged && bat.pct <= 15
            loops: Animation.Infinite
            NumberAnimation { to: 0.3; duration: 500 }
            NumberAnimation { to: 1.0; duration: 500 }
            onRunningChanged: if (!running) ic.opacity = 1
        }
    }
    Label { visible: bat.pillMode && !bat.vertical && Config.batteryPercent; text: bat.pct + "%"; color: bat.tone }

    PowerPanel { anchorItem: bat }
}
