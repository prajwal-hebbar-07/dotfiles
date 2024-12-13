return {
	{
		"numToStr/Comment.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		config = function()
			vim.g.skip_ts_context_commentstring_module = true

			require("Comment").setup({
				mappings = {
					basic = false,
					extra = false,
				},

				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			})

			-- Enhanced keymaps for commenting
			vim.keymap.set("n", "<leader>/", function()
				require("Comment.api").toggle.linewise.current()
			end, { desc = "Toggle comment" })

			vim.keymap.set(
				"v",
				"<leader>/",
				'<ESC><cmd>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>',
				{ desc = "Toggle comment on selection" }
			)

			vim.keymap.set("n", "<leader>bc", function()
				require("Comment.api").toggle.blockwise.current()
			end, { desc = "Toggle block comment" })

			vim.keymap.set(
				"v",
				"<leader>bc",
				'<ESC><cmd>lua require("Comment.api").toggle.blockwise(vim.fn.visualmode())<CR>',
				{ desc = "Toggle block comment on selection" }
			)
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			-- Get Catppuccin colors for better integration
			local mocha = require("catppuccin.palettes").get_palette("mocha")

			require("todo-comments").setup({
				keywords = {
					FIX = {
						icon = " ", -- Bug icon
						color = "error",
						alt = { "FIXME", "BUG", "FIXIT", "ISSUE", "ERROR" },
						signs = true,
					},
					TODO = {
						icon = " ", -- Checkbox icon
						color = "todo",
						alt = { "IMPLEMENT" },
						signs = true,
					},
					HACK = {
						icon = " ", -- Tool icon
						color = "hack",
						alt = { "TEMP", "TEMPORARY", "WORKAROUND" },
						signs = true,
					},
					WARN = {
						icon = " ", -- Warning icon
						color = "warning",
						alt = { "WARNING", "CAUTION", "CAREFUL" },
						signs = true,
					},
					PERF = {
						icon = "󰅒 ", -- Lightning bolt
						color = "perf",
						alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE", "COMPLEXITY" },
						signs = true,
					},
					NOTE = {
						icon = " ", -- Memo icon
						color = "note",
						alt = { "INFO", "EXPLAIN", "DESC" },
						signs = true,
					},
					TEST = {
						icon = "⏲ ", -- Clock icon
						color = "test",
						alt = { "TESTING", "PASSED", "FAILED", "UNIT", "SPEC" },
						signs = true,
					},
					API = {
						icon = "󰘦 ", -- API icon
						color = "api",
						alt = { "ENDPOINT", "ROUTE", "HTTP", "REST" },
						signs = true,
					},
					SECURITY = {
						icon = "󰿈 ", -- Shield icon
						color = "security",
						alt = { "AUTH", "AUTHORIZATION", "AUTHENTICATION", "SECURE" },
						signs = true,
					},
					UI = {
						icon = "󰃤 ", -- Palette icon
						color = "ui",
						alt = { "STYLE", "LAYOUT", "DESIGN", "COMPONENT" },
						signs = true,
					},
					REVIEW = {
						icon = " ", -- Magnifying glass
						color = "review",
						alt = { "CHECK", "VERIFY", "VALIDATE" },
						signs = true,
					},
					STATE = {
						icon = "󰘻 ", -- Database icon
						color = "state",
						alt = { "STORE", "REDUX", "CONTEXT", "DATA" },
						signs = true,
					},
				},

				highlight = {
					multiline = true,
					multiline_pattern = "^.",
					multiline_context = 10,
					before = "",
					keyword = "wide",
					after = "fg",
					pattern = [[.*<(KEYWORDS)\s*:]],
					comments_only = true,
					max_line_len = 400,
				},

				-- Catppuccin-based color scheme
				colors = {
					error = { "DiagnosticError", "ErrorMsg", mocha.red }, -- Bright red for errors
					warning = { "DiagnosticWarn", "WarningMsg", mocha.yellow }, -- Yellow for warnings
					todo = { "Todo", mocha.blue }, -- Blue for todos
					hack = { "DiagnosticWarn", mocha.peach }, -- Peach for hacks
					perf = { "Special", mocha.teal }, -- Teal for performance
					note = { "DiagnosticInfo", mocha.lavender }, -- Lavender for notes
					test = { "Identifier", mocha.green }, -- Green for tests
					api = { "Function", mocha.sapphire }, -- Sapphire for API
					security = { "String", mocha.maroon }, -- Maroon for security
					ui = { "Character", mocha.pink }, -- Pink for UI
					review = { "Special", mocha.mauve }, -- Mauve for review
					state = { "Type", mocha.sky }, -- Sky blue for state management
				},

				-- Search configuration
				search = {
					command = "rg",
					args = {
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
					},
					pattern = [[\b(KEYWORDS):]],
				},

				gui_style = {
					fg = "NONE",
					bg = "BOLD",
				},

				-- Better merge with defaults
				merge_keywords = false,
			})

			-- Navigation keymaps
			vim.keymap.set("n", "]t", function()
				require("todo-comments").jump_next()
			end, { desc = "Next todo comment" })

			vim.keymap.set("n", "[t", function()
				require("todo-comments").jump_prev()
			end, { desc = "Previous todo comment" })

			-- Telescope integration with category-specific searches
			vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find all TODOs" })
			vim.keymap.set("n", "<leader>fb", "<cmd>TodoTelescope keywords=FIX,BUG,ERROR<cr>", { desc = "Find bugs" })
			vim.keymap.set("n", "<leader>fn", "<cmd>TodoTelescope keywords=NOTE,INFO<cr>", { desc = "Find notes" })
			vim.keymap.set("n", "<leader>fh", "<cmd>TodoTelescope keywords=HACK,TEMP<cr>", { desc = "Find hacks" })
			vim.keymap.set(
				"n",
				"<leader>fp",
				"<cmd>TodoTelescope keywords=PERF,OPTIM<cr>",
				{ desc = "Find performance notes" }
			)
			vim.keymap.set(
				"n",
				"<leader>fa",
				"<cmd>TodoTelescope keywords=API,ENDPOINT<cr>",
				{ desc = "Find API notes" }
			)
			vim.keymap.set(
				"n",
				"<leader>fs",
				"<cmd>TodoTelescope keywords=SECURITY,AUTH<cr>",
				{ desc = "Find security notes" }
			)
			vim.keymap.set(
				"n",
				"<leader>fu",
				"<cmd>TodoTelescope keywords=UI,STYLE,COMPONENT<cr>",
				{ desc = "Find UI notes" }
			)
			vim.keymap.set(
				"n",
				"<leader>fr",
				"<cmd>TodoTelescope keywords=REVIEW,CHECK<cr>",
				{ desc = "Find review notes" }
			)
			vim.keymap.set(
				"n",
				"<leader>fd",
				"<cmd>TodoTelescope keywords=STATE,STORE,DATA<cr>",
				{ desc = "Find state/data notes" }
			)
		end,
	},
}
