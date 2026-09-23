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
            // kind of bar. Sample it once; if it's colourless and the same lightness
            // as the bar, show it inverted (drawn in the probe canvas). Colourful icons stay as-is.
            property real tone: 0   // +1 light mono icon, -1 dark mono icon, 0 colourful / unknown
            readonly property bool clash: (tone > 0 && Theme.light) || (tone < 0 && !Theme.light)
            IconImage {
                id: icon
                anchors.fill: parent
                source: entry.modelData.icon
                visible: !entry.clash
                opacity: entry.modelData.status === Status.Passive ? 0.5 : 1
            }
            Canvas {
                id: probe
                visible: entry.clash
                opacity: icon.opacity
                anchors.centerIn: parent
                width: 48; height: 48; scale: entry.width / 48   // drawn big, shown at icon size: stays crisp
                smooth: true
                property string src: entry.modelData.icon
                property bool probed: false
                property int tries: 0
                onSrcChanged: { probed = false; tries = 0; if (src) loadImage(src); requestPaint() }
                // tray icons often arrive after the item: retry until there are pixels
                Timer { interval: 700; repeat: true; running: !probe.probed && probe.tries < 15
                        onTriggered: { probe.tries++; if (!probe.isImageLoaded(probe.src)) probe.loadImage(probe.src); probe.requestPaint() } }
                onImageLoaded: requestPaint()
                // a hidden canvas drops its paint, and this flips mid-paint (tone is set
                // there) where requestPaint is ignored — so repaint on the next tick
                onVisibleChanged: if (visible) Qt.callLater(requestPaint)
                onPaint: {
                    if (!src || !isImageLoaded(src)) return
                    const ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.drawImage(src, 0, 0, width, height)
                    const d = ctx.getImageData(0, 0, width, height).data
                    let n = 0, lum = 0, sat = 0
                    for (let i = 0; i < d.length; i += 4) {
                        if (d[i + 3] < 100) continue
                        const r = d[i] / 255, g = d[i + 1] / 255, b = d[i + 2] / 255
                        const mx = Math.max(r, g, b), mn = Math.min(r, g, b)
                        lum += (mx + mn) / 2; sat += mx - mn; n++
                    }
                    if (n < 8) return   // not loaded yet: keep the last verdict
                    probed = true
                    lum /= n; sat /= n
                    entry.tone = sat > 0.18 ? 0 : lum > 0.7 ? 1 : lum < 0.3 ? -1 : 0
                    if (entry.tone === 0) return
                    // invert with blend modes (putImageData writes nothing in this Qt):
                    // white "difference" flips the colours, then the icon's own alpha
                    // masks it back to shape
                    ctx.save()
                    ctx.globalCompositeOperation = "qt-difference"
                    ctx.fillStyle = "white"
                    ctx.fillRect(0, 0, width, height)
                    ctx.globalCompositeOperation = "destination-in"
                    ctx.drawImage(src, 0, 0, width, height)
                    ctx.restore()
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
