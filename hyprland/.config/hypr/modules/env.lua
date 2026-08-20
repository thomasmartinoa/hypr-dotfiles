-- ~/.config/hypr/modules/env.lua
-- Ported 1:1 from modules/env.conf.
--
-- `hl.env(NAME, VALUE)` sets a variable before the display server initialises.
-- Both arguments are strings — numbers must be quoted. Changes need a logout
-- (or restarting the app) to reach already-running processes.
--
-- Sections:
--   1. Session identity (XDG / Wayland)
--   2. Toolkit / backend selection
--   3. HiDPI scaling (monitor scale = 1.60)
--   4. Cursor sizing
--   5. NVIDIA / GPU
--   6. Disabled / optional (kept for reference)


-- ─── 1. Session identity ─────────────────────────────────────────────────────
hl.env("XDG_SESSION_TYPE",    "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")


-- ─── 2. Toolkit / backend selection ──────────────────────────────────────────
-- Native Wayland first, X11 only as a fallback.

hl.env("GDK_BACKEND", "wayland,x11,*")           -- GTK
hl.env("QT_QPA_PLATFORM", "wayland;xcb")         -- Qt
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")          -- see ENV-03: Qt6 apps stay unthemed
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")


-- ─── 3. HiDPI scaling (paired with xwayland.force_zero_scaling) ──────────────
-- Native-Wayland apps get the scale from the compositor. XWayland apps do not,
-- so each toolkit is told by hand.

hl.env("GDK_SCALE", "1.6")                       -- see ENV-01: GTK only accepts integers
hl.env("QT_SCALE_FACTOR", "1.6")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")       -- see ENV-02: this ENABLES auto-scaling
hl.env("_JAVA_OPTIONS", "-Dsun.java2d.uiScale=1.6")


-- ─── 4. Cursor sizing ────────────────────────────────────────────────────────
-- Keep in sync: XCURSOR_SIZE = HYPRCURSOR_SIZE * monitor scale (16 * 1.6 ≈ 26).

hl.env("HYPRCURSOR_SIZE", "16")
hl.env("XCURSOR_SIZE", "26")


-- ─── 5. NVIDIA / GPU ─────────────────────────────────────────────────────────
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("LIBVA_DRIVER_NAME", "nvidia")

-- Leave off unless an X11 GL app misbehaves; some setups break with it enabled.
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")


-- ─── 6. Disabled / optional (uncomment if needed) ────────────────────────────

-- hl.env("WLR_NO_HARDWARE_CURSORS", "1")   -- if NVIDIA hardware cursors flicker

-- PRIME render offload for hybrid Intel+NVIDIA (`prime-run <app>`)
-- hl.env("__NV_PRIME_RENDER_OFFLOAD", "1")
-- hl.env("__VK_LAYER_NV_optimus", "NVIDIA_only")

-- hl.env("NVD_BACKEND", "direct")          -- can fix Firefox VA-API on some drivers
-- hl.env("GTK_USE_PORTAL", "1")            -- force GTK pickers through xdg-desktop-portal

-- hl.env("MOZ_DISABLE_RDD_SANDBOX", "1")
-- hl.env("EGL_PLATFORM", "wayland")

-- Software rendering — only useful inside a VM without GPU passthrough.
-- hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")
-- hl.env("LIBGL_ALWAYS_SOFTWARE", "1")
