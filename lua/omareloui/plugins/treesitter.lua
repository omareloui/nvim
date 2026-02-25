return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    version = "main",

    init = function(plugin)
      require("lazy.core.loader").add_to_rtp(plugin)
    end,

    dependencies = {
      {
        "HiPhish/rainbow-delimiters.nvim",
        config = function()
          require("rainbow-delimiters.setup").setup {}
        end,
      },
    },

    config = function()
      local ts = require "nvim-treesitter"

      ts.setup {
        install_dir = vim.fn.stdpath "data" .. "/site",
      }

      local langs = {
        "angular",
        "astro",
        "bash",
        "diff",
        "dockerfile",
        "eex",
        "elixir",
        "heex",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "json5",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "prisma",
        "python",
        "query",
        "regex",
        "ron",
        "rust",
        "scss",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "vue",
        "yaml",
      }

      ts.install(langs)

      for _, lang in ipairs(langs) do
        vim.api.nvim_create_autocmd("FileType", {
          pattern = lang,
          callback = function()
            vim.treesitter.start(nil, lang)
          end,
        })
      end

      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        pattern = { "*.component.html", "*.container.html" },
        callback = function()
          vim.treesitter.start(nil, "angular")
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",

    branch = "main",

    init = function()
      vim.g.no_plugin_maps = true
    end,

    config = function()
      local tsto = require "nvim-treesitter-textobjects"

      local opts = {
        select = {
          lookahead = true,
        },
        move = {
          set_jumb = false,
        },
      }

      local repeat_move = require "nvim-treesitter-textobjects.repeatable_move" ---@type table<string,fun(...)>
      local move = require "nvim-treesitter-textobjects.move" ---@type table<string,fun(...)>
      local select = require "nvim-treesitter-textobjects.select" ---@type table<string,fun(...)>

      -- Repeat Keymaps
      vim.keymap.set({ "n", "x", "o" }, ";", repeat_move.repeat_last_move)
      vim.keymap.set({ "n", "x", "o" }, ",", repeat_move.repeat_last_move_opposite)

      -- Move Keymaps
      vim.keymap.set({ "n", "x", "o" }, "]f", function()
        move.goto_next_start("@function.outer", "textobjects")
      end, { desc = "go to the start of the next function" })
      vim.keymap.set({ "n", "x", "o" }, "]F", function()
        move.goto_next_end("@function.outer", "textobjects")
      end, { desc = "go to the end of the function" })
      vim.keymap.set({ "n", "x", "o" }, "[f", function()
        move.goto_previous_start("@function.outer", "textobjects")
      end, { desc = "go to the start of the previous function" })
      vim.keymap.set({ "n", "x", "o" }, "[F", function()
        move.goto_previous_end("@function.outer", "textobjects")
      end, { desc = "go to the start of the function" })

      vim.keymap.set({ "n", "x", "o" }, "]c", function()
        move.goto_next_start("@class.outer", "textobjects")
      end, { desc = "go to the start of the next class" })
      vim.keymap.set({ "n", "x", "o" }, "]C", function()
        move.goto_next_end("@class.outer", "textobjects")
      end, { desc = "go to the end of the class" })
      vim.keymap.set({ "n", "x", "o" }, "[c", function()
        move.goto_previous_start("@class.outer", "textobjects")
      end, { desc = "go to the start of the previous class" })
      vim.keymap.set({ "n", "x", "o" }, "[C", function()
        move.goto_previous_end("@class.outer", "textobjects")
      end, { desc = "go to the start of the class" })

      -- Select Keymaps
      vim.keymap.set({ "x", "o" }, "af", function()
        select.select_textobject("@function.outer", "textobjects")
      end, { desc = "select outer part of a function" })
      vim.keymap.set({ "x", "o" }, "if", function()
        select.select_textobject("@function.inner", "textobjects")
      end, { desc = "select inner part of a function" })

      vim.keymap.set({ "x", "o" }, "ac", function()
        select.select_textobject("@class.outer", "textobjects")
      end, { desc = "select outer part of a class" })
      vim.keymap.set({ "x", "o" }, "ic", function()
        select.select_textobject("@class.inner", "textobjects")
      end, { desc = "select inner part of a class" })

      vim.keymap.set({ "x", "o" }, "al", function()
        select.select_textobject("@loop.outer", "textobjects")
      end, { desc = "select outer part of a loop" })
      vim.keymap.set({ "x", "o" }, "il", function()
        select.select_textobject("@loop.inner", "textobjects")
      end, { desc = "select inner part of a loop" })

      vim.keymap.set({ "x", "o" }, "ai", function()
        select.select_textobject("@conditional.outer", "textobjects")
      end, { desc = "select outer part of a conditional" })
      vim.keymap.set({ "x", "o" }, "ii", function()
        select.select_textobject("@conditional.inner", "textobjects")
      end, { desc = "select inner part of a conditional" })

      vim.keymap.set({ "x", "o" }, "ab", function()
        select.select_textobject("@block.outer", "textobjects")
      end, { desc = "select outer part of a block" })
      vim.keymap.set({ "x", "o" }, "ib", function()
        select.select_textobject("@block.inner", "textobjects")
      end, { desc = "select inner part of a block" })

      vim.keymap.set({ "x", "o" }, "ar", function()
        select.select_textobject("@parameter.outer", "textobjects")
      end, { desc = "select outer part of a parameter" })
      vim.keymap.set({ "x", "o" }, "ir", function()
        select.select_textobject("@parameter.inner", "textobjects")
      end, { desc = "select inner part of a parameter" })

      tsto.setup(opts)
    end,
  },

  -- Show context of the current function
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    opts = { mode = "cursor", max_lines = 3 },
  },

  -- Automatically add closing tags for HTML and JSX
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
    },
  },
}
