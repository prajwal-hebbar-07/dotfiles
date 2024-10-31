return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			flavour = "mocha",
			transparent_background = true,
		})
		vim.cmd.colorscheme("catppuccin")
	end,
}
-- return {
-- 	"ellisonleao/gruvbox.nvim",
-- 	priority = 1000,
-- 	name = "gruvbox",
-- 	config = function()
-- 		vim.cmd.colorscheme("gruvbox")
-- 	end,
-- }
-- return {
-- 	"rebelot/kanagawa.nvim",
-- 	priority = 1000,
-- 	config = function()
-- 		require("kanagawa").setup({
-- 			transparent = true,
-- 		})
-- 		vim.cmd.colorscheme("kanagawa-wave")
-- 	end,
-- }
-- return {
-- 	"EdenEast/nightfox.nvim",
-- 	priority = 1000,
-- 	config = function()
-- 		vim.cmd.colorscheme("terafox")
-- 	end,
-- }
-- return {
-- 	"craftzdog/solarized-osaka.nvim",
-- 	priority = 1000,
-- 	config = function()
-- 		vim.cmd.colorscheme("solarized-osaka")
-- 	end,
-- }
