import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Commons
import qs.Bar
import qs.Services

// Fullscreen power menu (replaces wlogout): lock · logout · sleep · reboot
// · shutdown. Same keys as the old layout: l o h r s, Escape closes.
Scope {
    id: scope
    property bool open: false

    IpcHandler {
        target: "powermenu"
        function toggle(): void { scope.open = !scope.open }
        function close(): void { scope.open = false }
    }

    readonly property var actions: [
        { key: "l", icon: "󰌾", label: "Lock",     run: () => { scope.open = false; Lock.lock() } },
        { key: "o", icon: "󰍃", label: "Logout",   run: () => Hyprland.dispatch(Hyprland.usingLua ? "hl.dsp.exit()" : "exit") },
        { key: "h", icon: "󰤄", label: "Sleep",    run: () => { scope.open = false; Quickshell.execDetached(["systemctl", "suspend"]) } },
        { key: "r", icon: "󰜉", label: "Reboot",   run: () => Quickshell.execDetached(["systemctl", "reboot"]) },
        { key: "s", icon: "󰐥", label: "Shutdown", run: () => Quickshell.execDetached(["systemctl", "poweroff"]) }
    ]

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: win
            required property var modelData
            screen: modelData
            visible: scope.open
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: scope.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            WlrLayershell.namespace: "hypr-powermenu"
            color: Qt.rgba(Theme.c.bg0.r, Theme.c.bg0.g, Theme.c.bg0.b, 0.7)

            MouseArea { anchors.fill: parent; onClicked: scope.open = false }

            Item {
                anchors.fill: parent
                focus: scope.open
                Keys.onPressed: (e) => {
                    if (e.key === Qt.Key_Escape) { scope.open = false; return }
                    const a = scope.actions.find(x => x.key === e.text.toLowerCase())
                    if (a) a.run()
                }
                Row {
                    anchors.centerIn: parent
                    spacing: 19
                    Repeater {
                        model: scope.actions
                        Rectangle {
                            id: btn
                            required property var modelData
                            width: 130; height: 130
                            radius: Theme.radius
                            color: m.containsMouse ? Theme.c.fg : Theme.c.bg1
                            border.width: 1
                            border.color: m.containsMouse ? Theme.c.fg : Theme.c.border
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Column {
                                anchors.centerIn: parent
                                spacing: 10
                                Label { anchors.horizontalCenter: parent.horizontalCenter; text: btn.modelData.icon
                                        font.pixelSize: 42; color: m.containsMouse ? Theme.c.bg0 : Theme.c.accentLight }
                                Label { anchors.horizontalCenter: parent.horizontalCenter; text: btn.modelData.label
                                        font.pixelSize: 12; color: m.containsMouse ? Theme.c.bg0 : Theme.c.accentMid }
                            }
                            Label { x: 10; y: 8; text: btn.modelData.key; font.pixelSize: 11; color: m.containsMouse ? Theme.c.bg0 : Theme.c.accentDim }
                            MouseArea { id: m; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                        onClicked: btn.modelData.run() }
                        }
                    }
                }
            }
        }
    }
}
