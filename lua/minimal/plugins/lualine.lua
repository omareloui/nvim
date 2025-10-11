local c = require "common.ui.palette"
local i = require("common.ui.icons").lualine

return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
    "AndreM222/copilot-lualine",
  },

  opts = {
    options = {
      globalstatus = true,
      icons_enabled = true,
      disabled_filetypes = { "oil" },
      ignore_focus = {
        "toggleterm",
        "lazy",
        "help",
        "mason",
        "lspinfo",
        "TelescopePrompt",
      },
      always_divide_middle = true,
    },

    sections = {
      lualine_a = { "mode" },

      lualine_b = {
        "branch",
        { "diff", symbols = i.git },
        "diagnostics",
      },

      lualine_c = {
        {
          "filename",
          path = 4,
          shorting_target = 40,
          symbols = i.file_symbols,
        },
      },

      lualine_x = {
        { "copilot", show_colors = true },
        { require("lazy.status").updates, cond = require("lazy.status").has_updates, color = { fg = c.yellow } },
        { "encoding" },
        { "fileformat" },
        { "filetype" },
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },
  },
}
