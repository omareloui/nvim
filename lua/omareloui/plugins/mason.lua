local localconfig = require "omareloui.util.local_config"

return {
  "williamboman/mason.nvim",
  enabled = localconfig.get("plugins.mason.enabled", false),
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },

  cmd = "Mason",
  build = ":MasonUpdate",
  config = function()
    local mason = require "mason"
    local mason_lspconfig = require "mason-lspconfig"
    local mason_tool_installer = require "mason-tool-installer"

    mason.setup {
      ui = { border = "rounded" },
      PATH = "append",
    }

    mason_lspconfig.setup {
      ensure_installed = {
        "astro",
        "bashls",
        "cssls",
        "denols",
        "dockerls",
        "elixirls",
        "emmet_ls",
        "eslint",
        "gopls",
        "html",
        "lua_ls",
        "marksman",
        "prismals",
        "tailwindcss",
        "templ",
        "yamlls",
      },
    }

    mason_tool_installer.setup {
      ensure_installed = {
        "buf",
        "buildifier",
        "cspell",
        "eslint_d",
        "gitlint",
        "golangci-lint",
        "hadolint",
        "htmlhint",
        "luacheck",
        "markdownlint",
        "prettier",
        "prettierd",
        "shellcheck",
        "shfmt",
        "sql-formatter",
        "sqlfluff",
        "stylua",
        "yamlfmt",
        "yamllint",
      },
    }
  end,
}
