import QtQuick
import qs.Commons

// One bar module. Draws itself as a bordered pill in the "pill" skin
// (the classic waybar look) and as flat text in "minimal". Widgets put
// their content inside; clicks/scroll come out as signals.
Rectangle {
    id: pill
    default property alias content: inner.data
    property bool pillMode: Theme.barStyle === "pill"
    property bool hovered: mouse.containsMouse
    property bool interactive: true
    property int padH: pillMode ? 9 : 7
    property int padV: pillMode ? 2 : 0
    property bool round: false        // the tray pill in the classic look
    property int extraRight: 0        // waybar reserves room after an ellipsized label

    signal clicked()
    signal rightClicked()
    signal middleClicked()
    signal scrolled(int delta)

    readonly property bool vertical: Config.vertical
    implicitWidth: vertical ? (pillMode ? 34 : 28) : inner.implicitWidth + padH * 2 + extraRight
    implicitHeight: vertical ? inner.implicitHeight + (pillMode ? 14 : 8) : (pillMode ? 31 : 26)
    // pill skin keeps the waybar css values exactly (6px, 12px tray, bg3 border)
    radius: pillMode ? (round ? 12 : 6) : Theme.radius
    color: pillMode ? (hovered && interactive ? Theme.c.bg2 : Theme.c.bg0)
                    : (hovered && interactive ? Theme.c.bg2 : "transparent")
    border.width: pillMode ? 1 : 0
    border.color: pillMode ? (hovered && interactive ? Theme.c.bg4 : Theme.c.bg3)
                           : (hovered && interactive ? Theme.c.borderStrong : Theme.c.border)
    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    property int gap: pillMode ? 13 : 6   // measured against waybar
    Grid {
        id: inner
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: pill.vertical ? parent.horizontalCenter : undefined
        x: pill.vertical ? 0 : pill.padH
        // exactly as many cells as visible children: Grid pads its implicit
        // size with spacing for every declared row/column, used or not
        readonly property int n: {
            let c = 0
            for (let i = 0; i < visibleChildren.length; i++) if (visibleChildren[i].width > 0 || visibleChildren[i].height > 0) c++   // a Repeater is a 0x0 child
            return Math.max(1, c)
        }
        columns: pill.vertical ? 1 : n
        rows: pill.vertical ? n : 1
        spacing: pill.vertical ? 4 : pill.gap
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: pill.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: (e) => {
            if (e.button === Qt.RightButton) pill.rightClicked()
            else if (e.button === Qt.MiddleButton) pill.middleClicked()
            else pill.clicked()
        }
        onWheel: (w) => pill.scrolled(w.angleDelta.y > 0 ? 1 : -1)
    }
}
