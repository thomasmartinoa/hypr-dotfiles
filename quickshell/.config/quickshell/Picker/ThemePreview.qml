import QtQuick
import qs.Commons

// A theme, previewed: its wallpaper with a mock desktop drawn in its own
// colours — the bar, a window, a terminal with the palette.
Item {
    id: tp
    required property var theme
    readonly property var c: theme.colors
    readonly property bool light: theme.mode === "light"
    readonly property string wall: theme.backgrounds && theme.backgrounds.length ? theme.backgrounds[0] : ""
    readonly property real k: width / 768       // everything is drawn for 768 wide and scaled
    readonly property color onWall: light ? "#141414" : "#ffffff"
    clip: true

    Image {
        anchors.fill: parent
        source: tp.wall !== "" ? "file://" + tp.wall : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize: Qt.size(1024, 640)
        cache: true
    }

    // bar (pill or minimal, whichever the theme asks for)
    Item {
        x: 12 * tp.k; y: 10 * tp.k; width: parent.width - 24 * tp.k; height: 26 * tp.k
        Rectangle {
            visible: tp.theme.bar !== "pill"
            anchors.fill: parent; radius: 3 * tp.k; color: tp.c.bg0
            Row { x: 10 * tp.k; anchors.verticalCenter: parent.verticalCenter; spacing: 8 * tp.k
                  Repeater { model: ["1", "●", "3"]; Text { required property string modelData; text: modelData; color: index === 1 ? tp.c.fg : tp.c.accent_mid; font.pixelSize: 11 * tp.k; font.family: Theme.font; required property int index } } }
            Text { anchors.centerIn: parent; text: "Tuesday 09:41"; color: tp.c.fg; font.pixelSize: 11 * tp.k; font.family: Theme.font }
            Row { anchors.right: parent.right; anchors.rightMargin: 10 * tp.k; anchors.verticalCenter: parent.verticalCenter; spacing: 10 * tp.k
                  Repeater { model: 5; Rectangle { width: 9 * tp.k; height: 9 * tp.k; radius: 2 * tp.k; color: tp.c.accent_light } } }
        }
        Row {
            visible: tp.theme.bar === "pill"
            spacing: 8 * tp.k
            Repeater {
                model: [46, 90]
                Rectangle { required property int modelData; width: modelData * tp.k; height: 26 * tp.k; radius: 5 * tp.k
                            color: tp.c.bg0; border.width: 1; border.color: tp.c.bg3
                            Row { anchors.centerIn: parent; spacing: 4 * tp.k
                                  Repeater { model: modelData > 50 ? 3 : 1; Rectangle { required property int index; width: 22 * tp.k; height: 16 * tp.k; radius: 3 * tp.k
                                             color: index === 1 ? tp.c.fg : tp.c.bg2 } } } }
            }
        }
        Row {
            visible: tp.theme.bar === "pill"
            anchors.right: parent.right; spacing: 8 * tp.k
            Repeater { model: [44, 80, 44, 26, 26]
                       Rectangle { required property int modelData; width: modelData * tp.k; height: 26 * tp.k; radius: 5 * tp.k
                                   color: tp.c.bg0; border.width: 1; border.color: tp.c.bg3
                                   Rectangle { anchors.centerIn: parent; width: parent.width - 16 * tp.k; height: 8 * tp.k; radius: 2 * tp.k; color: tp.c.accent_light } } }
        }
    }

    // a window: title, some text, a button row
    Rectangle {
        x: 36 * tp.k; y: 60 * tp.k; width: 300 * tp.k; height: 220 * tp.k
        radius: 4 * tp.k; color: tp.c.bg0; border.width: 1; border.color: tp.c.accent_light; opacity: 0.96
        Rectangle { x: 1; y: 1; width: parent.width - 2; height: 28 * tp.k; color: tp.c.bg1; radius: 4 * tp.k
                    Text { x: 12 * tp.k; anchors.verticalCenter: parent.verticalCenter; text: "thunar — " + tp.theme.name; color: tp.c.fg; font.pixelSize: 11 * tp.k; font.family: Theme.font } }
        Column {
            x: 14 * tp.k; y: 42 * tp.k; spacing: 8 * tp.k
            Repeater {
                model: [[0.9, "fg"], [0.6, "accent_mid"], [0.75, "fg"], [0.4, "accent_dim"], [0.55, "accent_mid"], [0.8, "fg"], [0.3, "accent_dim"]]
                Rectangle { required property var modelData; width: 260 * tp.k * modelData[0]; height: 6 * tp.k; radius: 2 * tp.k; color: tp.c[modelData[1]] }
            }
        }
        Row {
            anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 12 * tp.k; spacing: 8 * tp.k
            Rectangle { width: 56 * tp.k; height: 20 * tp.k; radius: 3 * tp.k; color: tp.c.bg2; border.width: 1; border.color: tp.c.bg3 }
            Rectangle { width: 56 * tp.k; height: 20 * tp.k; radius: 3 * tp.k; color: tp.c.fg }
        }
    }

    // a terminal: prompt lines + the 8 palette colours
    Rectangle {
        x: parent.width - 262 * tp.k; y: parent.height - 190 * tp.k; width: 226 * tp.k; height: 150 * tp.k
        radius: 4 * tp.k; color: tp.c.bg0; border.width: 1; border.color: tp.c.bg3; opacity: 0.92
        Column {
            x: 12 * tp.k; y: 12 * tp.k; spacing: 6 * tp.k
            Text { text: "~ ❯ hypr-theme set"; color: tp.c.fg; font.pixelSize: 10 * tp.k; font.family: Theme.font }
            Text { text: tp.theme.id; color: tp.c.accent_light; font.pixelSize: 10 * tp.k; font.family: Theme.font }
            Text { text: tp.theme.mode + " mode"; color: tp.c.accent_mid; font.pixelSize: 10 * tp.k; font.family: Theme.font }
            Item { width: 1; height: 6 * tp.k }
            Row { spacing: 4 * tp.k
                  Repeater { model: [tp.c.bg0, tp.c.bg2, tp.c.accent_dim, tp.c.accent_mid, tp.c.accent_light, tp.c.accent_bright]
                             Rectangle { required property string modelData; width: 18 * tp.k; height: 18 * tp.k; radius: 3 * tp.k; color: modelData
                                         border.width: 1; border.color: tp.c.bg3 } } }
        }
    }
}
