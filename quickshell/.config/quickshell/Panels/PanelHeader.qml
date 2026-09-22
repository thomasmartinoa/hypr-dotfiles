import QtQuick
import qs.Commons
import qs.Bar

Item {
    id: h
    property string title: ""
    property alias toggle: sw
    property bool showToggle: false
    signal toggled(bool on)
    width: parent.width
    height: 26
    Label {
        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
        text: h.title; font.pixelSize: Theme.fs(13); font.weight: Font.Bold; color: Theme.c.accentBright
    }
    Toggle {
        id: sw
        visible: h.showToggle
        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
        onToggled: (on) => h.toggled(on)
    }
}
