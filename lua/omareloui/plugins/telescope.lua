local should_install_fzf_plugin = vim.fn.executable "make" == 1

return {
  "nvim-telescope/telescope.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-live-grep-args.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = should_install_fzf_plugin,
    },
    { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
  },

  config = function()
    local telescope = require "telescope"
    local lga_actions = require "telescope-live-grep-args.actions"

    local options = {
      defaults = {
        --stylua: ignore
        vimgrep_arguments = { "rg", "-L", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" },
        file_ignore_patterns = {
          "node_modules",
          ".cache",
          "__pycache__",
          "venv",
          "%.git/",
          "%.output/",
          ".nuxt",
          "vendor",
        },
        color_devicons = vim.g.have_nerd_font,
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
        live_grep_args = {
          auto_quoting = true,
          mappings = {
            i = {
              ["<C-k>"] = lga_actions.quote_prompt(),
              ["<C-i>"] = lga_actions.quote_prompt { postfix = " --iglob " },
              ["<C-space>"] = lga_actions.to_fuzzy_refine,
            },
            n = {
              ["<C-k>"] = lga_actions.quote_prompt(),
              ["<C-i>"] = lga_actions.quote_prompt { postfix = " --iglob " },
              ["<C-space>"] = lga_actions.to_fuzzy_refine,
            },
          },
        },
      },
    }

    telescope.setup(options)

    if should_install_fzf_plugin then
      telescope.load_extension "fzf"
    end

    telescope.load_extension "live_grep_args"
  end,

  keys = {
    { "<leader>ff", "<Cmd>Telescope find_files follow=true hidden=true<CR>", desc = "Find files" },
    { "<leader>fa", "<Cmd>Telescope find_files follow=true hidden=true no_ignore=true<CR>", desc = "Find all" },
    { "<leader>fo", "<Cmd>Telescope oldfiles<CR>", desc = "Find in recent opened files" },
    { "<leader>fb", "<Cmd>Telescope buffers<CR>", desc = "Search in buffers" },
    { "<leader>fh", "<Cmd>Telescope help_tags<CR>", desc = "Find in help tags" },
    { "<leader>fk", "<Cmd>Telescope keymaps<CR>", desc = "Show key mappings" },
    { "<leader>fn", "<Cmd>Telescope file_browser files=false hide_parent_dir=true<CR>", desc = "Open file browser" },
    { "<leader>fr", "<Cmd>Telescope file_browser cwd=~/repos<CR>", desc = "Open all repos" },
    --stylua: ignore
    { "<leader>fw", function() require("telescope").extensions.live_grep_args.live_grep_args() end, desc = "Live grep with args" },

    { "<leader>gs", "<Cmd>Telescope git_status<CR>", desc = "Git status" },
  },
}
