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
├── colors.toml     name, mode (dark|light), bar (pill|minimal), [colors] [terminal] [git] [apps]
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
   - `[git]` keeps real hues. `[apps]` names the GTK/Qt/icon/cursor themes and `nvim_colorscheme`.
   - `bar = "pill"|"minimal"` is the skin the theme prefers.
3. Wallpaper: put one or more images in `backgrounds/` named `1-<slug>.png`, `2-…`.
   Match the mood (dark theme → dark image, light → bright). Prefer ≥ 2560 px wide,
   non-busy, so lock/login text stays readable over the blur. If downloading, use a
   source that allows reuse (Unsplash / Pexels / Wikimedia) and note the URL in a
   `backgrounds/SOURCES` file.
4. `hypr-theme set <id>` — it appears in the carousel (`SUPER+CTRL+SHIFT+SPACE`) automatically.
5. **Verify in every surface** (verify.md): bar (both skins: `qs ipc call bar toggle`),
   launcher `SUPER+D`, clipboard, notification (`qs ipc call notifications test`),
   panels (audio/network/power/agents), picker, power menu, lock screen (careful —
   see SKILL rule 5; the SDDM Main.qml uses the same geometry, so a screenshot of
   the lock screen stands in), kitty + fastfetch, btop, nvim, Thunar (GTK3, restart it),
   a Qt app (qt6ct-aware, restart it), VS Code. Fix any unreadable text by adjusting
   the ramp, not one app.
6. Commit `themes/<id>/` (+ README if you add anything user-facing).

## Change one app for every theme

Edit its template in `templates/`, `hypr-theme reload`, verify in dark and light.
If the app needs a file at a fixed path, add an `install_file` line in
`hypr-theme`'s `apply()` and, if it can be reloaded live, the reload there too
(see the kitty/btop/nvim lines). Add the app to README's live-vs-restart table.

## Make an app follow the theme (new template)

1. Find what the app reads (a config file, a theme dir, env vars, gsettings) and
   whether it reloads live (signal, IPC, file watch) — check its man page/source.
2. Write `templates/<file>.tpl` with the tags above; keep it monochrome.
3. Wire `apply()` in `theme/.local/bin/hypr-theme` (install + reload).
4. If the app is worth having on a fresh machine, add it to `PKGS_REPO` in install.sh.
5. Verify dark + light with screenshots; add a README row.

## Wallpapers

`hypr-wall set <path>` / `next` — the shell draws it (`Wallpaper` service, crossfade),
the lock screen blurs it, SDDM gets a copy via root-sync. Any theme's
`backgrounds/` are offered in the picker (`SUPER+SHIFT+W`), current theme first.
