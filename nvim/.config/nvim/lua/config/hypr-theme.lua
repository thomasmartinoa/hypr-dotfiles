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
  local ok = pcall(vim.cmd.colorscheme, t.colorscheme)
  if not ok then
    vim.notify("hypr-theme: colorscheme '" .. tostring(t.colorscheme) .. "' not installed", vim.log.levels.WARN)
  end
end

return M
