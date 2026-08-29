-- ─── 1. Session identity ─────────────────────────────────────────────────────
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- ─── 2. Toolkit / backend selection ──────────────────────────────────────────
-- Native Wayland first, X11 only as a fallback.

hl.env("GDK_BACKEND", "wayland,x11,*") -- GTK
hl.env("QT_QPA_PLATFORM", "wayland;xcb") -- Qt
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
--hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")

-- ─── 3. HiDPI scaling (paired with xwayland.force_zero_scaling) ──────────────
-- Native-Wayland apps get the scale from the compositor. XWayland apps do not,
-- so each toolkit is told by hand.

--hl.env("GDK_SCALE", "1.6")                 
hl.env("QT_SCALE_FACTOR", "1.6")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "0") 
hl.env("JDK_JAVA_OPTIONS", "-Dsun.java2d.uiScale=1.6")

-- ─── 4. Cursor sizing ────────────────────────────────────────────────────────
hl.env("HYPRCURSOR_SIZE", "16")
hl.env("XCURSOR_SIZE", "24")

-- ─── 5. NVIDIA / GPU ─────────────────────────────────────────────────────────
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("LIBVA_DRIVER_NAME", "nvidia")


-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- ─── 6. Disabled / optional ────────────────────────────

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
