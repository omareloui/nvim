local plugins = {}

local vue_lsp_path = require("omareloui.util.local_config").get "system_packages.vue_lsp"
if vue_lsp_path then
  table.insert(plugins, {
    name = "@vue/typescript-plugin",
    location = vue_lsp_path,
    languages = { "vue" },
  })
end

return {
  setup = function(lspconfig, on_attach, capabilities)
    lspconfig["ts_ls"].setup {
      root_dir = lspconfig.util.root_pattern "package.json",
      single_file_support = false,

      filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
      init_options = {
        plugins = plugins,
      },

      capabilities = capabilities,
      on_attach = function(_, bufnr)
        on_attach(_, bufnr)

        local function set(lhs, rhs, desc, mode)
          return require("omareloui.util.keymap").set(lhs, rhs, desc, { buffer = bufnr or 0, mode = mode })
        end

        local function apply_code_action(action)
          vim.lsp.buf.code_action {
            apply = true,
            context = {
              only = { action },
              diagnostics = {},
            },
          }
        end

        set("<leader>co", function()
          apply_code_action "source.organizeImports.ts"
        end, "Organize Imports")

        set("<leader>cr", function()
          apply_code_action "source.removeUnused.ts"
        end, "Remove Unused Imports")
      end,
    }
  end,
}
