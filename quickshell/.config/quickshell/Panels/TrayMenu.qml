import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Commons
import qs.Bar
import qs.Services

// A tray item's DBus menu drawn in the theme (Qt's platform menus ignore it).
// Submenus drill down in place with a back row; checkboxes/radios show state.
Panel {
    id: m
    required property var handle          // the tray item's QsMenuHandle
    property string title: ""
    pad: 5
    spacing: 0
    panelWidth: Math.min(360, Math.max(200, list.widest + pad * 2))

    // drill-down stack of handles; the last one is shown
    property var stack: []
    readonly property var current: stack.length ? stack[stack.length - 1] : handle
    onOpenChanged: if (!open) stack = []

    function clean(t) { return (t || "").replace(/__/g, "\u0001").replace(/_/g, "").replace(/\u0001/g, "_") }

    QsMenuOpener { id: opener; menu: m.current }

    // header: app name, or the submenu's back row
    Rectangle {
        width: parent.width; height: 30
        radius: Math.max(0, Theme.radius - 1)
        color: back.containsMouse && m.stack.length ? Theme.c.bg2 : "transparent"
        visible: m.title !== "" || m.stack.length > 0
        Row {
            anchors.verticalCenter: parent.verticalCenter
            x: 9; spacing: 8
            Label { visible: m.stack.length > 0; text: "\u{f0141}"; font.pixelSize: Theme.fs(14); color: Theme.c.accentMid }
            Label {
                text: m.stack.length ? m.clean(m.stack[m.stack.length - 1].text) : m.title
                font.pixelSize: Theme.fs(11); font.weight: Font.Bold
                color: Theme.c.accentMid
            }
        }
        MouseArea { id: back; anchors.fill: parent; hoverEnabled: true
                    enabled: m.stack.length > 0; cursorShape: Qt.PointingHandCursor
                    onClicked: m.stack = m.stack.slice(0, -1) }
    }
    Rectangle { visible: m.title !== "" || m.stack.length > 0; width: parent.width; height: 1; color: Theme.c.bg3 }
    Item { visible: m.title !== "" || m.stack.length > 0; width: 1; height: 4 }

    Column {
        id: list
        width: parent.width
        property real widest: 0
        property bool anyLead: false   // reserve the icon/check column only if something uses it
        Repeater {
            model: opener.children
            Item {
                id: row
                required property var modelData
                width: list.width
                height: modelData.isSeparator ? 9 : 30
                readonly property bool lead: modelData.buttonType !== QsMenuButtonType.None || modelData.icon !== ""
                Component.onCompleted: {
                    if (lead) list.anyLead = true
                    list.widest = Math.max(list.widest, content.implicitWidth + (row.modelData.hasChildren ? 44 : 24))
                }

                Rectangle {   // separator
                    visible: row.modelData.isSeparator
                    anchors.verticalCenter: parent.verticalCenter
                    x: 8; width: parent.width - 16; height: 1
                    color: Theme.c.bg3
                }
                Rectangle {
                    visible: !row.modelData.isSeparator
                    anchors.fill: parent
                    radius: Math.max(0, Theme.radius - 1)
                    color: hit.containsMouse && row.modelData.enabled ? Theme.c.bg2 : "transparent"
                    Behavior on color { ColorAnimation { duration: 90 } }
                }
                Row {
                    id: content
                    visible: !row.modelData.isSeparator
                    anchors.verticalCenter: parent.verticalCenter
                    x: 9; spacing: 9
                    opacity: row.modelData.enabled ? 1 : 0.4
                    Item {   // check / radio / icon slot, kept aligned across rows
                        visible: list.anyLead
                        width: 16; height: 16
                        anchors.verticalCenter: parent.verticalCenter
                        IconImage {
                            anchors.fill: parent
                            visible: row.modelData.buttonType === QsMenuButtonType.None && row.modelData.icon !== ""
                            source: row.modelData.icon
                        }
                        Label {
                            anchors.centerIn: parent
                            visible: row.modelData.buttonType !== QsMenuButtonType.None
                            readonly property bool on: row.modelData.checkState === Qt.Checked
                            text: row.modelData.buttonType === QsMenuButtonType.RadioButton
                                  ? (on ? "\u{f0134}" : "\u{f0130}")
                                  : (on ? "\u{f0c52}" : "\u{f0131}")
                            font.pixelSize: Theme.fs(14)
                            color: on ? Theme.c.accentBright : Theme.c.accentDim
                        }
                    }
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: m.clean(row.modelData.text)
                        font.pixelSize: Theme.fs(12)
                        color: hit.containsMouse ? Theme.c.accentBright : Theme.c.fg
                    }
                }
                Label {
                    visible: row.modelData.hasChildren
                    anchors.right: parent.right; anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\u{f0142}"; font.pixelSize: Theme.fs(14); color: Theme.c.accentMid
                }
                MouseArea {
                    id: hit
                    anchors.fill: parent
                    enabled: !row.modelData.isSeparator
                    hoverEnabled: true
                    cursorShape: row.modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (!row.modelData.enabled) return
                        if (row.modelData.hasChildren) { m.stack = m.stack.concat([row.modelData]); return }
                        row.modelData.triggered()
                        Panels.close()
                    }
                }
            }
        }
    }
}
