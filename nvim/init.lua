-- Set leader key before loading any plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable built-in plugins we don't need
local disabled_built_ins = {
	"netrw",
	"netrwPlugin",
	"netrwSettings",
	"netrwFileHandlers",
	"gzip",
	"zip",
	"zipPlugin",
	"tar",
	"tarPlugin",
	"getscript",
	"getscriptPlugin",
	"vimball",
	"vimballPlugin",
	"2html_plugin",
	"logipat",
	"matchit",
}

for _, plugin in pairs(disabled_built_ins) do
	vim.g["loaded_" .. plugin] = 1
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		lazyrepo,
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("options")
require("keymaps")

-- Setup lazy.nvim with configuration
require("lazy").setup("plugins", {
	defaults = {
		lazy = true,
	},
	install = {
		colorscheme = { "catppuccin" },
	},
	performance = {
		rtp = {
			disabled_plugins = disabled_built_ins,
		},
		cache = {
			enabled = true,
		},
		reset_packpath = true,
	},
	change_detection = {
		notify = false,
	},
})
