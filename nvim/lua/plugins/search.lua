return {
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = "FzfLua",
		keys = {
			{ "<leader>ff", "<cmd>FzfLua files<CR>", desc = "Find files" },
			{ "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "Search text" },
			{ "<leader>fb", "<cmd>FzfLua buffers<CR>", desc = "Find buffers" },
			{ "<leader>fr", "<cmd>FzfLua oldfiles<CR>", desc = "Recent files" },
			{ "<leader>fh", "<cmd>FzfLua help_tags<CR>", desc = "Help tags" },
			{ "<leader>/", "<cmd>FzfLua blines<CR>", desc = "Search current buffer" },
		},
		opts = {
			winopts = {
				height = 0.85,
				width = 0.9,
				preview = {
					layout = "horizontal",
					horizontal = "right:55%",
				},
			},
			fzf_opts = {
				["--layout"] = "reverse",
			},
			files = {
				fd_opts = "--color=never --type f --hidden --follow --exclude .git",
			},
			grep = {
				rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git'",
			},
		},
	},
}
