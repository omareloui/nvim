local local_config = require "common.local_config"

local servers_config = local_config.get("lsp.servers", {}) --[[@as table<string, table>]]

vim.lsp.enable(vim.tbl_keys(servers_config))
for server, config in pairs(servers_config) do
  if config then
    vim.lsp.config(server, config)
  end
end

vim.filetype.add {
  extension = {
    templ = "templ",
    mdx = "markdown",

    j2 = "jinja",
  },
  pattern = {
    [".*/hypr/.*%.conf"] = "hyprlang",

    [".*/.*%.html%.j2"] = "jinja.html",

    [".*/.*%.component%.html?"] = "htmlangular",
    [".*/.*%.container%.html?"] = "htmlangular",
  },
}

vim.diagnostic.config {
  float = { border = "rounded", source = "if_many" },
  severity_sort = true,
  underline = true,
  update_in_insert = true,
  virtual_text = {
    current_line = true,
    prefix = require("common.ui.icons").diagnostics_virtuals.prefix,
    source = true,
    spacing = 2,
  },
  signs = vim.g.have_nerd_font and { text = require("common.ui.icons").diagnostics } or {},
}

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),

  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    -- Remaps
    local set = require("common.keymap").set
    local diagnostic_utils = require "common.diagnostics-utils"

    set("[d", diagnostic_utils.jump_prev, "Go to previous diagnostic")
    set("]d", diagnostic_utils.jump_next, "Go to next diagnostic")

    -- Attach `ts_ls` specific keymaps
    if client and client.name == "ts_ls" then
      set("<leader>co", function()
        vim.lsp.buf.code_action {
          apply = true,
          context = {
            only = { "source.organizeImports.ts" },
            diagnostics = {},
          },
        }
      end, "Organize Imports", { buffer = event.buf })

      set("<leader>cr", function()
        vim.lsp.buf.code_action {
          apply = true,
          context = {
            only = { "source.removeUnused.ts" },
            diagnostics = {},
          },
        }
      end, "Remove Unused Imports", { buffer = event.buf })
    end

    -- Attach `gopls` specific keymaps and autocommands
    if client and client.name == "gopls" then
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          local params = vim.lsp.util.make_range_params()
          params.context = { only = { "source.organizeImports" } }
          local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
          for cid, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
              if r.edit then
                local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                vim.lsp.util.apply_workspace_edit(r.edit, enc)
              end
            end
          end
          vim.lsp.buf.format { async = false }
        end,
      })
    end

    -- When you move your cursor, the highlights will be cleared (the second autocommand).
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd("LspDetach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = "kickstart-lsp-highlight", buffer = event2.buf }
        end,
      })
    end
  end,
})
