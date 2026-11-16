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
      -- auto detection calls vim.pack.get(), which tries to write a lockfile
      -- into the read-only (nix store) config dir
      auto_integrations = false,
      integrations = {
        blink_cmp = { enabled = true, style = "bordered" },
        dap = true,
        dap_ui = true,
        fidget = true,
        gitsigns = true,
        harpoon = true,
        indent_blankline = { enabled = true },
        markview = true,
        mini = { enabled = true },
        neotest = true,
        nvim_surround = true,
        rainbow_delimiters = true,
        telescope = { enabled = true },
        treesitter_context = true,
        ufo = true,
        which_key = true,
      },
    }

    catppuccin.setup(opts)
  end,
}
