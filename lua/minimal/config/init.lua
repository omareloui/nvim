local HOME = os.getenv "HOME"
local undodir = nil

if HOME ~= nil then
  undodir = HOME .. "/.cache/nvim/undodir"
end

vim.g.have_nerd_font = true

vim.o.swapfile = false
vim.opt.colorcolumn = { "80", "120" }
vim.o.cursorcolumn = false
vim.o.cursorline = true

vim.o.foldcolumn = "0"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.opt.fillchars = { eob = " ", foldopen = "", foldclose = "" }

vim.o.hlsearch = true
vim.o.linebreak = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", lead = "·", trail = "·", eol = "↲", nbsp = "☠" }
vim.o.relativenumber = true
vim.o.scrolloff = 4
vim.o.sidescrolloff = 4
vim.o.spell = false
vim.opt.spelllang = { "en_us", "es" }
vim.o.spelloptions = "camel"
vim.o.undodir = undodir
vim.o.wrap = false
vim.o.laststatus = 2
vim.o.showmode = false
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.smartindent = true
vim.o.softtabstop = 2
vim.o.tabstop = 2
vim.o.ignorecase = true
vim.o.mouse = "a"
vim.o.smartcase = true
vim.o.number = true
vim.o.numberwidth = 2
vim.o.ruler = false
vim.o.signcolumn = "yes"
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.termguicolors = true
vim.o.undofile = true
vim.o.timeoutlen = 300
vim.o.updatetime = 200
vim.o.diffopt = "vertical"
vim.o.cmdheight = 1
vim.o.winborder = "rounded"

-- considers "-" as a part of a word.
vim.opt.iskeyword:append "-"

-- stop continuous comments
vim.api.nvim_create_autocmd("FileType", { command = "set formatoptions-=cro" })

--- Global keybindings ---

local set = require("common.keymap").set

set("<leader>so", "<cmd>up | so %<cr>", "Save and source current file")
set("<leader>w", "<cmd>write<cr>", "Save file")
set("<esc>", "<cmd>noh<cr>", "Clear search highlights", { silent = true })

set("k", "v:count == 0 ? 'gk' : 'k'", "Move up", { expr = true, silent = true, mode = { "n", "x" } })
set("j", "v:count == 0 ? 'gj' : 'j'", "Move down", { expr = true, silent = true, mode = { "n", "x" } })

set("<", "<gv", "Indent line backwards", { mode = "v" })
set(">", ">gv", "Indent line forwards", { mode = "v" })

set("<leader>y", '"+y', "Yank to the system clipboard", { remap = true, mode = { "n", "v" } })
set("<leader>Y", '"+Y', "Yank to the system clipboard", { remap = true })
set("<leader>p", '"+p', "Paste from the system clipboard", { remap = true, mode = { "n", "v" } })
set("<leader>P", '"+P', "Paste from the system clipboard", { remap = true })
set("p", 'p:let @"=@0<CR>', "Paste and keep the registry", { silent = true, remap = true, mode = { "v", "x" } })

set("<C-d>", "<C-d>zz", "Move down half a page")
set("<C-u>", "<C-u>zz", "Move up half a page")
set("n", "nzzzv", "Find next")
set("N", "Nzzzv", "Find previous")

set("<leader>su", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>", "Replace current word")

set("<leader>cz", "1z=", "Select the first spelling suggestion", { mode = { "n", "v" } })

set("<Esc><Esc>", "<C-\\><C-n>", "Exit terminal mode", { mode = "t" })

--- Global autocommands ---

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank { timeout = 50 }
  end,
})

-- Close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("close_with_q", { clear = true }),
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "query",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    local set = require("common.keymap").set
    set("q", "<cmd>close<cr>", "Close window", { buffer = event.buf, silent = true })
  end,
})

-- Wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("wrap_spell", { clear = true }),
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = vim.api.nvim_create_augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    if event.match:match "^%w%w+://" then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
