-- Bridge to the hypr-theme engine.
--
-- `hypr-theme set <name>` renders ~/.config/hypr-theme/current/neovim.lua
-- ({ colorscheme = "...", background = "dark"|"light" }) and then asks every
-- running nvim to call apply() over --remote-send. On startup, read() feeds
-- the colorscheme into LazyVim's opts (see plugins/theme.lua).

local M = {}

local path = vim.fn.expand("~/.config/hypr-theme/current/neovim.lua")

function M.read()
  local ok, t = pcall(dofile, path)
  if ok and type(t) == "table" then
    return t
  end
  return { colorscheme = "habamax", background = "dark" }
end

function M.apply()
  local t = M.read()
  vim.o.background = t.background or "dark"
  if t.colorscheme == "hyprmono" and t.palette then
    require("hyprmono").load(t.palette)
    return
  end
  if t.colorscheme == "aether" and t.aether then
    -- omacom/aether.nvim built from the palette, the way Aether/Omarchy do it
    local ok_a, aether = pcall(require, "aether")
    if ok_a then
      -- setup() first: lualine's aether theme reads the saved options, not
      -- the opts passed to load(), and would otherwise show stock colours.
      aether.setup({ colors = t.aether })
      aether.load()
      return
    end
  end
  local ok = pcall(vim.cmd.colorscheme, t.colorscheme)
  if not ok then
    vim.notify("hypr-theme: colorscheme '" .. tostring(t.colorscheme) .. "' not installed", vim.log.levels.WARN)
  end
end

return M
