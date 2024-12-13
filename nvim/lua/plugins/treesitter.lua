return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"windwp/nvim-ts-autotag", -- Auto close/rename HTML/JSX tags
			"nvim-treesitter/nvim-treesitter-textobjects",
			"JoosepAlviste/nvim-ts-context-commentstring", -- Better JSX commenting
			"windwp/nvim-autopairs", -- Auto pair brackets
		},
		config = function()
			-- Auto-install missing parsers
			require("nvim-treesitter.install").prefer_git = true
			local config = require("nvim-treesitter.configs")

			config.setup({
				auto_install = true,

				-- Enhanced syntax highlighting
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
					-- Disable slow treesitter highlight for large files
					disable = function(_, buf)
						local max_filesize = 100 * 1024 -- 100 KB
						local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
						if ok and stats and stats.size > max_filesize then
							return true
						end
					end,
				},

				-- Indentation based on treesitter
				indent = {
					enable = true,
					-- Disable indentation for certain languages where it might be problematic
					disable = { "python", "yaml" },
				},

				-- Auto-close and auto-rename tags
				autotag = {
					enable = true,
					enable_rename = true,
					enable_close = true,
					enable_close_on_slash = true,
					filetypes = {
						"html",
						"xml",
						"javascript",
						"javascriptreact",
						"typescript",
						"typescriptreact",
						"svelte",
						"vue",
						"tsx",
						"jsx",
						"markdown",
						"mdx",
					},
				},

				-- Enhanced text objects and movements
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							-- You can use the capture groups defined in textobjects.scm
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
							["ai"] = "@conditional.outer",
							["ii"] = "@conditional.inner",
							["al"] = "@loop.outer",
							["il"] = "@loop.inner",
							["ab"] = "@block.outer",
							["ib"] = "@block.inner",
							["ar"] = "@parameter.outer",
							["ir"] = "@parameter.inner",
							["at"] = "@comment.outer",
						},
						selection_modes = {
							["@parameter.outer"] = "v", -- charwise
							["@function.outer"] = "V", -- linewise
							["@class.outer"] = "<c-v>", -- blockwise
						},
					},

					-- Move between text objects
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = {
							["]f"] = "@function.outer",
							["]c"] = "@class.outer",
							["]i"] = "@conditional.outer",
							["]l"] = "@loop.outer",
							["]s"] = "@statement.outer",
							["]z"] = "@fold",
							["]a"] = "@parameter.inner",
						},
						goto_next_end = {
							["]F"] = "@function.outer",
							["]C"] = "@class.outer",
						},
						goto_previous_start = {
							["[f"] = "@function.outer",
							["[c"] = "@class.outer",
							["[i"] = "@conditional.outer",
							["[l"] = "@loop.outer",
							["[s"] = "@statement.outer",
							["[z"] = "@fold",
							["[a"] = "@parameter.inner",
						},
						goto_previous_end = {
							["[F"] = "@function.outer",
							["[C"] = "@class.outer",
						},
					},

					-- Swap text objects
					swap = {
						enable = true,
						swap_next = {
							["<leader>a"] = "@parameter.inner",
							["<leader>f"] = "@function.outer",
							["<leader>e"] = "@element",
						},
						swap_previous = {
							["<leader>A"] = "@parameter.inner",
							["<leader>F"] = "@function.outer",
							["<leader>E"] = "@element",
						},
					},
				},

				-- Language Parser Installation
				ensure_installed = {
					-- Web Development
					"javascript",
					"typescript",
					"tsx",
					"html",
					"css",
					"scss",
					"json",
					"jsonc",
					"vue",
					"svelte",
					"graphql",
					"prisma",

					-- React & Next.js specific
					"jsx",
					"regex",
					"jsdoc",

					-- Mobile Development
					"swift",
					"kotlin",

					-- Backend
					"python",
					"go",
					"gomod",
					"gowork",
					"gosum",

					-- DevOps & Configuration
					"dockerfile",
					"yaml",
					"toml",
					"bash",
					"fish",

					-- Git
					"git_rebase",
					"gitcommit",
					"gitignore",

					-- Documentation
					"markdown",
					"markdown_inline",

					-- Ethereum/Web3
					"solidity",

					-- Configuration
					"vim",
					"query",
					"lua",
				},

				-- Incremental selection based on named nodes
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = "<nop>",
						node_decremental = "<bs>",
					},
				},
			})

			-- Set folds based on treesitter
			vim.opt.foldmethod = "expr"
			vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
			-- Start with all folds open
			vim.opt.foldenable = false
			vim.opt.foldlevel = 99

			-- Better folding text
			vim.opt.foldtext = [[substitute(getline(v:foldstart),'\\t','  ','g').'...'.trim(getline(v:foldend))]]

			-- Setup context-based commenting
			require("nvim-treesitter.configs").setup({
				context_commentstring = {
					enable = true,
					enable_autocmd = false,
				},
			})

			-- Setup autopairs with treesitter support
			require("nvim-autopairs").setup({
				check_ts = true,
				ts_config = {
					lua = { "string" },
					javascript = { "template_string" },
					java = false,
				},
			})
		end,
	},
}
