import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.Commons
import qs.Bar
import qs.Services

Panel {
    id: p
    name: "power"

    readonly property var dev: UPower.displayDevice
    readonly property int pct: dev ? Math.round(dev.percentage * 100) : 0
    function fmt(sec) {
        if (!sec || sec <= 0) return ""
        const h = Math.floor(sec / 3600), m = Math.round((sec % 3600) / 60)
        return (h > 0 ? h + "h " : "") + m + "m"
    }
    readonly property string status: !dev ? "" :
        dev.state === UPowerDeviceState.Charging ? "Charging" + (fmt(dev.timeToFull) ? " · " + fmt(dev.timeToFull) + " to full" : "") :
        dev.state === UPowerDeviceState.Discharging ? (fmt(dev.timeToEmpty) ? fmt(dev.timeToEmpty) + " left" : "On battery") :
        dev.state === UPowerDeviceState.FullyCharged ? "Fully charged" : "Plugged in"

    PanelHeader { title: "Power" }

    Row {
        width: parent.width; spacing: 12
        Label { text: p.pct + "%"; font.pixelSize: Theme.fs(30); font.weight: Font.Bold; color: Theme.c.accentBright }
        Column {
            anchors.verticalCenter: parent.verticalCenter; spacing: 2
            Label { text: p.status; font.pixelSize: Theme.fs(12); color: Theme.c.fg }
            Label { text: p.dev && p.dev.healthSupported ? "Health " + Math.round(p.dev.healthPercentage) + "%" : ""; font.pixelSize: Theme.fs(11); color: Theme.c.accentMid }
        }
    }

    // power profile ----------------------------------------------------
    Column {
        width: parent.width; spacing: 6
        Label { text: "Profile"; font.pixelSize: Theme.fs(11); color: Theme.c.accentMid }
        Row {
            id: profiles
            width: parent.width; spacing: 6
            readonly property int n: PowerProfiles.hasPerformanceProfile ? 3 : 2
            Repeater {
                model: [
                    { name: "Saver",    icon: "󰌪", v: PowerProfile.PowerSaver,  ok: true },
                    { name: "Balanced", icon: "󰗑", v: PowerProfile.Balanced,    ok: true },
                    { name: "Perf",     icon: "󱐋", v: PowerProfile.Performance, ok: PowerProfiles.hasPerformanceProfile }
                ]
                PanelButton {
                    required property var modelData
                    visible: modelData.ok
                    width: (profiles.width - 6 * (profiles.n - 1)) / profiles.n
                    text: modelData.name; icon: modelData.icon
                    primary: PowerProfiles.profile === modelData.v
                    onClicked: PowerProfiles.profile = modelData.v
                }
            }
        }
    }

    Rectangle { width: parent.width; height: 1; color: Theme.c.bg3 }

    // session ----------------------------------------------------------
    Row {
        id: session
        width: parent.width; spacing: 6
        PanelButton { width: (session.width - 18) / 4; icon: "󰌾"; text: "Lock";     onClicked: { Quickshell.execDetached(["hyprlock"]); Panels.close() } }
        PanelButton { width: (session.width - 18) / 4; icon: "󰤄"; text: "Sleep";    onClicked: { Quickshell.execDetached(["systemctl", "suspend"]); Panels.close() } }
        PanelButton { width: (session.width - 18) / 4; icon: "󰜉"; text: "Reboot";   onClicked: { Quickshell.execDetached(["systemctl", "reboot"]); Panels.close() } }
        PanelButton { width: (session.width - 18) / 4; icon: "󰐥"; text: "Off";      onClicked: { Quickshell.execDetached(["systemctl", "poweroff"]); Panels.close() } }
    }
}
