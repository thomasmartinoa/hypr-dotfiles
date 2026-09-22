import QtQuick
import qs.Commons
import qs.Services
import qs.Panels

// Agents: the default agent's session usage. Hidden until an agent account
// is found. Click for the panel, right-click launches the default agent.
Pill {
    id: ag
    visible: Agents.present
    readonly property int pct: Agents.session ? Agents.session.percent : -1
    readonly property color tone: pct >= 90 ? Theme.c.accentDim : pct >= 70 ? Theme.c.accentMid : Theme.c.accentLight
    onClicked: Panels.toggle("agents", ag)
    onRightClicked: Agents.launch("")
    Label { text: "󱚝"; color: ag.tone }
    Label { visible: ag.pct >= 0 && !ag.vertical; text: ag.pct + "%"; color: ag.tone }
    AgentsPanel { anchorItem: ag }
}
