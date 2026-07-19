-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- (LazyVim already sets number, relativenumber, clipboard, ignorecase, wrap=false,
--  expandtab, etc. — only overrides and extras live here.)

local opt = vim.opt

opt.numberwidth = 4
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.confirm = true
opt.autoread = true

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.smartindent = false

opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.fn.mkdir(opt.undodir:get()[1], "p")

opt.inccommand = "split"
opt.splitkeep = "screen"
opt.updatetime = 100
opt.timeoutlen = 400
opt.pumheight = 10
opt.guicursor = ""
opt.isfname:append("@-@")
opt.virtualedit = "block"
opt.list = true
opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}

opt.showtabline = 1
opt.winborder = "rounded"

opt.foldmethod = "manual"
opt.foldlevel = 99

opt.diffopt:append({ "algorithm:histogram", "linematch:60" })
opt.shortmess:append("I")
