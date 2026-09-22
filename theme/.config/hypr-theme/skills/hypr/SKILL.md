---
name: hypr
description: >
  REQUIRED for anything about this Hyprland rice (~/hypr-dotfiles): themes and
  colours, wallpapers, the Quickshell bar/panels/launcher/lock/picker and their
  plugins, keybindings, window/layer rules, monitors, Hyprland Lua config,
  terminals, nvim/btop/GTK/Qt theming, install.sh/stow, diagnosing the PC
  (crashes, logs, performance, battery, display), and checking that the rice
  looks right. Triggers: theme, rice, bar, widget, plugin, panel, launcher,
  lock screen, wallpaper, keybind, hyprland, quickshell, shell.json, colors.toml,
  hypr-theme, hypr-wall, hypr-agent, diagnose, doctor, crash, "why is X broken",
  screenshot check. One skill: read the request, pick the matching section.
---

# /hypr — this rice, one skill

Request: $ARGUMENTS

You are working on **martin's monochrome Hyprland rice**. Everything lives
in the git repo `~/hypr-dotfiles` and is *symlinked* into `~` with GNU stow
(one package per app: `hyprland quickshell theme kittyterminal alacritty
nvim zsh starship gtk sddm`; `waybar rofi swaync wlogout` are legacy
fallbacks kept for when the shell is not running). **Edit files in the repo**
— `~/.config/hypr` *is* `~/hypr-dotfiles/hyprland/.config/hypr` — and commit
when done, without "Co-Authored-By" or "Generated with" lines.

## 1. Decide what the request is, then read the matching guide

| The request is about… | Guide | Typical words |
|---|---|---|
| a new theme, colours, dark/light, wallpaper, an app not following the theme | [`theming.md`](theming.md) | theme, palette, colors.toml, wallpaper, "make X follow the theme" |
| the bar, a widget, a panel, launcher/clipboard/picker/lock/power/notifications, IPC, shell.json | [`plugins.md`](plugins.md) | bar, widget, plugin, module, panel, popup, quickshell, qml |
| keybindings, window/layer rules, monitors, gaps/borders/animations, autostart, idle | [`hyprland.md`](hyprland.md) | bind, key, rule, monitor, scale, gaps, blur, opacity, autostart |
| something broken, slow, crashing, hot, draining, not showing; "diagnose my PC" | [`diagnose.md`](diagnose.md) | crash, error, log, freeze, lag, battery, wifi, sound, gpu, "why" |
| "check the rice", "does it look right", screenshots, before/after comparison | [`verify.md`](verify.md) | check, verify, screenshot, identical, readable |
| install.sh, stow, a fresh machine, packages | §5 below + `install.sh` header | install, stow, fresh, package |

A request can span guides ("make a theme and a widget for it") — read both.
When the wording is ambiguous, ask one short question **before** changing
anything; otherwise just do it.

## 2. The map

```
~/hypr-dotfiles/
├── install.sh                       fresh-machine installer (packages, migration, stow, theme, SDDM, sudoers)
├── hyprland/.config/hypr/
│   ├── hyprland.lua                 requires modules/*, then the theme's current/hyprland.lua
│   ├── modules/{env,autostart,binds,monitors,decorations,windowrules}.lua
│   ├── hypridle.conf  hyprlock.conf (fallbacks; the shell owns idle + lock)
│   └── scripts/  shell.sh lock.sh launcher.sh clipboard.sh powermenu.sh caffeine.sh brightness.sh
├── quickshell/.config/quickshell/   THE SHELL (Quickshell 0.3, QML) — see plugins.md
│   ├── shell.qml  Commons/{Theme,Config}.qml  Services/*.qml (singletons + IPC)
│   ├── Bar/ Panels/ Launcher/ Clipboard/ Picker/ Lock/ Power/ Notifications/ Osd/ Wallpaper/
├── theme/.config/hypr-theme/        THE THEME ENGINE — see theming.md
│   ├── themes/<id>/colors.toml + backgrounds/      one folder = one theme (picker auto-discovers)
│   ├── templates/*.tpl              one per app, rendered by render.py
│   ├── current/  → GENERATED. never edit; re-render with `hypr-theme reload`
│   ├── shell.json                   shell settings (bar position/skin layouts, modules, agents.default)
│   ├── menu.jsonc (+ menu.local.jsonc)   the SUPER+SPACE menu tree — see plugins.md
│   ├── agents/usage.py  skills/hypr/  plugins/  root-sync.sh
├── theme/.local/bin/  hypr-theme  hypr-wall  hypr-theme-menu  hypr-agent  hypr-doctor
├── sddm/  gtk/  nvim/  kittyterminal/  alacritty/  zsh/  starship/
└── README.md                        read its "Theming" and "Bar" sections when unsure
```

Commands you will use (all `--help`/header-documented — read the script if unsure):

| Command | Does |
|---|---|
| `hypr-theme list / current / set <id> / toggle / next / reload / json` | apply a theme everywhere (renders templates → current/, installs GTK/Qt/KDE/btop files, reloads kitty/hyprland/nvim/shell, root+SDDM sync) |
| `hypr-wall set <path> / next / current / ensure` | wallpaper (shell layer; also lock + SDDM) |
| `hypr-theme-menu theme|wallpaper` | open the carousel picker |
| `qs ipc call <target> <fn> [args]` | talk to the running shell. Targets: `bar theme wallpaper picker launcher clipboard notifications panels powermenu lock caffeine osd agents menu` (`qs ipc show` lists functions) |
| `qs log` | the shell's log (QML errors show here) |
| `~/.config/hypr/scripts/shell.sh restart` | restart the shell (needed after new files/qmldir changes; hot-reload can serve stale code) |
| `hyprctl reload && hyprctl configerrors` | after ANY Hyprland change; must print nothing |
| `hypr-agent list / default / launch / usage / skills install` | coding agents |
| `hypr-doctor [--print]` | diagnostics bundle (see diagnose.md) |
| `hypr-text-size <px>` · `hypr-scale <n>` | apparent text size (shell + GTK + terminals) and monitor scale |
| `qs ipc call menu open|run|search <id>` · `hypr-float <cmd>` · `hypr-edit <file>` · `hypr-toggle gaps|opacity` · `hypr-nightlight` · `hypr-remind` · `hypr-default` · `hypr-pkg` | menu actions, usable from anywhere |

## 3. Rules that keep the rice intact

1. **Never edit generated or foreign files**: `~/.config/hypr-theme/current/*`,
   `~/.config/gtk-3.0/settings.ini`, `~/.config/kdeglobals`, `~/.config/qt5ct|qt6ct`,
   `~/.config/btop/themes/hypr-theme.theme`, `/usr/share/**`, `/etc/**`
   (except through install.sh). They are rendered from `templates/*.tpl` —
   change the template (all themes) or `colors.toml` (one theme).
2. **Colour is the default; monochrome only when martin says so.** The two
   `hyprmono*` themes are the old greys-only look (plus `[git]` hues) and stay
   that way. Every other theme is **hued**: `hued = true` in colors.toml, the
   palette's official colours, and each app coloured the way its stock
   upstream theme does — btop one hue per box + real gradients, nvim's own
   scheme, bar battery green/yellow/red, critical notification red, lock fail
   red. Templates branch with `{{ hued <colour> <grey> }}` and QML with
   `Theme.hued ? Theme.c.good|warning|critical : <shade>`, so the mono themes
   stay pixel-identical (diff `render.py` output). Grey in a hued theme where
   a stock theme has colour is a bug, not restraint. Corners 4px
   (`Theme.radius`), 1px border (`Theme.c.border`) everywhere, in every theme.
3. **Both modes, always.** Anything visual is checked on `hyprmono` (dark)
   and `hyprmono-light` — `hypr-theme set <id>` swaps live; put the user's
   theme back when done (`hypr-theme current` first). A template change is
   also checked on one hued theme (`catppuccin-mocha`). When the request *was*
   "make me theme X", leave X applied at the end.
4. **Look at it.** Every visual change ends with a screenshot you actually
   read (verify.md). "It should work" is not done.
5. **Do not break the session.** Never `pkill -f qs|quickshell|hypr` (matches
   your own shell); use `pkill -x`. Never run `hyprctl dispatch exit`,
   `loginctl terminate-*`, or a lock test you cannot unlock (`Lock.lock()`
   locks the real session — if you must, keep a terminal with
   `hyprctl eval 'hl.clear_crashed_lockscreen()'` ready). No `sudo` prompts
   in a non-interactive run: use `hypr-doctor` (no-sudo) or ask the user to
   run the privileged step.
6. **Backups are git.** Work on the current branch; `git stash`/`git checkout
   -- <file>` undoes a bad change. Before deleting or overwriting anything
   outside the repo, look at it.
7. **Fresh install must still work.** If you add a package, a file the theme
   installs, a stow package or a sudo step, update `install.sh` and README.

## 4. How a change is applied (live vs restart)

| You changed | Apply with |
|---|---|
| `themes/*/colors.toml`, `templates/*.tpl` | `hypr-theme reload` (or `set`) |
| `quickshell/**.qml` existing file | hot-reloads on save; if errors persist or a `qmldir` / new file is involved → `shell.sh restart` |
| `shell.json` | hot-reloads (Config watches it) |
| `hyprland/**.lua` | `hyprctl reload && hyprctl configerrors` |
| kitty.conf | `pkill -SIGUSR1 -x kitty` |
| GTK3 apps, Qt apps, Kdenlive, Alacritty | need an app restart (documented; not a bug) |
| `theme/.local/bin/*`, new stow files | `cd ~/hypr-dotfiles && stow -R theme` (a new *file* in an already-linked dir needs nothing; a new *dir* needs restow) |

## 5. Fresh machine / install.sh

`install.sh` is the source of truth for packages (`PKGS_REPO`, `PKGS_AUR`),
stow packages (`PACKAGES`), migration of pre-existing configs, pre-flight
guards against stow "folding" `~/.local`, Qt env, theme apply, SDDM theme and
the root-sync sudoers rule. It is idempotent; `--dry-run` exists. When you
add anything a fresh user needs, add it there and bump `STEP_TOTAL` if you
add a step. Test with a fake HOME only if you can fully stub the tools
(`hyprctl`, `qs`, `awww`, `gsettings`) — an earlier run leaked into the live
session.

## 6. Finish

- Screenshot-verified in dark and light (verify.md), `hyprctl configerrors`
  clean, `qs log` free of new warnings.
- README updated if a user-facing thing changed (keybind table, widget list,
  live-vs-restart table).
- One commit, message says *why*; no attribution lines.
- Tell the user in a few lines what changed and how to use it; include the
  keybinding or command.
