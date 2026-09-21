pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

// Session lock state + PAM. The Lock/LockScreen window binds to `locked`.
// `loginctl lock-session` reaches us through hypridle's lock_cmd
// ('qs ipc call lock lock'); so does SUPER+L.
Singleton {
    id: root
    property bool locked: false
    property bool busy: false
    property string error: ""
    property int failures: 0

    function lock() { error = ""; failures = 0; locked = true }
    function unlock() { locked = false; busy = false; error = "" }

    function tryPassword(pw) {
        if (busy || pw.length === 0) return
        busy = true; error = ""
        pending = pw
        pam.start()
    }
    property string pending: ""

    PamContext {
        id: pam
        config: "hyprlock"          // /etc/pam.d/hyprlock: 'auth include login'
        user: Quickshell.env("USER")
        onResponseRequiredChanged: if (responseRequired) { respond(root.pending); root.pending = "" }
        onCompleted: (result) => {
            root.busy = false
            if (result === PamResult.Success) root.unlock()
            else { root.failures++; root.error = result === PamResult.MaxTries ? "Too many attempts" : "Wrong password" }
        }
        onError: (e) => { root.busy = false; root.error = "Authentication error" }
    }

    IpcHandler {
        target: "lock"
        function lock(): void { root.lock() }
        function status(): string { return root.locked ? "locked" : "unlocked" }
    }
}
