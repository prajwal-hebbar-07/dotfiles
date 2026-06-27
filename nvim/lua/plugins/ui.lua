return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				integrations = {
					cmp = true,
					fzf = true,
					native_lsp = { enabled = true },
					nvimtree = true,
					treesitter = true,
					which_key = true,
				},
			})

			vim.cmd.colorscheme("catppuccin")
		end,
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "modern",
			delay = 300,
		},
	},

	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
	},

	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle explorer" },
			{ "<leader>E", "<cmd>NvimTreeFindFile<CR>", desc = "Reveal current file" },
		},
		opts = {
			hijack_cursor = true,
			sync_root_with_cwd = true,
			update_focused_file = {
				enable = true,
				update_root = true,
			},
			view = {
				width = 34,
			},
			renderer = {
				group_empty = true,
				highlight_git = true,
				indent_markers = {
					enable = true,
				},
			},
			filters = {
				dotfiles = false,
			},
		},
	},
}
