vim.g.mapleader = " "
vim.g.maplocalleader = " "

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end

vim.opt.rtp:prepend(lazypath)

local lazyopts = {
  git = { timeout = 300 },
  ui = { border = "rounded" },
  change_detection = { notify = false },
  checker = { enabled = true, notify = false },
}

require("lazy").setup({
  { import = "omareloui.plugins" },
  { import = "omareloui.lsp.plugins" },
}, lazyopts)

require "omareloui.config.init"
require "omareloui.lsp.init"
require "omareloui.config.theme"
