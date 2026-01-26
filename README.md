<h1 align="center">
  <img src="https://raw.githubusercontent.com/hyprwm/Hyprland/main/assets/header.svg" width="600"/>
</h1>

<h1 align="center">🌿 Martin's Hyprland Dotfiles</h1>

<p align="center">
  <b>A minimal, aesthetic, and functional Hyprland rice</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/WM-Hyprland-blue?style=for-the-badge&logo=linux&logoColor=white" alt="Hyprland"/>
  <img src="https://img.shields.io/badge/Shell-Zsh-green?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Zsh"/>
  <img src="https://img.shields.io/badge/Terminal-Kitty-orange?style=for-the-badge&logo=alacritty&logoColor=white" alt="Kitty"/>
  <img src="https://img.shields.io/badge/Editor-Neovim-brightgreen?style=for-the-badge&logo=neovim&logoColor=white" alt="Neovim"/>
</p>

---

## ✨ Screenshots

<details open>
<summary><b>🖥️ Desktop Overview</b></summary>
<br>

![Main Window](Screenshots/mainwindow.png)

</details>

<details open>
<summary><b>📊 System Monitoring</b></summary>
<br>

![Fastfetch and Btop](Screenshots/withfastfetchandbtop.png)

</details>

<details open>
<summary><b>🚀 Application Launcher</b></summary>
<br>

![Rofi Launcher](Screenshots/rofi.png)

</details>

<details open>
<summary><b>🔔 Notifications</b></summary>
<br>

![SwayNC Notifications](Screenshots/swaync_notification.png)

</details>

<details open>
<summary><b>🌐 Browser</b></summary>
<br>

![Zen Browser](Screenshots/zen-browser.png)

</details>

---

## 🧩 Components

| Component | Name |
|-----------|------|
| 🪟 **Window Manager** | [Hyprland](https://hyprland.org/) |
| 📊 **Status Bar** | [Waybar](https://github.com/Alexays/Waybar) |
| 🚀 **App Launcher** | [Rofi](https://github.com/davatorium/rofi) |
| 🔔 **Notifications** | [SwayNC](https://github.com/ErikReider/SwayNotificationCenter) |
| 🖼️ **Wallpaper** | [Hyprpaper](https://github.com/hyprwm/hyprpaper) / [SWWW](https://github.com/LGFae/swww) |
| 🔒 **Lock Screen** | [Swaylock](https://github.com/swaywm/swaylock) |
| 💻 **Terminal** | [Kitty](https://sw.kovidgoyal.net/kitty/) / [Alacritty](https://alacritty.org/) |
| 🐚 **Shell** | [Zsh](https://www.zsh.org/) + [Starship](https://starship.rs/) |
| 📝 **Editor** | [Neovim](https://neovim.io/) |

---

## 🎨 Features

- **🌊 Blur Effects** - Beautiful blur with configurable opacity
- **✨ Smooth Animations** - Custom bezier curves for fluid window transitions
- **🎯 Dwindle Layout** - Efficient tiling with smart gaps
- **🔔 Notification Center** - Integrated SwayNC with custom styling
- **⚡ Fast Prompt** - Starship prompt with git integration and custom symbols
- **🖼️ Dynamic Wallpapers** - SWWW daemon for smooth wallpaper transitions

---

## 📁 Structure

```
dotfiles/
├── 📂 alacritty/          # Alacritty terminal config
├── 📂 hyprland/           # Hyprland WM configuration
│   └── .config/hypr/
│       ├── hyprland.conf      # Main config (imports modules)
│       ├── hypridle.conf      # Idle daemon config
│       ├── hyprpaper.conf     # Wallpaper config
│       ├── modules/           # Modular configs
│       │   ├── autostart.conf
│       │   ├── binds.conf
│       │   ├── decorations.conf
│       │   ├── env.conf
│       │   ├── monitors.conf
│       │   └── windowrules.conf
│       └── scripts/           # Helper scripts
├── 📂 kittyterminal/      # Kitty terminal config
├── 📂 nvim/               # Neovim configuration
├── 📂 rofi/               # Rofi launcher themes
├── 📂 starship/           # Starship prompt config
├── 📂 swaylock/           # Lock screen config
├── 📂 swaync/             # Notification center config
├── 📂 wallpaper/          # Wallpaper collection
├── 📂 waybar/             # Status bar config & styles
└── 📂 zsh/                # Zsh configuration
```

---

## 🚀 Installation

### Prerequisites

Make sure you have the following packages installed:

```bash
# Core
hyprland waybar rofi-wayland swaync swaylock hyprpaper hypridle swww

# Terminal & Shell
kitty alacritty zsh starship

# Utilities
polkit-gnome networkmanager pavucontrol

# Optional
neovim fastfetch btop eza
```

### Using GNU Stow (Recommended)

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Symlink all configs
stow alacritty hyprland kittyterminal nvim rofi starship swaylock swaync waybar zsh

# Or symlink individual configs
stow hyprland
stow waybar
# ... etc
```

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles

# Copy configs to .config
cp -r ~/dotfiles/hyprland/.config/hypr ~/.config/
cp -r ~/dotfiles/waybar/.config/waybar ~/.config/
cp -r ~/dotfiles/rofi/.config/rofi ~/.config/
# ... etc

# Copy zshrc
cp ~/dotfiles/zsh/.zshrc ~/
```

---

## ⌨️ Keybindings

Check out the keybindings in `hyprland/.config/hypr/modules/binds.conf`

---

## 🎨 Customization

### Changing Wallpaper

Edit `~/.config/hypr/hyprpaper.conf` or use SWWW:

```bash
swww img /path/to/wallpaper.png --transition-type grow
```

### Adjusting Blur & Opacity

Edit `hyprland/.config/hypr/modules/decorations.conf`:

```ini
decoration {
    active_opacity = 0.9
    inactive_opacity = 0.7
    
    blur {
        enabled = true
        size = 6
        passes = 4
    }
}
```

---

## 💝 Credits

- [Hyprland](https://hyprland.org/) - An amazing Wayland compositor
- [r/unixporn](https://reddit.com/r/unixporn) - For endless inspiration
- The Linux community for all the amazing open-source tools

---

<p align="center">
  <b>⭐ Star this repo if you found it helpful!</b>
</p>

<p align="center">
  Made with 💜 and lots of ☕
</p>
