local function select(i)
  return function()
    (require "harpoon"):list():select(i)
  end
end

return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  event = "VeryLazy",

  dependencies = { "nvim-lua/plenary.nvim" },

  keys = {
    {
      "<leader>ho",
      function()
        local harpoon = require "harpoon"
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = "Open Harpoon menu",
    },
    {
      "<leader>ha",
      function()
        (require "harpoon"):list():add()
      end,
      desc = "Add to Harpoon",
    },
    {
      "<leader>hh",
      function()
        (require "harpoon"):list():prev { ui_nav_wrap = true }
      end,
      desc = "Go to previous Harpoon file",
    },
    {
      "<leader>hl",
      function()
        (require "harpoon"):list():next { ui_nav_wrap = true }
      end,
      desc = "Go to next Harpoon file",
    },
    { "<A-1>", select(1), desc = "Go to Harpoon file 1" },
    { "<A-2>", select(2), desc = "Go to Harpoon file 2" },
    { "<A-3>", select(3), desc = "Go to Harpoon file 3" },
    { "<A-4>", select(4), desc = "Go to Harpoon file 4" },
    { "<A-5>", select(5), desc = "Go to Harpoon file 5" },
    { "<A-6>", select(6), desc = "Go to Harpoon file 6" },
  },

  config = function()
    require("harpoon"):setup()
  end,
}
