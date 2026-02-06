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

local linter_cache = {}

local function try_lint()
  local lint = require "lint"
  local filename = vim.fn.expand "%:t"

  if vim.bo.filetype == "sh" and (filename == ".env" or filename:match "^%.env%.") then
    return
  end

  -- Filter out linters whose binaries don't exist (with caching)
  local linters = lint.linters_by_ft[vim.bo.filetype] or {}

  local available_linters = vim.tbl_filter(function(linter)
    if linter_cache[linter] ~= nil then
      return linter_cache[linter]
    end

    local linter_config = lint.linters[linter]
    if not linter_config then
      linter_cache[linter] = false
      return false
    end

    local cmd = linter_config.cmd
    local is_available = cmd and type(cmd) == "string" and vim.fn.executable(cmd) == 1
    linter_cache[linter] = is_available
    return is_available
  end, linters)

  lint.try_lint(available_linters)
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
      { "<leader>lf", function() require("conform").format { lsp_fallback = true, async = false, timeout_ms = 2000 } end, desc = "Format file", mode = { "v", "n" } },
      { "<leader>nf", "<Cmd>noa up<CR>", desc = "Save buffer without formatting" },
    },

    config = function()
      local nvim_config

      local windows_app_data = os.getenv "LOCALAPPDATA"
      if windows_app_data then
        nvim_config = windows_app_data .. "/nvim"
      else
        local config = os.getenv "XDG_CONFIG_HOME" or os.getenv "HOME" .. "/.config"
        nvim_config = config .. "/nvim"
      end

      local opts = {
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

    keys = {
      { "<leader>ll", try_lint, desc = "Trigger linting for current file." },
    },

    config = function()
      local lint = require "lint"

      lint.linters_by_ft = local_config.get("lsp.linters_by_ft", {})

      vim.api.nvim_create_autocmd(
        { "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" },
        { group = vim.api.nvim_create_augroup("lint", { clear = true }), callback = try_lint }
      )

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
