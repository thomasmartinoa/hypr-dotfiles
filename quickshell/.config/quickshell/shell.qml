import Quickshell
import qs.Bar
import qs.Osd

// hypr-dotfiles shell. Bars come first; panels, OSD, wallpaper,
// notifications, lock and launcher follow (see the README roadmap).
ShellRoot {
    Bar {}
    OsdWindow {}
}
