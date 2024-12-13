return {
	{
		"tpope/vim-sleuth",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			-- Enhanced sleuth configuration
			vim.g.sleuth_automatic = 1
			vim.g.sleuth_neighbor_limit = 5

			-- File type specific indentation
			local indent_configs = {
				-- Web Development
				javascript = { sw = 2, expandtab = true },
				typescript = { sw = 2, expandtab = true },
				javascriptreact = { sw = 2, expandtab = true },
				typescriptreact = { sw = 2, expandtab = true },
				html = { sw = 2, expandtab = true },
				css = { sw = 2, expandtab = true },
				json = { sw = 2, expandtab = true },

				-- Backend
				python = { sw = 4, expandtab = true },
				go = { sw = 4, expandtab = false }, -- Go uses tabs

				-- Configuration files
				yaml = { sw = 2, expandtab = true },
				dockerfile = { sw = 2, expandtab = true },

				-- Others
				lua = { sw = 2, expandtab = true },
				markdown = { sw = 2, expandtab = true },
			}

			-- Apply file type specific configurations
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "*",
				callback = function()
					local ft = vim.bo.filetype
					local config = indent_configs[ft]
					if config then
						vim.bo.shiftwidth = config.sw
						vim.bo.expandtab = config.expandtab
					end
				end,
			})
		end,
	},
	{
		"shellRaining/hlchunk.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("hlchunk").setup({
				chunk = {
					enable = true,
					notify = false,
					support_filetypes = {
						-- Web Development
						"typescript",
						"javascript",
						"javascriptreact",
						"typescriptreact",
						"html",
						"css",
						"json",
						-- Backend
						"python",
						"go",
						-- Configuration
						"yaml",
						"dockerfile",
						-- Others
						"lua",
						"markdown",
						"*", -- fallback for all other filetypes
					},
					chars = {
						horizontal_line = "─",
						vertical_line = "│",
						left_top = "╭",
						left_bottom = "╰",
						right_arrow = ">",
					},
					style = {
						{ fg = "#806d9c" }, -- indent line
						{ fg = "#806d9c" }, -- indent connector
					},
				},
				indent = {
					enable = true,
					use_treesitter = true,
					chars = { "│" },
					style = {
						{ fg = "#3b3b3b" },
					},
				},
				line_num = {
					enable = true,
					use_treesitter = true,
					style = "#806d9c",
				},
				blank = {
					enable = true,
					chars = { "․" },
					style = {
						vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui"),
					},
				},
			})

			-- Add indent guides for specific web development patterns
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"javascript",
					"typescript",
					"javascriptreact",
					"typescriptreact",
					"html",
					"css",
				},
				callback = function()
					-- Enhanced indent highlighting for JSX/TSX
					vim.opt_local.indentexpr = "nvim_treesitter#indent()"
				end,
			})
		end,
	},
}
