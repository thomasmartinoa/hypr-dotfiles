pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// The notification daemon. Replaces swaync: popups top-right, a history
// for the bell's centre, do-not-disturb. Notifications stay tracked until
// dismissed from the centre, so the history survives popup timeouts.
//
// Survives hot reloads: the server keeps its notifications (keepOnReload),
// the list is rebuilt from them on start, and every operation tolerates a
// notification the app already closed.
Singleton {
    id: root

    property bool dnd: false
    // newest first; each entry wraps a Notification with our own bookkeeping
    property var items: []
    readonly property int count: items.length
    readonly property var popups: items.filter(e => e.popup && e.n)

    function toggleDnd() { dnd = !dnd }
    function alive(n) { try { return n && n.id !== undefined } catch (e) { return false } }
    function commit() { items = items.filter(e => root.alive(e.n)) }   // rebind + prune dead ones

    function add(n, showPopup) {
        n.tracked = true
        const entry = { n: n, id: n.id, popup: showPopup && !dnd, time: new Date() }
        items = [entry].concat(items)
        if (entry.popup) {
            // 5s, 10s for critical, or what the app asked for (ms; -1 = default)
            const t = n.expireTimeout > 0 ? n.expireTimeout
                    : n.urgency === NotificationUrgency.Critical ? 10000 : 5000
            popupTimer.createObject(root, { entryId: entry.id, interval: t })
        }
        n.closed.connect(() => root.remove(entry))
    }
    // Entries read back from `items` are copies (a var array is stored as a
    // QVariantList), so state changes go by id and rebuild the list.
    function hidePopup(entry) { items = items.filter(e => root.alive(e.n)).map(e => e.id === entry.id ? Object.assign({}, e, { popup: false }) : e) }
    function remove(entry) { items = items.filter(e => e.id !== entry.id && root.alive(e.n)) }
    function dismiss(entry) {
        try { if (alive(entry.n)) entry.n.dismiss() } catch (e) {}
        remove(entry)
    }
    function clearAll() {
        for (const e of items) { try { if (alive(e.n)) e.n.dismiss() } catch (err) {} }
        items = []
    }
    function invokeDefault(entry) {
        try {
            const acts = entry.n.actions
            const a = acts.find(x => x.identifier === "default") || acts[0]
            if (a) a.invoke()
        } catch (e) {}
        dismiss(entry)
    }

    Component {
        id: popupTimer
        Timer {
            property int entryId
            running: true
            onTriggered: { root.hidePopup({ id: entryId }); destroy() }
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
        onNotification: (n) => root.add(n, true)
    }
    // after a reload: adopt what the server kept, as history (no popups)
    Component.onCompleted: {
        for (const n of server.trackedNotifications.values) root.add(n, false)
    }
    // app closed / replaced it itself
    Connections {
        target: server
        function onTrackedNotificationsChanged() {
            const live = server.trackedNotifications.values
            root.items = root.items.filter(e => root.alive(e.n) && live.indexOf(e.n) !== -1)
        }
    }

    property bool ccOpen: false

    IpcHandler {
        target: "notifications"
        function dnd(): bool { root.toggleDnd(); return root.dnd }
        function clear(): void { root.clearAll() }
        function count(): int { return root.count }
        function test(): void { Quickshell.execDetached(["notify-send", "-a", "shell", "Test", "notification from the shell"]) }
    }
}
