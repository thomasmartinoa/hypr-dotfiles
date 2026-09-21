import QtQuick
import qs.Commons
import qs.Services

Pill {
    onClicked: Swaync.toggle()
    onRightClicked: Swaync.toggleDnd()
    Label {
        text: Swaync.dnd ? (Swaync.count > 0 ? "󰂠" : "󰪓")
            : Swaync.inhibited ? (Swaync.count > 0 ? "󰂛" : "󰪑")
            : (Swaync.count > 0 ? "󱅫" : "󰂜")
        color: Theme.c.accentLight
    }
}
