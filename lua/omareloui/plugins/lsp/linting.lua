return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },

  keys = {
    -- stylua: ignore
    { "<leader>ll", function() require("lint").try_lint() end, desc = "Trigger linting for current file." },
  },

  config = function()
    local present, lint = pcall(require, "lint")

    -- stylua: ignore
    if not present then return end

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

    local js_linter = "eslint"

    lint.linters_by_ft = {
      astro = { js_linter, "cspell" },
      bzl = { "buildifier", "cspell" },
      cs = { "cspell" },
      dockerfile = { "hadolint", "cspell" },
      gitcommit = { "gitlint", "cspell" },
      go = { "golangcilint", "cspell" },
      html = { "htmlhint", "cspell" },
      javascript = { js_linter, "cspell" },
      javascriptreact = { js_linter, "cspell" },
      lua = { "luacheck", "cspell" },
      markdown = { "markdownlint", "vale", "cspell" },
      nix = { "statix", "cspell" },
      proto = { "buf", "cspell" },
      python = { "flake8" },
      sh = { "shellcheck", "cspell" },
      sql = { "sqlfluff", "cspell" },
      svelte = { js_linter, "cspell" },
      text = { "cspell" },
      typescript = { js_linter, "cspell" },
      typescriptreact = { js_linter, "cspell" },
      yaml = { "yamllint", "cspell" },
      ansible = { "ansible_lint" },
      vue = { js_linter, "cspell" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

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
}
