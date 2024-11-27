vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- line numbers
opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- mouse mode
opt.mouse = "a"

-- line highlight
opt.cursorline = false

-- clipboard
opt.clipboard:append("unnamedplus")

-- search settings
opt.ignorecase = true
opt.smartcase = true

-- backspace setting
opt.backspace = "indent,eol,start"

