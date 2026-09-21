import Quickshell
import qs.Bar
import qs.Osd
import qs.Wallpaper
import qs.Notifications

// hypr-dotfiles shell. Bars come first; panels, OSD, wallpaper,
// notifications, lock and launcher follow (see the README roadmap).
ShellRoot {
    WallpaperWindow {}
    Bar {}
    OsdWindow {}
    NotificationPopups {}
}
