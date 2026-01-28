# GRUB Themes

Collection of themes to make your bootloader look prettier.

## How to Install

Copy any theme folder to `/boot/grub/themes/`:
```bash
sudo cp -r sayonara /boot/grub/themes/
```

Then pick one of these methods to activate it:

### GUI Method (easier)
If you prefer clicking buttons over editing config files:
- Install GRUB Customizer: `sudo pacman -S grub-customizer`
- Open it up and head to "Appearance settings"
- Pick your theme from the list
- Hit save and you're done

### Manual Method (for the config warriors)
If you like doing things the old-fashioned way:
- Open `/etc/default/grub` in your editor
- Add this line (change the theme name if needed):
  ```
  GRUB_THEME="/boot/grub/themes/sayonara/theme.txt"
  ```
- Regenerate your GRUB config: `sudo grub-mkconfig -o /boot/grub/grub.cfg`

Reboot and enjoy your fancy new bootloader!

## Adding More Themes

Same drill for any theme you find - just drop it in `/boot/grub/themes/`, select it, and reboot.
