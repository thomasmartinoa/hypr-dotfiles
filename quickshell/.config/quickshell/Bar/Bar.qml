import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons

// One bar per screen, on any edge. Two skins (Theme.barStyle):
//   pill     floating bordered modules — the classic waybar look
//   minimal  flat strip, Omarchy layout; can be transparent
// Sections and their widgets come from shell.json (Config.layoutFor).
//
// Gestures on empty bar space, like Omarchy: drag (or press-and-hold) to
// move the bar to another screen edge — the screen is split along its
// diagonals and the triangle under the cursor is the target, previewed
// while you drag; double-click toggles transparency (minimal skin only).
Scope {
    id: bars

    property bool moving: false
    property string candidate: ""
    function nearestEdge(nx, ny) {
        let edge = "top", best = ny
        if (1 - ny < best) { edge = "bottom"; best = 1 - ny }
        if (nx < best)     { edge = "left";   best = nx }
        if (1 - nx < best) { edge = "right";  best = 1 - nx }
        return edge
    }

    IpcHandler {
        target: "bar"
        function style(name: string): string {
            if (name === "pill" || name === "minimal") Theme.barOverride = name
            else if (name === "auto" || name === "") Theme.barOverride = ""
            return Theme.barStyle
        }
        function current(): string { return Theme.barStyle }
        function toggle(): string { Theme.barOverride = Theme.barStyle === "pill" ? "minimal" : "pill"; return Theme.barStyle }
        function position(edge: string): string { Config.setPosition(edge); return Config.position }
        function transparent(): bool { Config.toggleTransparent(); return Config.transparent }
        function visible(): bool { Config.set("bar.hidden", !Config.hidden); return !Config.hidden }
        function battery(): bool { Config.set("bar.battery", !Config.batteryPercent); return Config.batteryPercent }
    }

    Variants {
        model: Quickshell.screens

        Scope {
            id: perScreen
            required property var modelData

            PanelWindow {
                id: win
                screen: perScreen.modelData
                visible: !Config.hidden

                readonly property bool pill: Theme.barStyle === "pill"
                readonly property string pos: Config.position
                readonly property bool vertical: Config.vertical
                readonly property bool transparent: !pill && Config.transparent
                readonly property int thickness: pill ? (vertical ? 44 : 37) : (vertical ? 28 : 26)
                readonly property int edgeGap: pill ? 5 : 0
                readonly property int sideGap: pill ? 6 : 0

                anchors {
                    top:    pos === "top"    || vertical
                    bottom: pos === "bottom" || vertical
                    left:   pos === "left"   || !vertical
                    right:  pos === "right"  || !vertical
                }
                margins {
                    top:    pos === "top"    ? edgeGap : (vertical ? sideGap : 0)
                    bottom: pos === "bottom" ? edgeGap : (vertical ? sideGap : 0)
                    left:   pos === "left"   ? edgeGap : (vertical ? 0 : sideGap)
                    right:  pos === "right"  ? edgeGap : (vertical ? 0 : sideGap)
                }
                implicitHeight: vertical ? 0 : thickness
                implicitWidth: vertical ? thickness : 0
                color: pill || transparent ? "transparent" : Theme.c.bg0
                WlrLayershell.namespace: "hypr-bar"
                Behavior on color { ColorAnimation { duration: 150 } }

                // ---- gestures on empty space (under the widgets) ----
                MouseArea {
                    id: gesture
                    anchors.fill: parent
                    z: 0
                    acceptedButtons: Qt.LeftButton
                    pressAndHoldInterval: 200
                    cursorShape: bars.moving ? Qt.ClosedHandCursor : Qt.ArrowCursor
                    property real px: 0
                    property real py: 0
                    property bool suppress: false
                    function begin(x, y) {
                        if (bars.moving) return
                        bars.moving = true
                        update(x, y)
                    }
                    function update(x, y) {
                        // window position within the screen, then normalise
                        const sx = (win.pos === "right" ? win.screen.width - win.width - win.margins.right : win.margins.left) + x
                        const sy = (win.pos === "bottom" ? win.screen.height - win.height - win.margins.bottom : win.margins.top) + y
                        bars.candidate = bars.nearestEdge(Math.max(0, Math.min(1, sx / win.screen.width)),
                                                          Math.max(0, Math.min(1, sy / win.screen.height)))
                    }
                    onPressed: (e) => { px = e.x; py = e.y; suppress = false }
                    onPressAndHold: (e) => { if (pressed) begin(e.x, e.y) }
                    onPositionChanged: (e) => {
                        if (!(e.buttons & Qt.LeftButton)) return
                        if (!bars.moving) { if (Math.abs(e.x - px) + Math.abs(e.y - py) < 8) return; begin(e.x, e.y) }
                        else update(e.x, e.y)
                    }
                    onReleased: {
                        if (!bars.moving) return
                        const edge = bars.candidate
                        bars.moving = false; bars.candidate = ""; suppress = true
                        if (edge !== "" && edge !== Config.position) Config.setPosition(edge)
                    }
                    onCanceled: { bars.moving = false; bars.candidate = "" }
                    onDoubleClicked: (e) => {
                        if (suppress) { suppress = false; return }
                        if (!win.pill) Config.toggleTransparent()
                    }
                }

                // ---- sections ----
                component Section: Item {
                    id: sec
                    property string name
                    readonly property var entries: Config.layoutFor(Theme.barStyle, name)
                    implicitWidth: win.vertical ? col.implicitWidth : row.implicitWidth
                    implicitHeight: win.vertical ? col.implicitHeight : row.implicitHeight
                    width: implicitWidth
                    height: implicitHeight
                    Row {
                        id: row
                        visible: !win.vertical
                        spacing: win.pill ? 8 : 2
                        Repeater {
                            model: win.vertical ? [] : sec.entries
                            WidgetLoader { required property var modelData; widgetId: modelData; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }
                    Column {
                        id: col
                        visible: win.vertical
                        spacing: win.pill ? 8 : 6
                        Repeater {
                            model: win.vertical ? sec.entries : []
                            WidgetLoader { required property var modelData; widgetId: modelData; anchors.horizontalCenter: parent.horizontalCenter }
                        }
                    }
                }

                // positioned by hand: flipping anchors at runtime leaves items
                // stretched or pinned (anchors override the size bindings)
                Section {
                    name: "left"
                    x: win.vertical ? (parent.width - width) / 2 : 8
                    y: win.vertical ? 8 : (parent.height - height) / 2
                }
                Section {
                    name: "center"
                    x: (parent.width - width) / 2
                    y: (parent.height - height) / 2
                }
                Section {
                    name: "right"
                    x: win.vertical ? (parent.width - width) / 2 : parent.width - width - (win.pill ? 2 : 8)
                    y: win.vertical ? parent.height - height - (win.pill ? 2 : 8) : (parent.height - height) / 2
                }
            }

            // edge preview while moving: a translucent strip on the candidate edge
            PanelWindow {
                id: ghost
                screen: perScreen.modelData
                visible: bars.moving && bars.candidate !== "" && bars.candidate !== Config.position
                readonly property bool v: bars.candidate === "left" || bars.candidate === "right"
                anchors {
                    top:    bars.candidate === "top"    || v
                    bottom: bars.candidate === "bottom" || v
                    left:   bars.candidate === "left"   || !v
                    right:  bars.candidate === "right"  || !v
                }
                implicitHeight: v ? 0 : win.thickness
                implicitWidth: v ? win.thickness : 0
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "hypr-bar-ghost"
                mask: Region {}
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    radius: Theme.radius
                    color: Theme.alpha(Theme.c.fg, 0.18)
                    border.width: 1
                    border.color: Theme.c.borderStrong
                }
            }
        }
    }
}
