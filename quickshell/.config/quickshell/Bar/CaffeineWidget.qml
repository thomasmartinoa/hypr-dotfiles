import QtQuick
import qs.Commons
import qs.Services

Pill {
    extraRight: pillMode ? 1 : 0     // Qt draws the glyph ~1px narrower than GTK did
    onClicked: Caffeine.toggle()
    Label {
        text: Caffeine.on ? "󰅶" : "󰾪"
        color: Caffeine.on ? Theme.c.accentBright : Theme.c.accentDim
    }
}
