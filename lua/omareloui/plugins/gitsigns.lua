return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },

  opts = {
    signs = { changedelete = { text = "–" } },
    preview_config = { border = "rounded" },
    current_line_blame = true,
  },

  --stylua: ignore
  keys = {
    { "<leader>gd", function() require("gitsigns").diffthis() end, desc = "Diff this file"},
    { "<leader>gbS", function() require("gitsigns").stage_buffer() end, desc = "Stage buffer" },
    { "<leader>gbR", function() require("gitsigns").reset_buffer() end, desc = "Reset buffer" },
    { "<leader>ghS", function() require("gitsigns").stage_hunk() end, desc = "Stage hunk", mode = { "n", "v" } },
    { "<leader>ghp", function() require("gitsigns").preview_hunk() end, desc = "Preview hunk" },
    { "]h", function() require("gitsigns").next_hunk() end, desc = "Next hunk" },
    { "[h", function() require("gitsigns").preview_hunk() end, desc = "Previous hunk" },
  },
}
