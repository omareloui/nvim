return {
  "folke/trouble.nvim",
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
  cmd = { "TroubleToggle", "Trouble" },
  keys = {
    -- stylua: ignore start
    { "<leader>xx", "<Cmd>Trouble diagnostics toggle filter.not.severity = vim.diagnostic.severity.HINT<CR>", desc = "Diagnostics (Trouble)" },
    { "<leader>xX", "<Cmd>Trouble diagnostics toggle filter.buf=0 filter.not.severity=vim.diagnostic.severity.INFO<CR>", desc = "Buffer Diagnostics (Trouble)" },
    { "<leader>xs", "<Cmd>Trouble symbols toggle focus=false<CR>", desc = "Symbols (Trouble)" },
    { "<leader>xl", "<Cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "LSP Definitions / references / ... (Trouble)" },
    { "<leader>xL", "<Cmd>Trouble loclist toggle<CR>", desc = "Location List (Trouble)" },
    { "<leader>xq", "<Cmd>Trouble qflist toggle<CR>", desc = "Quickfix List (Trouble)" },

    { "<leader>xw", function() require("trouble").toggle "workspace_diagnostics" end, desc = "Toggle workspace diagnostics (Trouble)" },
    { "<leader>xd", function() require("trouble").toggle "document_diagnostics" end, desc = "Toggle document diagnostics (Trouble)" },

    -- stylua: ignore end
    {
      "[q",
      function()
        local trouble = require "trouble"
        if trouble.is_open() then
          trouble.prev { skip_groups = true, jump = true }
        else
          local ok, err = pcall(vim.cmd.cprev)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      desc = "Previous trouble/quickfix item",
    },
    {
      "]q",
      function()
        local trouble = require "trouble"
        if trouble.is_open() then
          trouble.next { skip_groups = true, jump = true }
        else
          local ok, err = pcall(vim.cmd.cnext)
          if not ok and err then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      desc = "Next trouble/quickfix item",
    },
  },

  config = function()
    local ok, trouble = pcall(require, "trouble")

    -- stylua: ignore
    if not ok then return end

    local opts = {
      use_diagnostic_signs = true,
      severity = vim.diagnostic.severity.INFO,
    }

    local wk = require "which-key"
    wk.add { { "<leader>x", group = "trouble" } }

    trouble.setup(opts)
  end,
}
