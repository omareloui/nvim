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

      local _repeat = require "nvim-treesitter-textobjects.repeatable_move" ---@type table<string,fun(...)>
      local move = require "nvim-treesitter-textobjects.move" ---@type table<string,fun(...)>
      local select = require "nvim-treesitter-textobjects.select" ---@type table<string,fun(...)>

      local set = require("common.keymap").set

      local km_opts = { mode = { "n", "x", "o" } }
      local hg_km_opts = { mode = { "x", "o" } }

      local function cb(fn, arg1, arg2)
        return function()
          return fn(arg1, arg2)
        end
      end

      --stylua: ignore start
      -- Repeatable Move Keymaps
      set(";", _repeat.repeat_last_move, "repeat last move", km_opts)
      set(",", _repeat.repeat_last_move_opposite, "repeat last move oppsite direction", km_opts)

      set("f", _repeat.builtin_f_expr, "repeat move on ; and ,", { expr = true, mode = km_opts.mode })
      set("F", _repeat.builtin_F_expr, "repeat move on ; and ,", { expr = true, mode = km_opts.mode })
      set("t", _repeat.builtin_t_expr, "repeat move on ; and ,", { expr = true, mode = km_opts.mode })
      set("T", _repeat.builtin_T_expr, "repeat move on ; and ,", { expr = true, mode = km_opts.mode })

      -- Move Keymaps
      set("]f", cb(move.goto_next_start, "@function.outer", "textobjects"), "go to the start of the next function", km_opts)
      set("]F", cb(move.goto_next_end, "@function.outer", "textobjects"), "go to the end of the function", km_opts)
      set("[f", cb(move.goto_previous_start, "@function.outer", "textobjects"), "go to the start of the previous function", km_opts)
      set("[F", cb(move.goto_previous_end, "@function.outer", "textobjects"), "go to the start of the function", km_opts)

      set("]c", cb(move.goto_next_start, "@class.outer", "textobjects"), "go to the start of the next class", km_opts)
      set("]C", cb(move.goto_next_end, "@class.outer", "textobjects"), "go to the end of the class", km_opts)
      set("[c", cb(move.goto_previous_start, "@class.outer", "textobjects"), "go to the start of the previous class", km_opts)
      set("[C", cb(move.goto_previous_end, "@class.outer", "textobjects"), "go to the start of the class", km_opts)

      -- Select Keymaps
      set("af", cb(select.select_textobject, "@function.outer", "textobjects"), "select outer part of a function", hg_km_opts)
      set("if", cb(select.select_textobject, "@function.inner", "textobjects"), "select inner part of a function", hg_km_opts)
      set("ac", cb(select.select_textobject, "@class.outer", "textobjects"), "select outer part of a class", hg_km_opts)
      set("ic", cb(select.select_textobject, "@class.inner", "textobjects"), "select inner part of a class", hg_km_opts)
      set("al", cb(select.select_textobject, "@loop.outer", "textobjects"), "select outer part of a loop", hg_km_opts)
      set("il", cb(select.select_textobject, "@loop.inner", "textobjects"), "select inner part of a loop", hg_km_opts)
      set("ai", cb(select.select_textobject, "@conditional.outer", "textobjects"), "select outer part of a conditional", hg_km_opts)
      set("ii", cb(select.select_textobject, "@conditional.inner", "textobjects"), "select inner part of a conditional", hg_km_opts)
      set("ab", cb(select.select_textobject, "@block.outer", "textobjects"), "select outer part of a block", hg_km_opts)
      set("ib", cb(select.select_textobject, "@block.inner", "textobjects"), "select inner part of a block", hg_km_opts)
      set("ar", cb(select.select_textobject, "@parameter.outer", "textobjects"), "select outer part of a parameter", hg_km_opts)
      set("ir", cb(select.select_textobject, "@parameter.inner", "textobjects"), "select inner part of a parameter", hg_km_opts)
      --stylua: ignore end

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
