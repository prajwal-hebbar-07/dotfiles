vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.termguicolors = true
opt.scrolloff = 8
opt.completeopt = "menu,menuone,noselect"
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	virtual_text = { source = "if_many", spacing = 2 },
})
