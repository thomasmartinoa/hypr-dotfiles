import QtQuick
import qs.Commons
import qs.Services

Pill {
    onClicked: Caffeine.toggle()
    Label {
        text: Caffeine.on ? "󰅶" : "󰾪"
        color: Caffeine.on ? Theme.c.accentBright : Theme.c.accentDim
    }
}
