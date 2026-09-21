-- Colourscheme follows the hypr-theme engine (see config/hypr-theme.lua).
-- "hyprmono" is generated from the theme palette by lua/hyprmono/init.lua;
-- zenbones stays installed as the fallback family with real light/dark
-- variants for themes that name it.
local bridge = require("config.hypr-theme")
local theme = bridge.read()

return {
  {
    "zenbones-theme/zenbones.nvim",
    dependencies = "rktjmp/lush.nvim",
    lazy = false,
    priority = 1000,
    init = function()
      vim.o.background = theme.background or "dark"
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        bridge.apply()
      end,
    },
  },
}
