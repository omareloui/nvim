return {
  setup = function(lspconfig, on_attach, capabilities)
    lspconfig["html"].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "html", "templ", "jinja.html" },
    }
  end,
}
