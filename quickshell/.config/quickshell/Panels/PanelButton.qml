import QtQuick
import qs.Commons
import qs.Bar

// Small pill button for panel footers / action rows.
Rectangle {
    id: b
    property string text: ""
    property string icon: ""
    property bool primary: false
    signal clicked()
    implicitWidth: row.implicitWidth + 24
    implicitHeight: 30
    radius: 8
    color: primary ? (m.containsMouse ? Theme.c.accentLight : Theme.c.fg) : (m.containsMouse ? Theme.c.bg3 : Theme.c.bg2)
    border.width: primary ? 0 : 1
    border.color: Theme.c.bg3
    Behavior on color { ColorAnimation { duration: 120 } }
    Row {
        id: row
        anchors.centerIn: parent
        spacing: 8
        Label { visible: b.icon !== ""; text: b.icon; font.pixelSize: 14; color: b.primary ? Theme.c.bg0 : Theme.c.accentLight }
        Label { visible: b.text !== ""; text: b.text; font.pixelSize: 12; color: b.primary ? Theme.c.bg0 : Theme.c.fg }
    }
    MouseArea { id: m; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: b.clicked() }
}
