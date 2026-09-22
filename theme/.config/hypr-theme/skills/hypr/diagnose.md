# Diagnose — "something is wrong with my PC / the rice"

Work from evidence. Establish facts, then rule out the boring causes, then
correlate on the timeline. Do not narrate a plausible story you have not
checked. Say what you found, what you ruled out, and what you could not tell.

## 1. Collect

```bash
hypr-doctor --print         # everything below in one bundle, no sudo, no prompts
```
It reports: versions (hyprland, quickshell, kernel, driver), GPU + which one
renders, monitors/scale, `hyprctl configerrors`, shell log warnings/errors,
failed systemd units (system + user), journal errors since boot, recent
crashes (`coredumpctl list`), CPU/mem/disk/thermal/battery health, power
profile, network state, pacman log (last upgrades), stow/link health
(`~/.config/hypr` etc. pointing into the repo), theme state, and the
processes that should be running (qs, polkit agent, cliphist watch).

Ask the user for the symptom in one line if it is vague: what, since when,
what changed (update? new package? new cable?).

## 2. Rule out the boring causes first

- Resource exhaustion: `free -h`, `df -h ~ /`, OOM kills in the journal
  (`journalctl -k -b | grep -i oom`). A process killed by the OOM killer is
  not a bug in that process.
- Thermal throttling: `sensors`, `cat /sys/class/thermal/thermal_zone*/temp`,
  power profile (`powerprofilesctl get`), caffeine/inhibitors (`systemd-inhibit --list`).
- The obvious: cable, muted sink (`wpctl status`), wifi radio off (`nmcli radio`),
  monitor scale after a mode change, a stale shell (`qs log` errors → `shell.sh restart`).

## 3. Correlate against the timeline

- **When did it start?** `journalctl -b -p warning --since "<time>"`, the pacman log
  (`/var/log/pacman.log`) for an upgrade right before, file mtimes in `~/.config`
  landing on the same minute (a config change is the usual suspect on a rice).
- **Is it a pattern?** `coredumpctl list` — one crash vs the same program dying repeatedly
  vs several programs dying together point in different directions.
- **Is it us?** Undo the rice's part to bisect: `hyprctl reload` with a module
  commented, `shell.sh restart`, switch theme (`hypr-theme set hyprmono`), run the app
  from a terminal to see its stderr, `git log --since=… --stat` for what changed here.

## 4. Crashes (adapted from Omarchy's diagnose-crash)

`coredumpctl info <pid|name>`: beyond the backtrace, note the **command line**
the process started with — it often names what it was working on. Check other
threads' stacks for what was in flight (thumbnailers, GPU queues, plugins).
Third-party code in the address space (extensions, out-of-tree drivers) is a
common cause — flag it, but do not blame it without evidence. Symbolize with
debuginfod (Arch runs one): `DEBUGINFOD_URLS=https://debuginfod.archlinux.org
coredumpctl debug <pid> --debugger-arguments="-batch -ex 'thread apply all bt'"`.
If it is a Hyprland or Quickshell bug, gather version + steps + log and offer
to file it upstream; do not "fix" it by disabling half the rice.

## 5. Common rice-specific causes (check these before anything exotic)

| Symptom | Look at |
|---|---|
| bar/launcher/lock missing, widgets blank | `qs log`; `pgrep -x qs`; `shell.sh restart`; a QML error in the last edited file |
| theme half applied (GTK app dark in light) | GTK3/Qt read theme at start → restart the app; `hypr-theme reload`; root apps need root-sync (`sudo hypr-theme-root-sync`) |
| icons are boxes | font: `fc-list | grep -i "JetBrainsMono Nerd Font Propo"` |
| keybind does nothing | `hyprctl configerrors`; `hyprctl binds -j | grep`; the script has `+x` and is on PATH (`~/.local/bin` is added in env.lua) |
| lock screen wrong size / tiny box | monitor scale: fractional scale rounding — see plugins.md pitfalls |
| no sleep / lock | caffeine on (`qs ipc call caffeine status`), `systemd-inhibit --list`, hypridle running twice |
| `~/.local` or `~/.config/x` is a symlink into the repo (stow folded) | install.sh pre-flight; `stow -D` the package, recreate the dir, `stow -R` |
| high battery drain | `powerprofilesctl`, `powertop --html` (asks sudo — user runs it), GPU on (`cat /sys/class/drm/card*/device/power_state`), a runaway process in `hypr-doctor` top list |

## 6. Report

Findings first (facts with the command that proves each), then the cause if
established, the fix applied (and how to undo it), and what remains unknown.
Never "fix" by deleting user data or resetting configs without asking.
