import QtQuick
import Quickshell
import qs.Commons

Pill {
    pillMode: Theme.barStyle === "pill"
    interactive: false
    SystemClock { id: clock; precision: SystemClock.Minutes }
    Label {
        text: Theme.barStyle === "pill" ? Qt.formatTime(clock.date, "HH:mm")
                                        : Qt.formatDateTime(clock.date, "dddd HH:mm")
        color: Theme.c.accentBright
        font.weight: Font.DemiBold
    }
}
