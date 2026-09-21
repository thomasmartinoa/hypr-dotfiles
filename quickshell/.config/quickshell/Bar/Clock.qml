import QtQuick
import Quickshell
import qs.Commons
import qs.Services
import qs.Panels

Pill {
    id: clk
    pillMode: Theme.barStyle === "pill"
    SystemClock { id: clock; precision: SystemClock.Minutes }
    onClicked: Panels.toggle("calendar", clk)
    Label {
        text: clk.vertical ? Qt.formatTime(clock.date, "HH\nmm")
            : Theme.barStyle === "pill" ? Qt.formatTime(clock.date, "HH:mm")
            : Qt.formatDateTime(clock.date, "dddd HH:mm")
        horizontalAlignment: Text.AlignHCenter
        color: Theme.c.accentBright
        font.weight: Font.DemiBold
    }
    CalendarPanel { anchorItem: clk }
}
