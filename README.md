# hypr-dotfiles

My personal Hyprland rice — a dark, blurred, mostly-monochrome setup built around a **Lua-configured Hyprland**.

Everything here is what I actually run day to day. Grab whatever's useful.

![License: MIT](https://img.shields.io/badge/license-MIT-black)
![Hyprland 0.56.2](https://img.shields.io/badge/hyprland-0.56.2-black)
![Config: Lua](https://img.shields.io/badge/config-lua-black)

---

## Screenshots

**Desktop**

![Main Window](Screenshots/mainwindow.png)

**Terminal — fastfetch + btop**

![Fastfetch and Btop](Screenshots/withfastfetchandbtop.png)

**Lock screen (hyprlock)**

![Hyprlock](Screenshots/hyprlock_scshot.png)

**Rofi launcher**

![Rofi Launcher](Screenshots/rofi.png)

**Logout menu (wlogout)**

![Wlogout](Screenshots/wlogout.png)

**Notification centre (SwayNC)**

![SwayNC Notifications](Screenshots/swaync_notification.png)


**Zen Browser**

![Zen Browser](Screenshots/zen-browser.png)

---

## Hyprland configured in Lua

Most Hyprland rices ship a pile of `.conf` files in hyprlang. This one doesn't — the whole
compositor config is **Lua**, using Hyprland's `hl` API:

Entry point is [`hyprland.lua`](hyprland/.config/hypr/hyprland.lua), which requires six modules:

| Module | What's in it |
|---|---|
| [`env.lua`](hyprland/.config/hypr/modules/env.lua) | Wayland/toolkit env vars, HiDPI scaling, NVIDIA bits |
| [`autostart.lua`](hyprland/.config/hypr/modules/autostart.lua) | waybar, awww, hypridle, polkit agent, batsignal, cliphist |
| [`binds.lua`](hyprland/.config/hypr/modules/binds.lua) | every keybind |
| [`monitors.lua`](hyprland/.config/hypr/modules/monitors.lua) | display layout — **edit this first** |
| [`decorations.lua`](hyprland/.config/hypr/modules/decorations.lua) | gaps, blur, opacity, shadows, animation curves |
| [`windowrules.lua`](hyprland/.config/hypr/modules/windowrules.lua) | layer blur for rofi/swaync/wlogout, idle inhibit |

> **Heads up:** the Lua config format needs a reasonably recent Hyprland — one that ships
> `/usr/share/hypr/stubs`. This is built and tested against **0.56.2**.

---

## What's in the rice

| | Using | Package |
|---|---|---|
| Compositor | [Hyprland](https://hyprland.org/) | `hyprland` |
| Bar | [Waybar](https://github.com/Alexays/Waybar) | `waybar` |
| Launcher | [Rofi](https://github.com/davatorium/rofi) | `rofi` |
| Notifications | [SwayNC](https://github.com/ErikReider/SwayNotificationCenter) | `swaync` |
| Lock screen | [hyprlock](https://github.com/hyprwm/hyprlock) | `hyprlock` |
| Idle daemon | [hypridle](https://github.com/hyprwm/hypridle) | `hypridle` |
| Logout menu | [wlogout](https://github.com/ArtsyMacaw/wlogout) | `wlogout` |
| Wallpaper | [awww](https://codeberg.org/LGFae/awww) | `awww` |
| Terminal | [Kitty](https://sw.kovidgoyal.net/kitty/) (main), [Alacritty](https://alacritty.org/) (spare) | `kitty` `alacritty` |
| Shell | [Zsh](https://www.zsh.org/) + [Starship](https://starship.rs/) | `zsh` `starship` |
| Editor | [Neovim](https://neovim.io/) ([LazyVim](https://www.lazyvim.org/)) | `neovim` |
| Files | [Thunar](https://docs.xfce.org/xfce/thunar/start) | `thunar` |
| Browser | [Zen Browser](https://zen-browser.app/) | `zen-browser-bin` (AUR) |
| Clipboard | [cliphist](https://github.com/sentriz/cliphist), with ffmpeg for image thumbnails | `cliphist` `ffmpeg` |
| Screenshots | grim + slurp | `grim` `slurp` |
| App theming | GTK2/3/4 + Qt5/Qt6, all from the shared palette | `adw-gtk-theme` `qt5ct` `qt6ct` `adwaita-qt5` `adwaita-qt6` `papirus-icon-theme` `inter-font` |


---

## Fonts (read this one — it's the usual reason a rice looks broken)

Everything needs **JetBrainsMono Nerd Font**, and the *variant* matters:

```bash
sudo pacman -S ttf-jetbrains-mono-nerd
```

| Variant | Used by |
|---|---|
| `JetBrainsMono Nerd Font Propo` | Waybar, SwayNC, hyprlock |
| `JetBrainsMono NFP Light` | Rofi |
| `JetBrains Mono Nerd Font` | Kitty, Alacritty |

`Propo` is the proportional build — it gives glyphs room to breathe, which is what keeps the bar
from looking cramped. The base and `Mono` variants will *work* but the spacing goes off.

Verify it landed:

```bash
fc-list : family | grep -i "JetBrainsMono Nerd Font Propo"
```

**If that prints nothing, every icon in Waybar and SwayNC renders as an empty box** and the whole
thing looks broken on first launch. It's not — you're just missing the font.

---

## Install

### Quick way

```bash
git clone https://github.com/thomasmartinoa/hypr-dotfiles.git ~/hypr-dotfiles
cd ~/hypr-dotfiles
./install.sh
```

The script installs the packages, symlinks everything with stow, creates `~/Pictures/screenshot`
(the screenshot binds need it to exist), and warns you about the font and the monitor config.
It refuses to clobber existing real files — if it finds any it tells you which and stops.

```bash
./install.sh --dry-run     # show what would be linked, change nothing
./install.sh --stow-only   # skip package installation
./install.sh --migrate     # back up files that are blocking stow, then re-run
```

### "cannot stow ... over existing target hyprland.lua"

Expect this on a fresh machine, and it isn't a bug. You log into Hyprland before running the
installer; Hyprland finds no config and **writes its own default `~/.config/hypr/hyprland.lua`**.
That real file then blocks the symlink. The session banner gives it away:

```
Warning: You're using an autogenerated config! (config file: /home/you/.config/hypr/hyprland.lua)
```

The installer recognises this case and says so. To clear it:

```bash
./install.sh --migrate     # moves it to ~/.config/hypr-dotfiles-backup-<timestamp>/
./install.sh               # re-run
```

`--migrate` only touches a known list (Hyprland's generated config, and GTK/KDE files written by
nwg-look). Anything outside that list it leaves alone and names explicitly, so you decide. It also
skips symlinks this repo already owns, which makes it safe to re-run.

### Manual way

Packages, if you'd rather do it yourself:

```bash
# compositor + desktop
sudo pacman -S hyprland hyprlock hypridle waybar rofi swaync awww \
               xdg-desktop-portal-hyprland polkit-gnome qt5ct qt6ct power-profiles-daemon

# terminal + shell
sudo pacman -S kitty alacritty zsh starship

# cli tools
sudo pacman -S neovim fastfetch btop eza

# utilities
sudo pacman -S grim slurp wl-clipboard cliphist ffmpeg playerctl brightnessctl \
               batsignal jq thunar pavucontrol networkmanager nm-connection-editor

# fonts (see the section above) + icons + GTK theme + stow
sudo pacman -S ttf-jetbrains-mono-nerd inter-font papirus-icon-theme adw-gtk-theme stow
```

`wlogout`, `adwaita-qt5` and `adwaita-qt6` aren't in the Arch repos — get them from the AUR
(`paru -S wlogout adwaita-qt5 adwaita-qt6`). On CachyOS all three are in the `[cachyos]` repo, so
plain `pacman -S` works there. Without `adwaita-qt6`, Qt apps fall back to Fusion and ignore the
colour scheme.

Then symlink with stow:

```bash
git clone https://github.com/thomasmartinoa/hypr-dotfiles.git ~/hypr-dotfiles
cd ~/hypr-dotfiles

# everything
stow alacritty gtk hyprland kde kittyterminal nvim qt rofi starship swaync theme \
     waybar wlogout zsh

# or just what you want
stow hyprland waybar
```

The repo can live anywhere — nothing hardcodes its path. Wallpapers ship inside the `hyprland`
package, so stow puts them at `~/.config/hypr/wallpapers/` wherever you cloned to.

---

## Layout

Each top-level folder is a GNU Stow package that mirrors your home directory:

```
alacritty/       →  ~/.config/alacritty/
gtk/             →  ~/.gtkrc-2.0, ~/.config/gtk-3.0/, ~/.config/gtk-4.0/
hyprland/        →  ~/.config/hypr/          (lua config, hyprlock, hypridle, wallpapers, scripts)
kde/             →  ~/.config/kdeglobals, ~/.local/share/color-schemes/
kittyterminal/   →  ~/.config/kitty/
nvim/            →  ~/.config/nvim/          (LazyVim)
qt/              →  ~/.config/qt5ct/colors/, ~/.config/qt6ct/colors/  (schemes only)
rofi/            →  ~/.config/rofi/
starship/        →  ~/.config/starship.toml
swaync/          →  ~/.config/swaync/
theme/           →  ~/.config/hypr-theme/    (the shared palette — one source of truth)
waybar/          →  ~/.config/waybar/
wlogout/         →  ~/.config/wlogout/
zsh/             →  ~/.zshrc

Screenshots/     →  images for this README (not a stow package)
templates/       →  files rendered by install.sh (not a stow package)
install.sh       →  installer
```

---

## Application theming (GTK & Qt)

Most rices theme the desktop shell and leave ordinary applications looking like stock GNOME. This
repo carries the app theming too, driven from the same palette as the bar.

| Toolkit | Gets | From |
|---|---|---|
| GTK4 / libadwaita | Full recolour | [`gtk-4.0/gtk.css`](gtk/.config/gtk-4.0/gtk.css) — imports the palette, maps it onto libadwaita's named colours |
| GTK3 | Full recolour + `adw-gtk3-dark` | [`gtk-3.0/gtk.css`](gtk/.config/gtk-3.0/gtk.css) — imports the palette, both classic and libadwaita names |
| GTK2 | Full recolour | [`.gtkrc-2.0`](gtk/.gtkrc-2.0) — explicit `style` block; GTK2 has no CSS so the values are transcribed |
| Qt6 | Full palette, 22 roles | [`qt6ct/colors/hypr-mono.conf`](qt/.config/qt6ct/colors/hypr-mono.conf) |
| Qt5 | Full palette, 21 roles | [`qt5ct/colors/hypr-mono.conf`](qt/.config/qt5ct/colors/hypr-mono.conf) |
| KDE / KF6 | Full palette | [`HyprMono.colors`](kde/.local/share/color-schemes/HyprMono.colors) + [`kdeglobals`](kde/.config/kdeglobals) |

Shared across all five: **Inter** for UI text, **Papirus-Dark** for icons, `prefer-dark`.

The two Qt files differ by exactly one value — Qt5 has no `Accent` role, which arrived in Qt 6.6.

GTK2 is worth a note: no GTK2 theme is installed on a modern Arch system (`adw-gtk3-dark` ships
`gtk-3.0` and `gtk-4.0` directories only), so a `gtk-theme-name` line there is a dead reference and
GTK2 apps fall back to the built-in Raleigh theme. The explicit `style` block recolours GTK2 with no
theme package at all.

### One env var covers both Qt versions

`QT_QPA_PLATFORMTHEME` takes a single value, which looks like it should force a choice between Qt5
and Qt6. It doesn't: **both plugins register both keys.** Reading the Qt plugin metadata directly:

```console
$ objcopy -O binary --only-section=.qtmetadata \
      /usr/lib/qt/plugins/platformthemes/libqt5ct.so /dev/stdout | strings
Qt5CTPlatformThemePlugin
Keys
qt5ct  qt6ct
```

`libqt6ct.so` declares the same pair. Qt matches `QT_QPA_PLATFORMTHEME` against a plugin's declared
keys, so `qt6ct` resolves to `libqt5ct.so` under Qt5 and `libqt6ct.so` under Qt6. One value, both
toolkits themed — no per-app launcher overrides needed.

### Two honest limitations

- **GTK3 recolouring is partial.** `adw-gtk3` honours the common named colours, but an app shipping
  its own hardcoded stylesheet wins over these overrides. GTK4/libadwaita is where it works fully.
- **Nothing is live.** GTK and Qt apps read their theme at startup. A palette change needs those apps
  restarted — unlike Waybar and SwayNC, which `SUPER` + `R` restarts for you.

### Qt4 and older

Not covered, because they don't exist on a current Arch system. Qt4 reached end of life in 2015 and
was dropped from the repos; Qt3 died in 2007; Qt1 and Qt2 are 1990s software. None of them is
installable from any configured repo, and nothing here links against them.

If you ever install Qt4 from the AUR, its theming is unrelated to everything above — no qt4ct, no
platform theme plugin. It reads `~/.config/Trolltech.conf`, written by `qtconfig-qt4`. Shipping a
config for a toolkit with zero installed users would just be dead weight in the repo.

Kvantum is not used here. If you have it installed it's inert, because qt6ct's `style` is
`Adwaita-Dark`. Switch `style=kvantum` in `qt6ct.conf` if you'd rather drive Qt through Kvantum — but
then the palette above stops applying and Kvantum's own theme takes over.

### Why qt6ct.conf is a template, not a stow package

qt6ct resolves `color_scheme_path` with `QFile`, which doesn't expand `~` and resolves relative paths
against the working directory — so the value has to be absolute. Rather than hardcode `/home/martin`,
`install.sh` renders [`templates/qt6ct.conf.in`](templates/qt6ct.conf.in) with your real `$HOME`.

It also keeps `~/.config/qt6ct/qt6ct.conf` a real file rather than a symlink into the repo, which
matters because qt6ct's GUI rewrites that file whenever you change a setting — including window
geometry you don't want in version control.

### Migrating an existing setup

If you've configured GTK by hand or with nwg-look, those files sit exactly where stow needs to put
symlinks. `install.sh` detects this and stops rather than overwriting. One command clears them:

```bash
./install.sh --migrate     # moves them to ~/.config/hypr-dotfiles-backup-<timestamp>/
```

**Watch for the GTK4 symlink trap in particular.** The common advice for theming GTK4 is to symlink
a theme's `gtk.css` into `~/.config/gtk-4.0/`. Done partially, it silently disables the theme
entirely:

```console
$ ls -l ~/.config/gtk-4.0/
gtk.css -> /usr/share/themes/adw-gtk3-dark/gtk-4.0/gtk.css     # only this was linked
$ cat ~/.config/gtk-4.0/gtk.css
@import url('libadwaita.css');                                  # ...but this is relative
```

GTK resolves that `@import` against `~/.config/gtk-4.0/` — the *logical* path — not against the
theme directory the symlink points into. `libadwaita.css` was never linked alongside it, so the
import fails and every GTK4 app falls back to unstyled:

```
Gtk-WARNING: Theme parser error: gtk.css:1:1-31: Failed to import:
  Error opening file /home/you/.config/gtk-4.0/libadwaita.css: No such file or directory
```

If you see that warning, this is why. `--migrate` clears those symlinks, and the `gtk` package
replaces them with a `gtk.css` that imports the shared palette by a path that actually resolves.

Note that nwg-look **writes** these files, so running it later will overwrite the stowed symlinks.
Pick one or the other; this repo assumes you've stopped using nwg-look.

---

## Apps that ignore the system theme

Setting GTK and Qt correctly still leaves a whole class of applications untouched, because they
don't ask the toolkit what colour anything should be. Knowing which is which saves a lot of time
wondering why a config "didn't work".

### These follow the toolkit config

Everything in the table above: GTK2/3/4 apps (thunar, pavucontrol, nm-connection-editor, gimp),
Qt5/Qt6 apps (qbittorrent, cmake-gui, qt5ct/qt6ct), and KDE apps (kdenlive) once `kdeglobals` is in
place.

### These have their own theme engine

| App | Engine | Lever |
|---|---|---|
| VS Code | Electron, own themes | `workbench.colorCustomizations` in `~/.config/Code/User/settings.json` |
| Zen Browser | Firefox chrome | `userChrome.css` in the profile + `toolkit.legacyUserProfileCustomizations.stylesheets=true` |
| Telegram | own palette format | a `.tdesktop-palette` file, imported via Settings → Chat Settings → Theme |
| OBS Studio | own Qt stylesheets (`.obt`) | set the theme to **System**, which is the one `.obt` that defers to the Qt palette |
| LocalSend | Flutter / Material | reads the portal's accent colour — see the caveat below |
| Heroic, WhatsApp, Unity Hub | Electron | no system hook; each has its own settings |

**The Flutter caveat.** LocalSend logs `dynamic_color: Accent color detected` on startup, which
suggests it's reading the desktop's accent. It reads `org.freedesktop.appearance accent-color` from
the XDG portal — and on this setup that key **isn't published**:

```console
$ busctl --user call org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop \
      org.freedesktop.portal.Settings Read ss "org.freedesktop.appearance" "accent-color"
Call failed: Requested setting not found

$ ... Read ss "org.freedesktop.appearance" "color-scheme"
v v u 1                      # 1 = prefer-dark, this one does work
```

So dark mode reaches Flutter apps but accent colour does not, because `xdg-desktop-portal-gtk`
doesn't implement that key. There is no user-level fix short of a portal backend that publishes it.

### grub-customizer is a special case — and it isn't a toolkit problem

It's a GTK3 app, so it *should* follow the GTK config. It doesn't, because it re-execs itself
through **pkexec** and draws its GUI as root:

```console
$ grep exec.path /usr/share/polkit-1/actions/net.launchpad.*grub-customizer.policy
<annotate key="org.freedesktop.policykit.exec.path">/usr/bin/grub-customizer</annotate>
```

pkexec sanitises the environment, so `GTK_THEME` and `XDG_CONFIG_HOME` don't survive, and root reads
`/root/.config`, which has no theme. Hence the stock light window. `install.sh` copies the GTK config
into `/root` to fix it — the same applies to any other pkexec GUI you run.

---

## Keybinds

`SUPER` is the mod key. All of these live in
[`modules/binds.lua`](hyprland/.config/hypr/modules/binds.lua).

### Launching

| Keys | Action |
|---|---|
| `SUPER` + `Return` | Terminal (kitty) |
| `SUPER` + `D` | App launcher (rofi) |
| `SUPER` + `E` | File manager (thunar) |
| `SUPER` + `B` | Browser (zen-browser) |
| `SUPER` + `V` | Clipboard history — see [Clipboard menu](#clipboard-menu) |
| `SUPER` + `L` | Lock screen (hyprlock) |
| `SUPER` + `M` | Logout menu (wlogout) |
| `SUPER` + `R` | Restart waybar + swaync |

### Clipboard menu

`SUPER` + `V` opens [`scripts/clipboard.sh`](rofi/.config/rofi/scripts/clipboard.sh) — a rofi menu
over cliphist that renders copied images as real thumbnails rather than `binary data` blobs.

| Keys | Action |
|---|---|
| `Enter` | Copy the entry and close |
| `Delete` | Delete that entry from history — the menu stays open on the same row |
| `Ctrl` + `D` | Forward-delete in the search box (rofi's default is `Delete`, which is reassigned above) |
| `Esc` | Close |
| `SUPER` + `V` | Pressing it again closes the menu |

Thumbnails need **ffmpeg**. Without it the menu still opens and still works — it just silently shows
no thumbnails, because the script sends ffmpeg's stderr to `/dev/null`. If your clipboard menu looks
plainer than the screenshots, that's why.

Thumbnails are cached in `~/.cache/cliphist-thumbs`, pruned after 14 days. The menu lists the 60
most recent entries.

### Windows

| Keys | Action |
|---|---|
| `SUPER` + `Q` | Close window |
| `SUPER` + `T` | Toggle floating |
| `SUPER` + `F` | Fullscreen |
| `SUPER` + `SHIFT` + `F` | Maximize |
| `SUPER` + `P` | Pseudo-tile |
| `SUPER` + `J` | Toggle split direction |
| `SUPER` + `←↑↓→` | Move focus |
| `SUPER` + drag `LMB` | Move window |
| `SUPER` + drag `RMB` | Resize window |

### Workspaces

| Keys | Action |
|---|---|
| `SUPER` + `1`–`0` | Switch to workspace 1–10 |
| `SUPER` + `SHIFT` + `1`–`0` | Move window to workspace 1–10 |
| `SUPER` + scroll | Cycle workspaces |
| `SUPER` + `S` | Toggle scratchpad (special workspace `magic`) |
| `SUPER` + `SHIFT` + `S` | Move window to scratchpad |
| 3-finger horizontal swipe | Switch workspace |

### Screenshots

Saved to `~/Pictures/screenshot/` **and** copied to the clipboard.

| Keys | Action |
|---|---|
| `SUPER` + `Print` | Whole screen |
| `SUPER` + `X` | Select a region |
| `SUPER` + `SHIFT` + `Print` | Active window |
| `SUPER` + `SHIFT` + `X` | Region → clipboard only, no file |

### Media & hardware keys

Volume, mic mute, brightness and playback all work while locked. Playback keys need `playerctl`;
brightness targets `intel_backlight`

---

## Customising

### Wallpaper

Wallpapers live in [`hyprland/.config/hypr/wallpapers/`](hyprland/.config/hypr/wallpapers/) and get
symlinked to `~/.config/hypr/wallpapers/`. The one set at login is in
[`modules/autostart.lua`](hyprland/.config/hypr/modules/autostart.lua):

```lua
hl.exec_cmd("awww-daemon & awww img ~/.config/hypr/wallpapers/montain_main.png")
```

Drop your own image in that folder and point the line at it. To change it live:

```bash
awww img /path/to/wallpaper.png --transition-type grow
```

The lock screen background is separate — it's `~/.config/hypr/hyprlock.png`, set in `hyprlock.conf`.

Neither bundled image is mine — see [Wallpapers](#wallpapers) under Credits before you reuse them.

### Blur, opacity and gaps

All in [`modules/decorations.lua`](hyprland/.config/hypr/modules/decorations.lua):

```lua
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 7,
        border_size = 1,
        layout = "dwindle",
    },

    decoration = {
        rounding         = 4,
        active_opacity   = 0.9,     -- focused window
        inactive_opacity = 0.7,     -- everything else

        blur = {
            enabled  = true,
            size     = 8,
            passes   = 3,           -- more passes = heavier blur, more GPU
            vibrancy = 0.1696,
        },
    },
})
```

If the blur costs you frames, drop `passes` to `2` before touching anything else.

Animation curves are in the same file — five named beziers driving fifteen animation leaves. The
window motion is `easeOutQuint` with `popin 87%`; there's a commented-out spring config at the
bottom if you prefer the newer upstream feel.

### Colours

**One palette file drives every GTK surface.** The monochrome ramp is defined once in
[`theme/.config/hypr-theme/palette.css`](theme/.config/hypr-theme/palette.css) and imported by
Waybar, SwayNC, GTK3 and GTK4:

```css
@import '../hypr-theme/palette.css';
```

That path is relative to `~/.config/`, so it resolves across stow packages — each package is its own
symlink, and GTK follows the logical path rather than the physical one in the repo.

Change a grey there and it changes in the bar, the notification centre, and every GTK app at once.

Two files cannot import it, so they mirror it by hand:

| File | Why it's separate |
|---|---|
| [`palette.rasi`](theme/.config/hypr-theme/palette.rasi) | rofi has its own syntax and its surfaces are translucent, so several values carry an alpha channel |
| [`hypr-mono.conf`](qt/.config/qt6ct/colors/hypr-mono.conf) | Qt colour schemes are 22 positional `#AARRGGBB` values in `Qt::ColorRole` order — no imports, no names |

Both name the palette colour they correspond to in a comment. Kitty's terminal palette is inline at
the bottom of `kitty.conf` and is deliberately independent — it sets the 16 ANSI colours, not UI
chrome.

---

## Gotchas

These are hardcoded to *my* laptop. Check them before you file a bug:

- **Monitor.** [`modules/monitors.lua`](hyprland/.config/hypr/modules/monitors.lua) assumes a single
  `eDP-1` at `2560x1440@165Hz`, scale `1.6`. Almost certainly wrong for you — run `hyprctl monitors`
  and fix it. The `1.6` scale is also mirrored in `env.lua` as `QT_SCALE_FACTOR` and
  `JDK_JAVA_OPTIONS`; change all three together.
- **NVIDIA.** [`env.lua`](hyprland/.config/hypr/modules/env.lua) sets `GBM_BACKEND=nvidia-drm` and
  `LIBVA_DRIVER_NAME=nvidia`. Comment those out on AMD or Intel-only machines. PRIME offload and
  `WLR_NO_HARDWARE_CURSORS` are in there too, commented, if you need them.
- **Backlight device.** Brightness binds and the SwayNC backlight widget both target
  `intel_backlight`. Check `ls /sys/class/backlight/` and substitute yours.
- **Keyboard backlight.** [`hypridle.conf`](hyprland/.config/hypr/hypridle.conf) dims
  `rgb:kbd_backlight` after 4 minutes. Comment that listener out if you don't have one.
- **Screenshot directory.** The binds pipe through `tee`, which won't create the folder. If you
  skipped `install.sh`, run `mkdir -p ~/Pictures/screenshot` yourself.

---

## Credits

- [Hyprland](https://hyprland.org/) and the whole hypr* ecosystem
- [awww](https://codeberg.org/LGFae/awww) by LGFae
- [LazyVim](https://www.lazyvim.org/) for the Neovim base

### Wallpapers

The two images in [`hyprland/.config/hypr/wallpapers/`](hyprland/.config/hypr/wallpapers/) are not
mine. They're bundled so the rice looks right on first launch, and they are **not covered by this
repo's MIT licence**.

| File | Source |
|---|---|
| `montain_main.png` | Mount Ararat over Yerevan (B&W). Photographer unknown — earliest traceable source: [wallpaperswide.com](https://wallpaperswide.com/) |
| `creationofadam.png` | *The Creation of Adam*, Michelangelo, Sistine Chapel ceiling (c. 1512). The painting itself is public domain; the provenance of this particular photograph and edit is unknown. |

I couldn't verify an author for either, so I haven't invented one. If you hold rights to either
image and want it credited differently or pulled from the repo, open an issue and I'll sort it.
Swapping in your own wallpaper is one line — see [Wallpaper](#wallpaper) under Customising.

## License

The configuration in this repo is [MIT](LICENSE) — do what you like with it. If a piece of this
ends up in your own rice, I'd love to see it, but you're under no obligation.

The bundled wallpapers are **not** mine to license and are excluded from the above; see
[Wallpapers](#wallpapers).
