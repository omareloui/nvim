local should_install_fzf_plugin = vim.fn.executable "make" == 1

local function get_grepprg()
  local common_args = {
    "-L",
    "--hidden",
    "--no-heading",
    "--line-number",
  }

  local grep_args = {
    "grep",
    "-b",
    "--ignore-case",
    "--recursive",
    "--no-messages",
  }

  local ripgrep_args = {
    "rg",
    "--color=never",
    "--with-filename",
    "--line-number",
    "--column",
    "--smart-case",
  }

  local args = {}

  local is_ripgrep = vim.o.grepprg:find "rg" ~= nil
  if is_ripgrep then
    args = vim.list_extend(ripgrep_args, common_args)
  else
    args = vim.list_extend(grep_args, common_args)
  end

  return args
end

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
    local actions = require "telescope.actions"
    local lga_actions = require "telescope-live-grep-args.actions"

    local options = {
      defaults = {
        vimgrep_arguments = get_grepprg(),
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
        mappings = {
          i = {
            ["<esc>"] = actions.close,
            ["<C-o>"] = actions.send_selected_to_qflist,
          },
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

    local tb = require "telescope.builtin"
    local gas = require "telescope-live-grep-args.shortcuts"
    local km_common_opts = { disable_devicons = not vim.g.have_nerd_font }

    local function get_km_cb(fun, opts)
      return function()
        fun(vim.tbl_extend("force", opts or {}, km_common_opts))
      end
    end

    local set = require("common.keymap").set

    set("<leader>fa", get_km_cb(tb.find_files, { hidden = true, follow = true, no_ignore = true }), "Find all")
    set("<leader>ff", get_km_cb(tb.find_files, { hidden = true, follow = true }), "Find files")

    set("<leader>fo", get_km_cb(tb.oldfiles), "Find in recent opened files")
    set("<leader>fb", get_km_cb(tb.buffers), "Search in buffers")
    set("<leader>fh", get_km_cb(tb.help_tags), "Find in help tags")
    set("<leader>fk", get_km_cb(tb.keymaps), "Show key mappings")
    set("<leader>fn", get_km_cb(tb.file_browser, { files = false, hide_parent_dir = true }), "Open file browser")
    set("<leader>fr", get_km_cb(tb.file_browser, { cwd = "~/repos" }), "Open all repos")

    set("<leader>fw", get_km_cb(telescope.extensions.live_grep_args.live_grep_args), "Live grep with args")
    --stylua: ignore
    set("<leader>fc", get_km_cb(gas.grep_word_under_cursor), "Live grep with args under cursor")
    set("<leader>fc", get_km_cb(gas.grep_visual_selection), "Live grep with args the highlighted text", { mode = "v" })

    set("<leader>gs", get_km_cb(tb.git_status), "Git status")
  end,
}
