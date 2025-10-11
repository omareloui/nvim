return {
  "folke/todo-comments.nvim",
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
  cmd = { "TodoTrouble", "TodoTelescope" },
  opts = {},

  --stylua: ignore
  keys = {
    { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
    { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
    { "<leader>ft", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme comments" },
    { "<leader>fT", "<cmd>TodoTelescope<cr>", desc = "Todo" },
  },
}
