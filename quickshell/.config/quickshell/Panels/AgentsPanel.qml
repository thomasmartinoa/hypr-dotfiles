import QtQuick
import Quickshell
import qs.Commons
import qs.Bar
import qs.Services

// Agent usage — Omarchy's panel: per account the plan and each limit as a
// bar with its reset time, then tokens by day (last week) and by model,
// and the default agent with a launch button.
Panel {
    id: p
    name: "agents"
    panelWidth: 340
    onOpenChanged: if (open) Agents.refresh()

    // ticks the countdowns while open
    property int now: 0
    Timer { interval: 30000; running: p.open; repeat: true; onTriggered: p.now++ }

    PanelHeader { title: "Agents" }

    // ---- accounts ----------------------------------------------------
    Repeater {
        model: Agents.accounts
        Column {
            required property var modelData
            width: parent.width; spacing: 8
            Row {
                width: parent.width
                Label { text: modelData.name; font.pixelSize: Theme.fs(13); font.weight: Font.DemiBold; color: Theme.c.fg; width: parent.width - plan.width }
                Rectangle {
                    id: plan
                    visible: modelData.plan !== ""
                    width: planLbl.implicitWidth + 12; height: 18; radius: 3
                    color: Theme.c.bg2; border.width: 1; border.color: Theme.c.border
                    Label { id: planLbl; anchors.centerIn: parent; text: modelData.plan; font.pixelSize: Theme.fs(10); color: Theme.c.accentMid }
                }
            }
            Label { visible: modelData.error !== ""; width: parent.width; wrapMode: Text.Wrap
                    text: modelData.error; font.pixelSize: Theme.fs(11); color: Theme.c.accentMid }
            Repeater {
                model: modelData.limits
                Column {
                    required property var modelData
                    width: parent.width; spacing: 4
                    Row {
                        width: parent.width
                        Label { text: modelData.name; font.pixelSize: Theme.fs(11); color: Theme.c.fg; width: parent.width - pct.width - reset.width }
                        Label { id: reset; text: { void p.now; return Agents.resetsIn(modelData.resets_at) } font.pixelSize: Theme.fs(11); color: Theme.c.accentMid; rightPadding: 8 }
                        Label { id: pct; text: modelData.percent + "%"; font.pixelSize: Theme.fs(11); font.weight: Font.DemiBold
                                color: modelData.percent >= 90 ? Theme.c.accentDim : Theme.c.accentBright }
                    }
                    Rectangle {
                        width: parent.width; height: 6; radius: 3; color: Theme.c.bg2
                        Rectangle { width: Math.max(6, parent.width * Math.min(100, modelData.percent) / 100); height: parent.height; radius: 3
                                    color: modelData.percent >= 90 ? Theme.c.accentMid : Theme.c.accentBright
                                    Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } } }
                    }
                }
            }
            Label {
                visible: !!modelData.extra
                text: modelData.extra ? "Extra usage: " + (modelData.extra.used ?? 0) + " / " + (modelData.extra.limit ?? "∞") + " " + modelData.extra.currency : ""
                font.pixelSize: Theme.fs(11); color: Theme.c.accentMid
            }
        }
    }
    Label {
        visible: !Agents.present
        width: parent.width; wrapMode: Text.Wrap
        text: "No coding agent found. Install claude, codex or opencode and log in; usage shows up here."
        font.pixelSize: Theme.fs(12); color: Theme.c.accentMid
    }

    Rectangle { visible: Agents.tokens.days.length > 0; width: parent.width; height: 1; color: Theme.c.bg3 }

    // ---- tokens by day -----------------------------------------------
    Column {
        visible: Agents.tokens.days.length > 0
        width: parent.width; spacing: 6
        readonly property var days: Agents.tokens.days
        readonly property real max: Math.max(1, ...days.map(d => d.total))
        readonly property real week: days.reduce((s, d) => s + d.total, 0)
        Row {
            width: parent.width
            Label { text: "Tokens · last 7 days"; font.pixelSize: Theme.fs(11); color: Theme.c.accentMid; width: parent.width - wk.width }
            Label { id: wk; text: Agents.fmtTokens(parent.parent.week); font.pixelSize: Theme.fs(11); color: Theme.c.fg }
        }
        Row {
            id: chart
            width: parent.width; height: 56; spacing: 6
            readonly property real bw: (width - spacing * (parent.days.length - 1)) / Math.max(1, parent.days.length)
            Repeater {
                model: chart.parent.days
                Column {
                    required property var modelData
                    required property int index
                    width: chart.bw; height: chart.height; spacing: 3
                    Item {
                        width: parent.width; height: parent.height - 14
                        Rectangle {
                            anchors.bottom: parent.bottom; width: parent.width
                            height: Math.max(2, parent.height * modelData.total / chart.parent.max)
                            radius: 2
                            color: index === chart.parent.days.length - 1 ? Theme.c.accentBright : Theme.c.accentMid
                            Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                        }
                    }
                    Label { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDate(new Date(modelData.date + "T12:00:00"), "ddd").slice(0, 2)
                            font.pixelSize: Theme.fs(9); color: index === chart.parent.days.length - 1 ? Theme.c.fg : Theme.c.accentDim }
                }
            }
        }
    }

    // ---- tokens by model ---------------------------------------------
    Column {
        visible: Agents.tokens.models.length > 0
        width: parent.width; spacing: 4
        Label { text: "By model"; font.pixelSize: Theme.fs(11); color: Theme.c.accentMid }
        Repeater {
            model: Agents.tokens.models.slice(0, 4)
            Row {
                required property var modelData
                width: parent.width
                Label { text: modelData.model; font.pixelSize: Theme.fs(11); color: Theme.c.fg; width: parent.width - tot.width }
                Label { id: tot; text: Agents.fmtTokens(modelData.total) + "  ·  " + Agents.fmtTokens(modelData.output) + " out"; font.pixelSize: Theme.fs(11); color: Theme.c.accentMid }
            }
        }
    }

    Rectangle { width: parent.width; height: 1; color: Theme.c.bg3 }

    // ---- footer: default agent + launch, refresh ---------------------
    Row {
        width: parent.width; spacing: 6
        Column {
            width: parent.width - launch.width - refresh.width - 12
            anchors.verticalCenter: parent.verticalCenter; spacing: 1
            Label { text: "Default: " + (Agents.defaultAgent || "none"); font.pixelSize: Theme.fs(12); color: Theme.c.fg }
            Label { text: { void p.now; return "updated " + Agents.ago() } font.pixelSize: Theme.fs(10); color: Theme.c.accentMid; elide: Text.ElideRight; width: parent.width }
        }
        PanelButton { id: refresh; icon: Agents.busy ? "󰑖" : "󰑐"; onClicked: Agents.refresh() }
        PanelButton { id: launch; icon: "󱚝"; text: "Launch"; primary: true; enabled: Agents.defaultAgent !== ""
                      onClicked: { Agents.launch(""); Panels.close() } }
    }
}
