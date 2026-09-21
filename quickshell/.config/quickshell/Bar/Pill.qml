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

    implicitWidth: inner.implicitWidth + padH * 2 + extraRight
    implicitHeight: pillMode ? 31 : 26
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
    Row {
        id: inner
        anchors.verticalCenter: parent.verticalCenter
        x: pill.padH
        spacing: pill.gap
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
