import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

// A theme, previewed: its wallpaper with a mock desktop drawn in its own
// colours — the bar, a kitty running fastfetch, a Thunar window.
Item {
    id: tp
    required property var theme
    readonly property var c: theme.colors
    readonly property bool light: theme.mode === "light"
    readonly property string wall: theme.backgrounds && theme.backgrounds.length ? theme.backgrounds[0] : ""
    readonly property real k: width / 768       // everything is drawn for 768 wide and scaled
    readonly property color onWall: light ? "#141414" : "#ffffff"
    readonly property string host: hostFile.text().trim() || "arch"
    FileView { id: hostFile; path: "/etc/hostname" }
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

    // two tiled windows, like the rice's own screenshot: kitty running
    // fastfetch on the left, Thunar on the right, Hyprland border around each
    readonly property int winY: 44
    readonly property int winH: 475 - 44 - 10
    readonly property int winW: (768 - 10 * 2 - 8) / 2

    // ---- kitty + fastfetch ----
    Rectangle {
        x: 10 * tp.k; y: tp.winY * tp.k; width: tp.winW * tp.k; height: tp.winH * tp.k
        radius: 4 * tp.k; color: tp.c.bg0; border.width: 1; border.color: tp.c.accent_light; opacity: 0.97
        clip: true
        readonly property real fs: 6.6 * tp.k
        Text { x: 14 * tp.k; y: 10 * tp.k; text: "~ \u276f ff"; color: tp.c.accent_mid; font.pixelSize: parent.fs; font.family: Theme.font }
        Text {
            x: 14 * tp.k; y: 26 * tp.k
            text: "                  -`\n                 .o+`\n                `ooo/\n               `+oooo:\n              `+oooooo:\n              -+oooooo+:\n            `/:-:++oooo+:\n           `/++++/+++++++:\n          `/++++++++++++++:\n         `/+++ooooooooooooo/`\n        ./ooosssso++osssssso+`\n       .oossssso-````/ossssss+`\n      -osssssso.      :ssssssso.\n     :osssssss/        osssso+++.\n    /ossssssss/        +ssssooo/-\n  `/ossssso+/:-        -:/+osssso+-\n `+sso+:-`                 `.-/+oso:\n`++:.                           `-/+/\n.`                                 `/"
            color: tp.c.accent_light; font.pixelSize: parent.fs; font.family: Theme.font; lineHeight: 1.1
            textFormat: Text.PlainText
        }
        Column {
            x: 180 * tp.k; y: 26 * tp.k; spacing: 0
            Repeater {
                model: [
                    Quickshell.env("USER") + "@" + tp.host, "─────────────────",
                    "OS: Arch Linux x86_64", "Kernel: Linux cachyos", "Uptime: 5 mins",
                    "Packages: 1310 (pacman)", "Shell: zsh 5.9",
                    "WM: Hyprland (Wayland)", "Theme: " + tp.theme.name + " [GTK/Qt]",
                    "Icons: Papirus" + (tp.light ? "-Light" : "-Dark"), "Font: JetBrainsMono NF",
                    "Terminal: kitty", "CPU: Intel Core i7", "GPU: NVIDIA RTX 3070 Ti",
                    "Memory: 3.5 GiB / 31 GiB", "Disk (/): 18 GiB / 196 GiB",
                    "Battery: 100% [AC]", "Locale: en_US.UTF-8"
                ]
                Text { required property string modelData; required property int index
                       text: modelData; color: index === 0 ? tp.c.accent_bright : tp.c.fg
                       font.pixelSize: 6.6 * tp.k; font.family: Theme.font; lineHeight: 1.1 }
            }
            Item { width: 1; height: 8 * tp.k }
            Row {
                Repeater { model: [tp.c.bg0, tp.c.bg1, tp.c.bg2, tp.c.bg3, tp.c.accent_dim, tp.c.accent_mid, tp.c.accent_light, tp.c.accent_bright]
                           Rectangle { required property string modelData; width: 14 * tp.k; height: 8 * tp.k; color: modelData } }
            }
            Row {
                Repeater { model: [tp.c.bg1, tp.c.bg2, tp.c.bg3, tp.c.accent_dim, tp.c.accent_mid, tp.c.accent_light, tp.c.accent_bright, tp.c.fg]
                           Rectangle { required property string modelData; width: 14 * tp.k; height: 8 * tp.k; color: modelData } }
            }
        }
        Text { x: 14 * tp.k; y: parent.height - 24 * tp.k; text: "~ \u276f \u2588"; color: tp.c.accent_mid; font.pixelSize: parent.fs; font.family: Theme.font }
    }

    // ---- Thunar ----
    Rectangle {
        x: (10 + tp.winW + 8) * tp.k; y: tp.winY * tp.k; width: tp.winW * tp.k; height: tp.winH * tp.k
        radius: 4 * tp.k; color: tp.c.bg0; border.width: 1; border.color: tp.c.accent_mid; opacity: 0.97
        clip: true
        readonly property real fs: 7 * tp.k
        readonly property int side: 96
        // toolbar: nav buttons + path bar
        Rectangle {
            x: 1; y: 1; width: parent.width - 2; height: 26 * tp.k; color: tp.c.bg1
            Row { x: 8 * tp.k; anchors.verticalCenter: parent.verticalCenter; spacing: 4 * tp.k
                  Repeater { model: ["\u{f004d}", "\u{f0054}", "\u{f005d}", "\u{f02dc}"]
                             Rectangle { required property string modelData; width: 18 * tp.k; height: 18 * tp.k; radius: 3 * tp.k; color: tp.c.bg2
                                         Text { anchors.centerIn: parent; text: modelData; color: tp.c.fg; font.pixelSize: 9 * tp.k; font.family: Theme.font } } } }
            Rectangle { x: 100 * tp.k; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 108 * tp.k; height: 18 * tp.k
                        radius: 3 * tp.k; color: tp.c.bg0; border.width: 1; border.color: tp.c.bg3
                        Text { x: 8 * tp.k; anchors.verticalCenter: parent.verticalCenter; text: "/home/" + Quickshell.env("USER"); color: tp.c.fg; font.pixelSize: 7 * tp.k; font.family: Theme.font } }
        }
        // places sidebar
        Rectangle {
            x: 1; y: 27 * tp.k; width: parent.side * tp.k; height: parent.height - 28 * tp.k - 18 * tp.k; color: tp.c.bg1
            Column {
                x: 8 * tp.k; y: 8 * tp.k; spacing: 3 * tp.k
                Text { text: "Places"; color: tp.c.accent_mid; font.pixelSize: 6.5 * tp.k; font.family: Theme.font; font.weight: Font.Bold }
                Repeater {
                    model: [["\u{f02dc}", "Home"], ["\u{f0379}", "Desktop"], ["\u{f0219}", "Documents"], ["\u{f01da}", "Downloads"],
                            ["\u{f075a}", "Music"], ["\u{f021f}", "Pictures"], ["\u{f0567}", "Videos"], ["\u{f0a7a}", "Trash"]]
                    Rectangle { required property var modelData; required property int index
                                width: tp.k * 80; height: 14 * tp.k; radius: 3 * tp.k; color: index === 0 ? tp.c.bg3 : "transparent"
                                Row { x: 5 * tp.k; anchors.verticalCenter: parent.verticalCenter; spacing: 5 * tp.k
                                      Text { text: modelData[0]; color: tp.c.accent_light; font.pixelSize: 8 * tp.k; font.family: Theme.font }
                                      Text { text: modelData[1]; color: tp.c.fg; font.pixelSize: 7 * tp.k; font.family: Theme.font; anchors.verticalCenter: parent.verticalCenter } } }
                }
                Item { width: 1; height: 6 * tp.k }
                Text { text: "Devices"; color: tp.c.accent_mid; font.pixelSize: 6.5 * tp.k; font.family: Theme.font; font.weight: Font.Bold }
                Row { x: 5 * tp.k; spacing: 5 * tp.k
                      Text { text: "\u{f02ca}"; color: tp.c.accent_light; font.pixelSize: 8 * tp.k; font.family: Theme.font }
                      Text { text: "File System"; color: tp.c.fg; font.pixelSize: 7 * tp.k; font.family: Theme.font; anchors.verticalCenter: parent.verticalCenter } }
            }
        }
        // folder grid
        Grid {
            x: (parent.side + 16) * tp.k; y: 40 * tp.k; columns: 4; columnSpacing: 12 * tp.k; rowSpacing: 12 * tp.k
            Repeater {
                model: ["Desktop", "Documents", "Downloads", "Music", "Pictures", "Videos", "hypr-dotfiles", "Projects"]
                Column {
                    required property string modelData; required property int index
                    width: 52 * tp.k; spacing: 3 * tp.k
                    Item {
                        width: 52 * tp.k; height: 32 * tp.k
                        // Papirus-ish folder: back tab + front face
                        Rectangle { x: 12 * tp.k; y: 2 * tp.k; width: 14 * tp.k; height: 6 * tp.k; radius: 1.5 * tp.k; color: tp.c.accent_mid }
                        Rectangle { x: 12 * tp.k; y: 6 * tp.k; width: 28 * tp.k; height: 22 * tp.k; radius: 2 * tp.k; color: tp.c.accent_mid }
                        Rectangle { x: 12 * tp.k; y: 11 * tp.k; width: 28 * tp.k; height: 17 * tp.k; radius: 2 * tp.k; color: tp.c.accent_light }
                    }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData; color: tp.c.fg; font.pixelSize: 6.5 * tp.k; font.family: Theme.font; elide: Text.ElideRight; width: 52 * tp.k; horizontalAlignment: Text.AlignHCenter }
                }
            }
        }
        // status bar
        Rectangle {
            x: 1; y: parent.height - 19 * tp.k; width: parent.width - 2; height: 18 * tp.k; color: tp.c.bg1
            Text { x: 8 * tp.k; anchors.verticalCenter: parent.verticalCenter; text: "8 items, Free space: 178 GB"; color: tp.c.accent_mid; font.pixelSize: 6.5 * tp.k; font.family: Theme.font }
        }
    }
}
