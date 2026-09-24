# Theming — themes, colours, wallpapers, apps that must follow

## How it works

`hypr-theme set <id>` reads `themes/<id>/colors.toml`, renders every
`templates/*.tpl` into `~/.config/hypr-theme/current/`, installs the files apps
cannot import from there (GTK settings.ini, kdeglobals, qt5ct/qt6ct, btop
theme, VS Code extension), pokes running apps (hyprctl reload, kitty SIGUSR1,
nvim remote, btop SIGUSR2, `qs ipc call theme reload`), ensures a wallpaper
from the theme's `backgrounds/`, and syncs `/root` + SDDM through the sudoers
helper. The shell reads `current/colors.json` live (`Commons/Theme.qml`).

```
themes/<id>/
├── colors.toml     name, mode (dark|light), bar (pill|floating|minimal), [colors] [terminal] [git] [apps]
└── backgrounds/    1-*.png|jpg … first one is the default wallpaper
templates/<app>.tpl → current/<app>
```

Template tags (`render.py` header has the full list):
`{{ bg0 }}`, `{{ bg0 | rgba 0.6 }}`, `{{ bg0 | hypr }}`, `{{ bg0 | argb 0.1 }}`,
`{{ mix bg0 fg 20% }}`, `{{ dark "1" "0" }}`, `{{ mode }}`, `{{ name }}`, `{{ home }}`,
plus any key from `[terminal]`, `[git]`, `[apps]`.

## Make a new theme

1. `cp -r themes/hyprmono themes/<id>` (or `hyprmono-light` for a light one).
   `<id>` is lowercase-with-dashes; `name` in colors.toml is the display name.
2. Edit `colors.toml`:
   - `mode` drives GTK (`adw-gtk3` / `adw-gtk3-dark`), Qt (`Adwaita` / `Adwaita-Dark`),
     icons (Papirus-Light / Papirus-Dark), nvim `background`, the shell's `Theme.light`.
   - **The ramp**: `bg0 < bg1 < bg2 < bg3 < bg4` backgrounds (bg0 = bar/cards), then
     `accent_dim < accent_mid < accent_light < accent_bright` and `fg` for text.
     Dark: bg0 ≈ #0a0a0a, fg ≈ #e8e8e8. Light: bg0 ≈ #f4f4f4, fg ≈ #141414.
     A tinted theme keeps the same *luminance* steps, only the hue changes.
   - **Contrast targets** (WCAG-ish): `fg` on `bg0` ≥ 12:1, `accent_mid` on `bg0` ≥ 4.5:1
     (it is used for secondary text everywhere), `accent_dim` on `bg0` ≥ 3:1 (inactive).
     Light themes fail here first — the previous light theme needed its greys darkened.
   - `[terminal]` 16 colours are a grey ramp too; keep `background` = bg0-ish and
     `foreground` readable through kitty's translucency (light: darker than you think).
   - `[git]` keeps real hues. `[apps]` names the GTK/Qt/icon/cursor themes and `nvim_colorscheme`
     (any installed scheme works — LazyVim already ships `catppuccin-*` and `tokyonight-*`;
     `hyprmono` is the generated grey one; check `ls ~/.local/share/nvim/lazy/` before naming another).
   - `bar = "pill"|"floating"|"minimal"` is the skin the theme prefers (pill is shown as "Legacy").
   - **Hued theme** — the default for any new theme unless the user asks for monochrome:
     `hued = true` at the top, the ramp uses the
     palette's own surface/text steps (Mocha: crust→mantle→base→surface0→surface1, text/subtext/
     overlay), `accent_bright`/`active` = the palette's accent (Mocha: lavender), and the hue keys
     `red orange yellow green aqua blue purple` + `warning critical` carry the *real* colours
     (in mono themes they are greys). `[terminal]` is the palette's official 16-colour set.
     Copy `themes/catppuccin-mocha/` as the starting point instead of hyprmono.
     Official palettes are usually already on disk: `~/.local/share/nvim/lazy/<scheme>/extras/kitty/*.conf`
     (tokyonight, catppuccin) is the exact 16-colour set and `lua/<scheme>/colors/*.lua` the ramp — read
     those instead of guessing hex values from memory.
3. Wallpaper: put one or more images in `backgrounds/` named `1-<slug>.png`, `2-…`.
   Match the mood (dark theme → dark image, light → bright). Prefer ≥ 2560 px wide,
   non-busy, so lock/login text stays readable over the blur. If downloading, use a
   source that allows reuse (Unsplash / Pexels / Wikimedia) and note the URL in a
   `backgrounds/SOURCES` file.
4. `hypr-theme set <id>` — it appears in the carousel (`SUPER+CTRL+SHIFT+SPACE`) automatically.
5. **Verify in every surface** (verify.md). For btop use `hypr-float btop`
   (a tiled kitty next to other windows is < 80×24 and btop only prints "Terminal size too
   small"). `hypr-wall next` cycles to the theme's other backgrounds. Verify: bar (every skin: `qs ipc call bar toggle` cycles them),
   launcher `SUPER+D`, clipboard, notification (`qs ipc call notifications test`),
   panels (audio/network/power/agents), picker, power menu, lock screen (careful —
   see SKILL rule 5; the SDDM Main.qml uses the same geometry, so a screenshot of
   the lock screen stands in), kitty + fastfetch, btop, nvim, Thunar (GTK3, restart it),
   a Qt app (qt6ct-aware, restart it), VS Code. Fix any unreadable text by adjusting
   the ramp, not one app.
6. The theme is the user's: `themes/<id>/` is gitignored, so it stays on
   this machine. Don't commit it or `git add -f` it (MAINTAINER.md decides
   what ships). To share it, the user copies the folder.

## Hued vs monochrome in templates

`{{ hued <a> <b> }}` renders `a` when the theme has `hued = true`, else `b`; only the chosen
side is resolved. Use it wherever a stock upstream theme would put a colour — one hue per
btop box, green→yellow→red temperature gradients, lock `fail_color` red, `check_color`
green — with the grey the mono themes had before as `b`. Check with a render diff that the
mono themes did not move:

```bash
cd ~/.config/hypr-theme; for t in hyprmono hyprmono-light; do
  python3 render.py themes/$t templates /tmp/$t-after >/dev/null; done   # vs a copy made before
```
The shell reads `hued` and `colors.good/warning/critical` from `colors.json`
(`Theme.hued`, `Theme.c.*`). Hued today: battery (charging green, ≤30 % yellow, ≤15 % red),
SysMon > 85 % yellow, critical notification border red; the waybar fallback uses
`@state-good/-warning/-critical` from `palette.css`. When adding a widget with a state,
follow that pattern — `Theme.hued ? Theme.c.critical : Theme.c.accentDim`.

## Firefox

`templates/firefox-userChrome.css.tpl` (browser chrome), `firefox-userContent.css.tpl`
(about: pages, new tab, reader) and `firefox-user.js.tpl` (prefs). `apply_firefox` in
`hypr-theme` installs them into every profile from `profiles.ini` — Firefox 156+ keeps
profiles under `~/.config/mozilla/firefox`, older builds under `~/.mozilla/firefox`. Facts
that cost time once:
- Both user sheets are *user-origin*: every declaration needs `!important` or the page's
  own tokens win (the settings page kept its cyan accent until then).
- Firefox ≥ 130 chrome is built on design-system tokens (`--background-color-canvas`,
  `--toolbar-background-color`, `--color-accent-primary`, `--panel-*`, `--tab-*`,
  `--urlbar-*`); override those, not element selectors. Pull current names from the build:
  `unzip -o /usr/lib/firefox/omni.ja 'chrome/toolkit/skin/classic/global/design-system/*.css'`.
- New tab uses its own `--newtab-*` vars (in browser/omni.ja, builtin-addons/newtab).
- Nothing reloads live: `pkill -x firefox` and relaunch; screenshot with
  `grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')"`.
- A never-launched Firefox has no profile; `timeout 15 firefox --headless about:blank`
  creates one without a window.

## Change one app for every theme

Edit its template in `templates/`, `hypr-theme reload`, verify in dark and light.
If the app needs a file at a fixed path, add an `install_file` line in
`hypr-theme`'s `apply()` and, if it can be reloaded live, the reload there too
(see the kitty/btop/nvim lines). If it ships with the rice, add the app to README's live-vs-restart table.

## Make an app follow the theme (new template)

1. Find what the app reads (a config file, a theme dir, env vars, gsettings) and
   whether it reloads live (signal, IPC, file watch) — check its man page/source.
2. Write `templates/<file>.tpl` with the tags above; colour it the app's stock way and branch with `{{ hued … }}` so the mono themes stay grey.
3. Wire `apply()` in `theme/.local/bin/hypr-theme` (install + reload).
4. If it ships with the rice and the app is worth having on a fresh machine, add it to `PKGS_REPO` in install.sh.
5. Verify dark + light with screenshots (+ a README row if it ships).

## Font, text size, scale

These are the user's, not a theme's: `hypr-font set <family>` (families from
`hypr-font list`), `hypr-text-size <9-20>` and `hypr-scale <n>`. They write
`shell.json` (`font.family`, `font.size`) and render
`~/.config/hypr-theme/ui/{kitty.conf,alacritty.toml}` plus a fontconfig rule;
a theme must never set them. In QML, sizes go through `Theme.fs(px)` and the
family through `Theme.font`.

## Wallpapers

`hypr-wall set <path>` / `next` — the shell draws it (`Wallpaper` service, crossfade),
the lock screen blurs it, SDDM gets a copy via root-sync. Any theme's
`backgrounds/` are offered in the picker (`SUPER+SHIFT+W`), current theme first.

## Aether (the Omarchy theming app) as a palette source

`aether --generate <image> --no-apply --output <dir>` renders Aether's own templates
(colors.toml in Omarchy names, btop, neovim.lua for aether.nvim, vscode extension, chromium
"r,g,b", …) into `<dir>` without touching the system — the safe way to see its extraction or
its per-app mapping. **`--import-colors-toml` / `--import-base16` / `--apply-blueprint` apply
immediately** (they write `~/.config/aether/theme/`, a VS Code extension
`local.theme-aether-*` and `~/.config/zed/themes/aether.json`); do not use them to inspect.
The GUI's swatches can be read off a screenshot by sampling pixels (ffmpeg → rgb24 → python).
The rice mirrors Aether's app mappings as `templates/*-aether*.tpl` + `nvim_colorscheme =
"aether"` so a palette can be compared both ways on the same theme.
