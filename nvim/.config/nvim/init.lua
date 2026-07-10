-- Define leaders before loading plugins so every mapping uses the same prefix.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("hebbar.core")
require("hebbar.lazy")
