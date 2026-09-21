import QtQuick
import Quickshell
import qs.Bar
import qs.Osd
import qs.Wallpaper
import qs.Notifications
import qs.Lock
import qs.Power
import qs.Picker
import qs.Launcher
import qs.Services

// hypr-dotfiles shell. Bars come first; panels, OSD, wallpaper,
// notifications, lock and launcher follow (see the README roadmap).
ShellRoot {
    WallpaperWindow {}
    Bar {}
    OsdWindow {}
    NotificationPopups {}
    LockScreen {}
    PowerMenu {}
    ImagePicker {}
    Launcher {}
    // singletons only come alive when referenced; these must run from the start
    Scope { Component.onCompleted: { void Idle.paused; void Caffeine.on; void Notifs.count; void Themes.themes } }
}
