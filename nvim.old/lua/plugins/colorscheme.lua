-- return {
-- 	"catppuccin/nvim",
-- 	name = "catppuccin",
-- 	priority = 1000,
-- 	config = function()
-- 		require("catppuccin").setup({
-- 			flavour = "mocha",
-- 			transparent_background = true,
-- 		})
-- 		vim.cmd.colorscheme("catppuccin")
-- 	end,
-- }
-- return {
-- 	"ellisonleao/gruvbox.nvim",
-- 	priority = 1000,
-- 	name = "gruvbox",
-- 	config = function()
-- 		require("gruvbox").setup({
-- 			transparent = true,
-- 		})
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
-- 		require("nightfox").setup({
-- 			options = {
-- 				transparent = true,
-- 			},
-- 		})
-- 		vim.cmd.colorscheme("carbonfox")
-- 	end,
-- }
-- return {
-- 	"craftzdog/solarized-osaka.nvim",
-- 	priority = 1000,
-- 	config = function()
-- 		require("solarized-osaka").setup({
-- 			transparent = true,
-- 		})
-- 		vim.cmd.colorscheme("solarized-osaka")
-- 	end,
-- }
return {
	"folke/tokyonight.nvim",
	priority = 1000,
	config = function()
		require("tokyonight").setup({
			transparent = true,
		})
		vim.cmd.colorscheme("tokyonight-night")
	end,
}
