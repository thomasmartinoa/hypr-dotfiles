# Verify — look at what you changed

The rice was built by measuring screenshots, not by trusting code. Every
visual change ends with a capture you read.

```bash
SP=${SCRATCH:-/tmp/hypr-check}; mkdir -p "$SP"
grim -s 0.6 "$SP/full.png"                       # whole screen, scaled (fast to read)
grim "$SP/full.png" && ffmpeg -y -loglevel error -i "$SP/full.png" \
     -vf "crop=1100:900:iw-1100:0" "$SP/topright.png"   # a crop, e.g. a panel under the bar
```
Then **read the PNG** (Read tool) and compare against what you meant. For
pixel questions convert to raw grey and measure runs (`ffmpeg -i x.png -f
rawvideo -pix_fmt gray -` + a few lines of python) instead of eyeballing.

## Drive the shell without the mouse

```bash
qs ipc call launcher toggle | picker theme | picker wallpaper | clipboard open | powermenu toggle
qs ipc call panels open audio|network|bluetooth|power|agents|notifications ; qs ipc call panels close
qs ipc call notifications test ; qs ipc call bar toggle ; qs ipc call bar position left|top
hypr-theme set hyprmono-light ; hypr-theme set hyprmono      # dark/light
sleep 1.5 between opening and capturing (animations, async images)
```
Open a real app for app theming: `hypr-float btop` / `hypr-float nvim <file>`
(it opens its own kitty, class `hypr-float`, centred and big enough for btop —
do **not** wrap a `kitty` inside it), `thunar &`; then `hyprctl dispatch
focuswindow class:hypr-float`. Close it after by pid — `closewindow address:…`
is rejected by the lua dispatcher on this Hyprland:

```bash
for p in $(hyprctl clients -j | jq -r '.[] | select(.class=="hypr-float") | .pid'); do kill $p; done
```
and confirm `hyprctl clients -j | jq -r '.[].class'` lists none left.

## The checklist for "check the rice" / a new theme

For **dark and light**: bar (pill + minimal), launcher, clipboard, a
notification popup + the bell's list, audio/network/power/agents panels,
picker (theme + wallpaper), power menu, kitty with fastfetch, btop, nvim,
Thunar, one Qt app, VS Code, the lock screen (rule 5 in SKILL.md — a lock
capture needs the user present; the SDDM greeter shares its layout).

Flag: text below ~3:1 contrast, colour that is not grey in a mono theme (except git) or
a grey where the stock upstream theme has a colour in a hued theme (btop boxes, lock fail), corners
not 4px / missing 1px border, glyph boxes (font), clipped or overlapping
text, anything that differs between the two themes in *layout*.

## Comparing against a reference

When asked for "identical to X": capture both at the same scale, crop the
same region, measure heights/widths/paddings numerically, and iterate until
the numbers match; a 1px text-height difference between GTK and Qt hinting
is the known floor.

Put the user's theme back (`hypr-theme set <the one from hypr-theme current at start>`)
and close anything you opened.
