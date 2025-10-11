return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  config = function()
    local catppuccin = require "catppuccin"

    local opts = {
      transparent_background = true,
      float = { transparent = true },
      flavour = "mocha",
    }

    catppuccin.setup(opts)
  end,
}
