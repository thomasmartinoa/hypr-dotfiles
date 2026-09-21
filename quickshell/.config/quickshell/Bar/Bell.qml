import QtQuick
import qs.Commons
import qs.Services
import qs.Panels
import qs.Notifications

Pill {
    id: bell
    onClicked: Panels.toggle("notifications", bell)
    onRightClicked: Notifs.toggleDnd()
    Label {
        text: Notifs.dnd ? (Notifs.count > 0 ? "󰂠" : "󰪓") : (Notifs.count > 0 ? "󱅫" : "󰂜")
        color: Notifs.dnd ? Theme.c.accentDim : Theme.c.accentLight
    }
    NotificationCenter { anchorItem: bell }
}
