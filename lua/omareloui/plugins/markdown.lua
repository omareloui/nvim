return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    opts = {
      preview = {
        -- "internal", "mini" or "devicons"
        icon_provider = vim.g.have_nerd_font and "internal" or "devicons",
      },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    enabled = vim.g.have_node,
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
  },
}
