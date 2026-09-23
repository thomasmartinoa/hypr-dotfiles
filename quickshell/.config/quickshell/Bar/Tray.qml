import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Commons
import qs.Services
import qs.Panels

Pill {
    id: tray
    round: true
    interactive: false
    visible: SystemTray.items.values.length > 0
    padH: pillMode ? 12 : 6
    Repeater {
        model: SystemTray.items
        Item {
            id: entry
            required property var modelData
            width: 16; height: 16
            // Many apps ship a single-colour white (or black) tray icon made for one
            // kind of bar. Look at what's actually drawn; if it's colourless and the
            // same lightness as the bar, invert it on the GPU. Colourful icons stay as-is.
            property real tone: 0   // +1 light mono icon, -1 dark mono icon, 0 colourful / unknown
            readonly property bool clash: (tone > 0 && Theme.light) || (tone < 0 && !Theme.light)
            IconImage {
                id: icon
                anchors.fill: parent
                source: entry.modelData.icon
                opacity: entry.modelData.status === Status.Passive ? 0.5 : 1
                layer.enabled: entry.clash
                layer.effect: ShaderEffect { fragmentShader: Qt.resolvedUrl("../Shaders/invert.frag.qsb") }
                onSourceChanged: probe.again()
            }
            // Sample a snapshot of the icon as displayed (not the file: the icon theme,
            // Papirus vs Papirus-Dark, follows light/dark and changes the pixels).
            Canvas {
                id: probe
                visible: false
                width: 32; height: 32
                property var grab: null   // keep the ItemGrabResult alive while it's used
                property int tries: 0
                function again() { tries = 0; retry.restart() }
                function snap() {
                    if (entry.clash) { retry.restart(); return }   // don't sample the inverted layer
                    icon.grabToImage(r => { grab = r }, Qt.size(width, height))
                }
                Timer { id: retry; interval: 600; onTriggered: { probe.tries++; probe.snap() } }
                Component.onCompleted: again()
                // the icon theme swaps a moment after the colours do: look again then
                Connections { target: Theme; function onLightChanged() { entry.tone = 0; probe.again() } }
                // Canvas can't load "itemgrabber:" urls; an Image can, and Canvas draws Images
                Image { id: snapImg; visible: false; source: probe.grab ? probe.grab.url : ""; cache: false
                        onStatusChanged: if (status === Image.Ready) probe.requestPaint() }
                onPaint: {
                    if (snapImg.status !== Image.Ready) return
                    const ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.drawImage(snapImg, 0, 0, width, height)
                    const d = ctx.getImageData(0, 0, width, height).data
                    let n = 0, lum = 0, sat = 0
                    for (let i = 0; i < d.length; i += 4) {
                        if (d[i + 3] < 100) continue
                        const r = d[i] / 255, g = d[i + 1] / 255, b = d[i + 2] / 255
                        const mx = Math.max(r, g, b), mn = Math.min(r, g, b)
                        lum += (mx + mn) / 2; sat += mx - mn; n++
                    }
                    // nothing drawn yet (icon still loading): try again shortly
                    if (n < 8) { if (tries < 15) retry.restart(); return }
                    lum /= n; sat /= n
                    entry.tone = sat > 0.18 ? 0 : lum > 0.7 ? 1 : lum < 0.3 ? -1 : 0
                }
            }
            TrayMenu {
                id: menu
                // ids aren't unique (every Electron app is chrome_status_icon_1)
                name: "tray:" + (entry.modelData.id || "") + ":" + (entry.modelData.title || "")
                anchorItem: entry
                handle: entry.modelData.menu
                title: entry.modelData.title || entry.modelData.tooltipTitle || entry.modelData.id
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                cursorShape: Qt.PointingHandCursor
                onClicked: (e) => {
                    if (e.button === Qt.RightButton || entry.modelData.onlyMenu) {
                        if (entry.modelData.hasMenu) Panels.toggle(menu.name, entry)
                    } else if (e.button === Qt.MiddleButton) entry.modelData.secondaryActivate()
                    else entry.modelData.activate()
                }
                onWheel: (w) => entry.modelData.scroll(w.angleDelta.y, false)
            }
        }
    }
}
