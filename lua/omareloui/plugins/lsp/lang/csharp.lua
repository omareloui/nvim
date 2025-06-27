local dll_path = require("omareloui.util.local_config").get "system_packages.omnisharp_dll"

return {
  enabled = not not dll_path,
  setup = function(lspconfig, on_attach, capabilities)
    lspconfig["omnisharp"].setup {
      cmd = {
        "dotnet",
        location = dll_path,
      },

      capabilities = capabilities,
      on_attach = on_attach,

      settings = {
        FormattingOptions = {
          EnableEditorConfigSupport = true,
          OrganizeImports = true,
        },
        MsBuild = {
          LoadProjectsOnDemand = nil,
        },
        RoslynExtensionsOptions = {
          EnableAnalyzersSupport = true,
          EnableImportCompletion = true,
          AnalyzeOpenDocumentsOnly = nil,
        },
        Sdk = {
          IncludePrereleases = true,
        },
      },
    }
  end,
}
