return {
  "nguyenvukhang/nvim-toggler",
  enabled = true,
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },

  keys = {
    {
      "<leader>cl",
      function()
        require("nvim-toggler").toggle()
      end,
      desc = "Toggle the cursor word (eg. from true to false)",
      mode = { "n", "v" },
    },
  },

  opts = {
    remove_default_keybinds = true,
    inverses = {
      ["True"] = "False",
      ["right"] = "left",
      ["Right"] = "Left",
      ["start"] = "end",
      ["&&"] = "||",
      ["&"] = "|",
    },
  },
}
