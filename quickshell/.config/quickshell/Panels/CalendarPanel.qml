import QtQuick
import qs.Commons
import qs.Bar

// Month grid under the clock; click the arrows or scroll to step months.
Panel {
    id: p
    name: "calendar"
    panelWidth: 300
    property date shown: new Date()
    readonly property date today: new Date()
    function step(n) { shown = new Date(shown.getFullYear(), shown.getMonth() + n, 1) }
    onOpenChanged: if (open) shown = new Date()

    Item {
        width: parent.width; height: 26
        Label { anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter
                text: "󰅁"; font.pixelSize: Theme.fs(14); color: Theme.c.accentMid
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: p.step(-1) } }
        Label { anchors.centerIn: parent; text: Qt.formatDate(p.shown, "MMMM yyyy"); font.pixelSize: Theme.fs(13); font.weight: Font.Bold; color: Theme.c.accentBright }
        Label { anchors.right: parent.right; anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter
                text: "󰅂"; font.pixelSize: Theme.fs(14); color: Theme.c.accentMid
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: p.step(1) } }
        MouseArea { anchors.fill: parent; z: -1; onWheel: (w) => p.step(w.angleDelta.y > 0 ? -1 : 1) }
    }
    Grid {
        columns: 7
        width: parent.width
        Repeater {
            model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
            Label { required property string modelData; width: p.panelWidth / 7 - 4; horizontalAlignment: Text.AlignHCenter
                    text: modelData; font.pixelSize: Theme.fs(10); color: Theme.c.accentDim }
        }
    }
    Grid {
        id: days
        columns: 7
        width: parent.width
        readonly property int first: (new Date(p.shown.getFullYear(), p.shown.getMonth(), 1).getDay() + 6) % 7   // Monday first
        readonly property int count: new Date(p.shown.getFullYear(), p.shown.getMonth() + 1, 0).getDate()
        Repeater {
            model: 42
            Item {
                required property int index
                readonly property int day: index - days.first + 1
                readonly property bool inMonth: day >= 1 && day <= days.count
                readonly property bool isToday: inMonth && p.today.getFullYear() === p.shown.getFullYear() && p.today.getMonth() === p.shown.getMonth() && p.today.getDate() === day
                width: p.panelWidth / 7 - 4; height: 30
                Rectangle { anchors.centerIn: parent; width: 26; height: 26; radius: 13; color: parent.isToday ? Theme.c.fg : "transparent" }
                Label { anchors.centerIn: parent; text: parent.inMonth ? parent.day : ""; font.pixelSize: Theme.fs(12)
                        color: parent.isToday ? Theme.c.bg0 : Theme.c.fg; font.weight: parent.isToday ? Font.Bold : Font.Medium }
            }
        }
    }
}
