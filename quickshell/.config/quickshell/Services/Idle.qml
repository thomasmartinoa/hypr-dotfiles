pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Services

// Idle timers (replaces hypridle's listeners). Same steps as the old
// hypridle.conf: dim, keyboard backlight, lock, screen off, suspend.
// Caffeine pauses all of them; a wayland idle inhibitor (video playing)
// does too. hypridle itself stays only as the logind bridge: it turns
// `loginctl lock-session` and the pre-sleep hook into 'qs ipc call lock lock'.
Singleton {
    id: root

    property int dimAfter:     300
    property int kbdAfter:     250
    property int lockAfter:    1800
    property int screenAfter:  2500
    property int suspendAfter: 3600
    readonly property bool paused: Caffeine.on

    function sh(cmd) { Quickshell.execDetached(["bash", "-c", cmd]) }

    IdleMonitor {
        enabled: !root.paused; respectInhibitors: true; timeout: root.dimAfter
        onIsIdleChanged: root.sh(isIdle ? "brightnessctl -d intel_backlight -s set 10%" : "brightnessctl -d intel_backlight -r")
    }
    IdleMonitor {
        enabled: !root.paused; respectInhibitors: true; timeout: root.kbdAfter
        onIsIdleChanged: root.sh(isIdle ? "brightnessctl -sd rgb:kbd_backlight set 0" : "brightnessctl -rd rgb:kbd_backlight")
    }
    IdleMonitor {
        enabled: !root.paused; respectInhibitors: true; timeout: root.lockAfter
        onIsIdleChanged: if (isIdle) Lock.lock()
    }
    IdleMonitor {
        enabled: !root.paused; respectInhibitors: true; timeout: root.screenAfter
        onIsIdleChanged: {
            Quickshell.execDetached(["hyprctl", "dispatch", isIdle ? 'hl.dsp.dpms("off")' : 'hl.dsp.dpms("on")'])
            if (!isIdle) root.sh("brightnessctl -r")
        }
    }
    IdleMonitor {
        enabled: !root.paused; respectInhibitors: true; timeout: root.suspendAfter
        onIsIdleChanged: if (isIdle) root.sh("systemctl suspend")
    }
}
