vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.netrw_banner = 0

local opt = vim.opt

opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.mouse = "a"
opt.clipboard:append("unnamedplus")

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = false
opt.wrap = false

opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undodir"

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.inccommand = "split"

opt.splitright = true
opt.splitbelow = true
opt.updatetime = 100
opt.timeoutlen = 400
opt.colorcolumn = "0"
opt.guicursor = ""
opt.isfname:append("@-@")

opt.foldenable = true
opt.foldmethod = "manual"
opt.foldlevel = 99
opt.foldcolumn = "0"
