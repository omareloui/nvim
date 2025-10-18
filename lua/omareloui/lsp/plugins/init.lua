local local_config = require "common.local_config"

---@return string[]
local function get_servers(key)
  local formatters_by_ft = local_config.get(key, {})
  local formatters = {}
  local seen = {}
  for _, ft_formatters in pairs(formatters_by_ft) do
    for _, formatter in ipairs(ft_formatters) do
      if not seen[formatter] then
        seen[formatter] = true
        table.insert(formatters, formatter)
      end
    end
  end
  return formatters
end

local function try_lint()
  local lint = require "lint"
  local filename = vim.fn.expand "%:t"

  if filename == ".env" or filename:match "^%.env%." then
    return
  end

  return lint.try_lint()
end

return {
  { "neovim/nvim-lspconfig" },

  {
    "williamboman/mason.nvim",
    enabled = local_config.get("lsp.mason.enabled", false),
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    dependencies = {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    cmd = "Mason",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup { ui = { border = "rounded" }, PATH = "append" }

      local ensure_installed = vim.tbl_keys(local_config.get("lsp.servers", {}))
      vim.list_extend(ensure_installed, get_servers "lsp.formatters_by_ft")
      vim.list_extend(ensure_installed, get_servers "lsp.linters_by_ft")
      require("mason-tool-installer").setup { ensure_installed = ensure_installed }
    end,
  },

  {
    "j-hui/fidget.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    opts = {
      notification = {
        window = {
          winblend = 0,
        },
      },
    },
  },

  {
    "saghen/blink.cmp",
    version = "1.*",

    build = "nix run .#build-plugin",

    opts = {
      keymap = { preset = "default" },

      signature = { enabled = true },

      completion = {
        ghost_text = { enabled = true },
        documentation = { auto_show = false },
      },

      snippets = {
        preset = "luasnip",
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      fuzzy = {
        implementation = "prefer_rust",
        sorts = {
          "exact",
          "score",
          "sort_text",
        },
      },
    },

    opts_extend = { "sources.default" },
  },

  {
    "L3MON4D3/LuaSnip",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    version = "v2.*",

    build = (function()
      if vim.fn.has "win32" == 1 or vim.fn.executable "make" == 0 then
        return
      end
      return "make install_jsregexp"
    end)(),

    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        enabled = false,
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },

    config = function()
      local ls = require "luasnip"

      require("luasnip.loaders.from_lua").lazy_load { paths = "~/.config/nvim/lua/common/snippets" }

      local options = {
        history = true,
        updateevents = "TextChanged,TextChangedI",
        enable_autosnippets = true,
      }

      ls.config.set_config(options)
    end,

    keys = {
      {
        "<C-j>",
        function()
          local ls = require "luasnip"
          if ls.expand_or_jumpable() then
            ls.expand_or_jump()
          end
        end,
        desc = "Expand the snippet or jump to the next snippet placeholder",
        mode = { "i", "s" },
        silent = true,
      },

      {
        "<C-k>",
        function()
          local ls = require "luasnip"
          if ls.jumpable(-1) then
            ls.jump(-1)
          end
        end,
        desc = "Jump to the previous placeholder",
        mode = { "i", "s" },
        silent = true,
      },

      {
        "<C-l>",
        function()
          local ls = require "luasnip"
          if ls.choice_active() then
            ls.change_choice(1)
          end
        end,
        desc = "Cycle in snippet's options right",
        mode = { "i", "s" },
        silent = true,
      },

      {
        "<C-h>",
        function()
          local ls = require "luasnip"
          if ls.choice_active() then
            ls.change_choice(-1)
          end
        end,
        desc = "Cycle in snippet's options left",
        mode = { "i", "s" },
        silent = true,
      },
    },
  },

  {
    "stevearc/conform.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },

    --stylua: ignore
    keys = {
      { "<leader>lf", function() require("conform").format { lsp_fallback = true, async = false, timeout_ms = 2000 } end, desc = "Format file", mode = { "v", "n" }, },
      { "<leader>nf", "<Cmd>noa up<CR>", desc = "Save buffer without formatting" },
    },

    config = function(_, opts)
      local nvim_config

      local windows_app_data = os.getenv "LOCALAPPDATA"
      if windows_app_data then
        nvim_config = windows_app_data .. "/nvim"
      else
        local config = os.getenv "XDG_CONFIG_HOME" or os.getenv "HOME" .. "/.config"
        nvim_config = config .. "/nvim"
      end

      opts = {
        formatters = {
          buildifier = {
            inherit = false,
            command = "buildifier",
          },

          sql_formatter = {
            prepend_args = { "-c", nvim_config .. "/lua/common/lsp/sql_formatter.json" },
          },

          prettier = {
            options = {
              ft_parsers = {
                svg = "html",
              },
            },
          },
        },

        format_on_save = { lsp_fallback = true, timeout_ms = 2000 },

        formatters_by_ft = local_config.get("lsp.formatters_by_ft", {}),

        notify_on_error = true,
      }

      require("conform").setup(opts)
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },

    --stylua: ignore
    keys = {
      { "<leader>ll", try_lint, desc = "Trigger linting for current file." },
    },

    config = function()
      local lint = require "lint"

      local proto_lint_pattern = "([^:]+):(%d+):(%d+):(.+)"
      local proto_lint_groups = { "file", "lnum", "col", "message" }
      local buf_parser = require("lint.parser").from_pattern(
        proto_lint_pattern,
        proto_lint_groups,
        nil,
        { ["source"] = "buf", ["severity"] = vim.diagnostic.severity.WARN }
      )

      lint.linters.buf = {
        cmd = "buf",
        args = {
          "lint",
          "--path",
        },
        stdin = false,
        append_fname = true,
        ignore_exitcode = true,
        parser = buf_parser,
      }

      lint.linters_by_ft = local_config.get("lsp.linters_by_ft", {})

      -- vim.api.nvim_create_autocmd(
      --   { "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" },
      --   { group = vim.api.nvim_create_augroup("lint", { clear = true }), callback = try_lint }
      -- )

      local cspell_ns = lint.get_namespace "cspell"

      vim.diagnostic.config({
        virtual_text = false,
        signs = false,
      }, cspell_ns)

      lint.linters.cspell = require("lint.util").wrap(lint.linters.cspell, function(diagnostic)
        diagnostic.severity = vim.diagnostic.severity.HINT
        return diagnostic
      end)
    end,
  },
}
