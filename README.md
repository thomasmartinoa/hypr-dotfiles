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

## What's in it

| | Using | Package |
|---|---|---|
| Compositor | [Hyprland](https://hyprland.org/) | `hyprland` |
| Bar | [Waybar](https://github.com/Alexays/Waybar) | `waybar` |
| Launcher | [Rofi](https://github.com/davatorium/rofi) | `rofi` |
| Notifications | [SwayNC](https://github.com/ErikReider/SwayNotificationCenter) | `swaync` |
| Lock / idle | [hyprlock](https://github.com/hyprwm/hyprlock) + [hypridle](https://github.com/hyprwm/hypridle) | `hyprlock` `hypridle` |
| Logout menu | [wlogout](https://github.com/ArtsyMacaw/wlogout) | `wlogout` |
| Wallpaper | [awww](https://codeberg.org/LGFae/awww) | `awww` |
| Terminal | [Kitty](https://sw.kovidgoyal.net/kitty/), [Alacritty](https://alacritty.org/) | `kitty` `alacritty` |
| Shell | [Zsh](https://www.zsh.org/) + [Starship](https://starship.rs/) | `zsh` `starship` |
| Editor | [Neovim](https://neovim.io/) ([LazyVim](https://www.lazyvim.org/)) | `neovim` |
| Files | [Thunar](https://docs.xfce.org/xfce/thunar/start) | `thunar` |
| Browser | [Zen Browser](https://zen-browser.app/) | `zen-browser-bin` |
| Clipboard | [cliphist](https://github.com/sentriz/cliphist) with image thumbnails | `cliphist` `ffmpeg` |
| Screenshots | grim + slurp | `grim` `slurp` |
| App theming | GTK2/3/4 + Qt5/6 from one palette | `qt5ct` `qt6ct` `papirus-icon-theme` `inter-font` |

---

## Fonts

```bash
sudo pacman -S ttf-jetbrains-mono-nerd inter-font
```

The **Propo** variant matters — it's what Waybar, SwayNC and hyprlock use. Check it landed:

```bash
fc-list : family | grep -i "JetBrainsMono Nerd Font Propo"
```

**If that prints nothing, every icon renders as an empty box.** That's the usual reason a fresh
install looks broken.

---

## Install

```bash
git clone https://github.com/thomasmartinoa/hypr-dotfiles.git ~/hypr-dotfiles
cd ~/hypr-dotfiles
./install.sh
```

That installs the packages and symlinks everything with GNU Stow. It won't overwrite anything
without asking first.

| Flag | Does |
|---|---|
| `--dry-run` | Show what would happen, change nothing |
| `--stow-only` | Skip package installation |
| `--migrate` | Back up blocking files without asking |
| `--no-migrate` | Never move anything; stop instead |
| `--skip-root` | Don't copy the GTK config into `/root` |

**On a fresh machine** you'll have logged into Hyprland once before installing, so Hyprland will
have written its own `~/.config/hypr/hyprland.lua`. That blocks the symlink. The installer spots
it, explains it, and offers to move it to a timestamped backup — just answer `Y`.

The repo can live anywhere; nothing hardcodes its path.

---

## Layout

Each top-level folder is a Stow package mirroring your home directory:

```
alacritty/   →  ~/.config/alacritty/
gtk/         →  ~/.gtkrc-2.0, ~/.config/gtk-3.0/, ~/.config/gtk-4.0/
hyprland/    →  ~/.config/hypr/     (lua config, hyprlock, hypridle, wallpapers)
kde/         →  ~/.config/kdeglobals, ~/.local/share/color-schemes/
kittyterminal/ → ~/.config/kitty/
nvim/        →  ~/.config/nvim/     (LazyVim)
qt/          →  ~/.config/qt5ct/colors/, ~/.config/qt6ct/colors/
rofi/        →  ~/.config/rofi/
starship/    →  ~/.config/starship.toml
swaync/      →  ~/.config/swaync/
theme/       →  ~/.config/hypr-theme/   (the shared palette)
waybar/      →  ~/.config/waybar/
wlogout/     →  ~/.config/wlogout/
zsh/         →  ~/.zshrc
```

The Hyprland config is split into modules under
[`hypr/modules/`](hyprland/.config/hypr/modules/) — `binds`, `monitors`, `decorations`, `env`,
`autostart`, `windowrules`.

---

## Keybinds

`SUPER` is the mod key. All of them live in
[`modules/binds.lua`](hyprland/.config/hypr/modules/binds.lua).

| Keys | Action |
|---|---|
| `SUPER` + `Return` / `E` / `B` | Terminal · file manager · browser |
| `SUPER` + `D` / `V` | App launcher · clipboard history |
| `SUPER` + `L` / `M` | Lock screen · logout menu |
| `SUPER` + `R` | Restart waybar + swaync |
| `SUPER` + `Q` / `T` / `F` | Close · float · fullscreen |
| `SUPER` + `SHIFT` + `F` / `P` / `J` | Maximize · pseudo-tile · toggle split |
| `SUPER` + `←↑↓→` | Move focus |
| `SUPER` + drag `LMB` / `RMB` | Move · resize window |
| `SUPER` + `1`–`0` | Switch workspace (add `SHIFT` to move the window there) |
| `SUPER` + scroll · 3-finger swipe | Cycle workspaces |
| `SUPER` + `S` / `SHIFT` + `S` | Toggle scratchpad · move window to it |
| `SUPER` + `Print` / `X` | Screenshot: whole screen · region |
| `SUPER` + `SHIFT` + `Print` / `X` | Active window · region to clipboard only |

Screenshots are saved to `~/Pictures/screenshot/` and copied to the clipboard. Volume, brightness
and media keys work while locked.

In the clipboard menu (`SUPER` + `V`): `Enter` copies, `Delete` removes an entry, `Ctrl`+`D`
forward-deletes in the search box.

---

## Customising

**Wallpaper** — drop an image in
[`hypr/wallpapers/`](hyprland/.config/hypr/wallpapers/) and point the `awww img` line in
[`autostart.lua`](hyprland/.config/hypr/modules/autostart.lua) at it. Live change:
`awww img /path/to/image.png --transition-type grow`. The lock screen background is separate —
`~/.config/hypr/hyprlock.png`.

**Blur, gaps, opacity, animations** — all in
[`decorations.lua`](hyprland/.config/hypr/modules/decorations.lua). If blur costs you frames, drop
`blur.passes` to `2` first.

**Colours** — one palette drives everything. Edit
[`palette.css`](theme/.config/hypr-theme/palette.css) and it changes Waybar, SwayNC and every
GTK app at once. Two files can't import it and mirror it by hand:
[`palette.rasi`](theme/.config/hypr-theme/palette.rasi) for rofi and
[`hypr-mono.conf`](qt/.config/qt6ct/colors/hypr-mono.conf) for Qt. Kitty's ANSI colours are inline
in `kitty.conf`.

Apps with their own theme engines — VS Code, Zen, Telegram, OBS, LocalSend, Electron apps — won't
follow any of this. They each need their own config.

---

## Gotchas

Hardcoded to *my* laptop — check these first:

- **Monitor.** [`monitors.lua`](hyprland/.config/hypr/modules/monitors.lua) assumes one `eDP-1` at
  `2560x1440@165Hz`, scale `1.6`. Run `hyprctl monitors` and fix it. The scale is mirrored in
  [`env.lua`](hyprland/.config/hypr/modules/env.lua) — change both.
- **NVIDIA.** `env.lua` sets NVIDIA env vars. Comment them out on AMD/Intel.
- **Backlight.** Brightness binds target `intel_backlight`. Check `ls /sys/class/backlight/`.
- **Keyboard backlight.** [`hypridle.conf`](hyprland/.config/hypr/hypridle.conf) dims it after
  4 minutes — comment that listener out if you don't have one.

---

## Credits

[Hyprland](https://hyprland.org/) and the hypr\* ecosystem · [awww](https://codeberg.org/LGFae/awww)
by LGFae · [LazyVim](https://www.lazyvim.org/).

**Wallpapers aren't mine and aren't covered by the licence.** `montain_main.png` is Mount Ararat
over Yerevan (B&W), photographer unknown, earliest traceable source
[wallpaperswide.com](https://wallpaperswide.com/). `creationofadam.png` is Michelangelo's Sistine
Chapel painting — public domain, but this particular photograph's provenance is unknown. If you
hold rights to either, open an issue.

## License

Config is [MIT](LICENSE). Bundled wallpapers are excluded — see above.
