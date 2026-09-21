import QtQuick
import qs.Commons

// Horizontal slider, 0..1. `value` is shown; `moved(v)` is emitted on drag.
Item {
    id: s
    property real value: 0
    property bool dimmed: false
    signal moved(real v)
    width: parent.width
    height: 20
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width; height: 4; radius: 2
        color: Theme.c.bg3
        Rectangle {
            width: Math.max(4, parent.width * Math.max(0, Math.min(1, s.value))); height: parent.height; radius: 2
            color: s.dimmed ? Theme.c.accentDim : Theme.c.fg
            Behavior on width { NumberAnimation { duration: 60 } }
        }
    }
    Rectangle {
        width: 12; height: 12; radius: 6
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(s.width - width, s.width * s.value - width / 2))
        color: s.dimmed ? Theme.c.accentMid : Theme.c.accentBright
        Behavior on x { NumberAnimation { duration: 60 } }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        function set(mx) { s.moved(Math.max(0, Math.min(1, mx / s.width))) }
        onPressed: (e) => set(e.x)
        onPositionChanged: (e) => { if (pressed) set(e.x) }
        onWheel: (w) => s.moved(Math.max(0, Math.min(1, s.value + (w.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
