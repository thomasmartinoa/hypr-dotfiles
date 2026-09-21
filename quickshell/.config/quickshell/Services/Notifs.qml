pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// The notification daemon. Replaces swaync: popups top-right, a history
// for the bell's centre, do-not-disturb. Notifications stay tracked until
// dismissed from the centre, so the history survives popup timeouts.
Singleton {
    id: root

    property bool dnd: false
    // newest first; each entry wraps a Notification with our own bookkeeping
    property var items: []
    readonly property int count: items.length
    readonly property var popups: items.filter(e => e.popup)

    function toggleDnd() { dnd = !dnd }

    function add(n) {
        n.tracked = true
        const entry = { n: n, id: n.id, popup: !dnd, time: new Date() }
        items = [entry].concat(items)
        if (entry.popup) {
            // 5s, 10s for critical, or what the app asked for (ms; -1 = default)
            const t = n.expireTimeout > 0 ? n.expireTimeout
                    : n.urgency === NotificationUrgency.Critical ? 10000 : 5000
            popupTimer.createObject(root, { entry: entry, interval: t })
        }
    }
    function hidePopup(entry) {
        entry.popup = false
        items = items.slice()          // rebind
    }
    function dismiss(entry) {
        entry.n.dismiss()
        items = items.filter(e => e !== entry)
    }
    function clearAll() {
        for (const e of items) e.n.dismiss()
        items = []
    }
    function invokeDefault(entry) {
        const acts = entry.n.actions
        let a = acts.find(x => x.identifier === "default") || acts[0]
        if (a) a.invoke()
        dismiss(entry)
    }

    Component {
        id: popupTimer
        Timer {
            property var entry
            running: true
            onTriggered: { root.hidePopup(entry); destroy() }
        }
    }

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true
        onNotification: (n) => root.add(n)
    }
    // app closed / replaced it itself
    Connections {
        target: server
        function onTrackedNotificationsChanged() {
            const live = server.trackedNotifications.values
            root.items = root.items.filter(e => live.indexOf(e.n) !== -1)
        }
    }

    IpcHandler {
        target: "notifications"
        function dnd(): bool { root.toggleDnd(); return root.dnd }
        function clear(): void { root.clearAll() }
        function count(): int { return root.count }
    }
}
