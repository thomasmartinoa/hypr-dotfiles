-- Colourscheme follows the hypr-theme engine (see config/hypr-theme.lua).
local theme = require("config.hypr-theme").read()

return {
  -- zenbones: near-monochrome family with matching light and dark variants.
  -- "zenwritten" is the neutral grey one used by the HyprMono themes.
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
      colorscheme = theme.colorscheme,
    },
  },
}
