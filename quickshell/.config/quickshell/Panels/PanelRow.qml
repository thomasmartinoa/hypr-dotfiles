import QtQuick
import qs.Commons
import qs.Bar

// A list row: icon, title, subtitle, optional trailing text. Highlights on
// hover; `active` marks the selected/connected one.
Rectangle {
    id: r
    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property string trailing: ""
    property bool active: false
    property bool busy: false
    signal clicked()
    signal rightClicked()
    width: parent.width
    height: subtitle !== "" ? 44 : 36
    radius: Theme.radius
    color: active ? Theme.c.bg2 : m.containsMouse ? Theme.c.bg1 : "transparent"
    Behavior on color { ColorAnimation { duration: 120 } }
    Label {
        id: ic
        x: 10; anchors.verticalCenter: parent.verticalCenter
        text: r.icon; width: 20; font.pixelSize: 15
        color: r.active ? Theme.c.accentBright : Theme.c.accentMid
    }
    Column {
        anchors.left: ic.right; anchors.leftMargin: 8
        anchors.right: tr.left; anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1
        Label { width: parent.width; elide: Text.ElideRight; text: r.title; font.pixelSize: 13
                color: r.active ? Theme.c.accentBright : Theme.c.fg; font.weight: r.active ? Font.DemiBold : Font.Medium }
        Label { visible: r.subtitle !== ""; width: parent.width; elide: Text.ElideRight; text: r.subtitle
                font.pixelSize: 11; color: Theme.c.accentMid }
    }
    Label {
        id: tr
        anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter
        text: r.busy ? "…" : r.trailing; font.pixelSize: 11; color: Theme.c.accentMid
    }
    MouseArea {
        id: m
        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (e) => e.button === Qt.RightButton ? r.rightClicked() : r.clicked()
    }
}
