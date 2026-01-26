# My Hyprland Dotfiles

Hey! These are my personal dotfiles for my Hyprland setup. I've been tweaking this rice for a while now and finally decided to share it. It's nothing too crazy - just a clean, minimal setup that works well for me.

Feel free to grab whatever you find useful!

---

## Screenshots

Here's what it looks like:

**The main desktop**

![Main Window](Screenshots/mainwindow.png)

**Terminal with fastfetch and btop running**

![Fastfetch and Btop](Screenshots/withfastfetchandbtop.png)

**Rofi launcher**

![Rofi Launcher](Screenshots/rofi.png)

**Notifications (SwayNC)**

![SwayNC Notifications](Screenshots/swaync_notification.png)

**Zen Browser in action**

![Zen Browser](Screenshots/zen-browser.png)

---

## What I'm using

- **Window Manager:** [Hyprland](https://hyprland.org/) - honestly the best wayland compositor out there
- **Bar:** [Waybar](https://github.com/Alexays/Waybar) - simple and customizable
- **Launcher:** [Rofi](https://github.com/davatorium/rofi) - fast app launcher
- **Notifications:** [SwayNC](https://github.com/ErikReider/SwayNotificationCenter) - nice notification center
- **Wallpaper:** [Hyprpaper](https://github.com/hyprwm/hyprpaper) + [SWWW](https://github.com/LGFae/swww) for smooth transitions
- **Lock Screen:** [Swaylock](https://github.com/swaywm/swaylock)
- **Terminal:** [Kitty](https://sw.kovidgoyal.net/kitty/) (main) and [Alacritty](https://alacritty.org/) (backup)
- **Shell:** [Zsh](https://www.zsh.org/) with [Starship](https://starship.rs/) prompt
- **Editor:** [Neovim](https://neovim.io/)

---

## Some things I like about this setup

- Blur on windows looks really nice with the right opacity settings
- Animations are smooth - I spent way too much time tweaking the bezier curves
- Dwindle tiling layout just works for how I use my desktop
- SwayNC gives me a proper notification center instead of notifications just disappearing
- Starship prompt is fast and shows me git info without being too cluttered
- SWWW lets me change wallpapers with cool transition effects

---

## How it's organized

The repo is set up for GNU Stow so each folder is its own "package":

```
alacritty/       - alacritty terminal config
hyprland/        - the main hyprland config (split into modules)
kittyterminal/   - kitty terminal config  
nvim/            - neovim setup
rofi/            - launcher themes
starship/        - shell prompt config
swaylock/        - lock screen
swaync/          - notification center
wallpaper/       - my wallpapers
waybar/          - status bar config and styles
zsh/             - zsh config
```

The hyprland config is modular - main stuff is in `hyprland/.config/hypr/` and I split things like keybinds, decorations, autostart etc into separate files under `modules/`.

---

## Installation

### You'll need these packages

```bash
# the essentials
hyprland waybar rofi-wayland swaync swaylock hyprpaper hypridle swww

# terminal stuff
kitty alacritty zsh starship

# other stuff I use
polkit-gnome networkmanager pavucontrol neovim fastfetch btop eza
```

### Using Stow (the easy way)

I use GNU Stow to manage everything. If you don't have it, just `sudo pacman -S stow` (or whatever your package manager is).

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# symlink everything at once
stow alacritty hyprland kittyterminal nvim rofi starship swaylock swaync waybar zsh

# or just what you need
stow hyprland waybar
```

### Manual way

If you don't want to use stow, just copy the configs:

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles

cp -r ~/dotfiles/hyprland/.config/hypr ~/.config/
cp -r ~/dotfiles/waybar/.config/waybar ~/.config/
# ... you get the idea

cp ~/dotfiles/zsh/.zshrc ~/
```

---

## Keybindings

All my keybinds are in `hyprland/.config/hypr/modules/binds.conf` - check that file out if you want to see what's what.

---

## Tweaking stuff

**Wallpaper**

You can either edit `~/.config/hypr/hyprpaper.conf` or just use swww directly:

```bash
swww img /path/to/your/wallpaper.png --transition-type grow
```

**Blur and transparency**

These are in `hyprland/.config/hypr/modules/decorations.conf`. The main things you'd want to change:

```ini
decoration {
    active_opacity = 0.9      # focused window opacity
    inactive_opacity = 0.7    # unfocused windows
    
    blur {
        enabled = true
        size = 6
        passes = 4            # more passes = more blur but heavier on gpu
    }
}
```

---

That's pretty much it. If something doesn't work or you have questions, feel free to open an issue.
