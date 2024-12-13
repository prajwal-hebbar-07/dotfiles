return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		-- Get colors from your catppuccin theme
		local colors = require("catppuccin.palettes").get_palette("mocha")

		require("neo-tree").setup({
			close_if_last_window = true,
			enable_git_status = true,
			enable_diagnostics = true,

			filesystem = {
				follow_current_file = {
					enabled = true,
					leave_dirs_open = true,
				},
				use_libuv_file_watcher = true,
				filtered_items = {
					visible = false,
					hide_dotfiles = false,
					hide_gitignored = false,
					hide_by_pattern = {
						"node_modules",
						".git",
						".next",
						"dist",
						"build",
						".DS_Store",
						"__pycache__",
					},
					never_show = {
						".DS_Store",
						"thumbs.db",
					},
				},
				commands = {
					-- Add custom commands for web development
					copy_selector = function(state)
						local node = state.tree:get_node()
						local filepath = node:get_id()
						local filename = node.name
						local modify = vim.fn.fnamemodify

						local results = {
							e = { val = modify(filename, ":e"), msg = "Extension only" },
							f = { val = filename, msg = "Filename" },
							h = { val = modify(filename, ":~"), msg = "Path relative to Home" },
							p = { val = modify(filename, ":."), msg = "Path relative to CWD" },
							P = { val = filepath, msg = "Absolute path" },
						}

						vim.ui.select({
							"Absolute path",
							"Path relative to CWD",
							"Path relative to Home",
							"Filename",
							"Extension only",
						}, {
							prompt = "Choose type of path to copy",
						}, function(choice)
							if choice then
								local i = string.sub(
									"PphfE",
									vim.fn.match(choice, "\\c\\v^\\w+") + 1,
									vim.fn.match(choice, "\\c\\v^\\w+") + 1
								)
								local result = results[string.lower(i)]
								vim.fn.setreg("+", result.val)
								vim.notify("Copied: " .. result.val)
							end
						end)
					end,
				},
			},

			window = {
				width = 35,
				mappings = {
					["<space>"] = "none",
					["P"] = "copy_selector",
					["l"] = "open",
					["h"] = "close_node",
				},
				position = "left",
			},

			default_component_configs = {
				indent = {
					with_markers = true,
					with_expanders = true,
				},
				modified = {
					symbol = "●",
					highlight = "NeoTreeModified",
				},
				git_status = {
					symbols = {
						-- Change symbols to match your preferred ones
						added = "✚",
						modified = "",
						deleted = "✖",
						renamed = "󰁕",
						untracked = "",
						ignored = "",
						unstaged = "󰄱",
						staged = "",
						conflict = "",
					},
				},
				icon = {
					folder_closed = "",
					folder_open = "",
					folder_empty = "",
					folder_empty_open = "",
				},
			},
		})

		-- Enhanced keymaps
		vim.keymap.set("n", "\\", "<cmd>Neotree toggle<CR>", { desc = "Toggle file explorer" })
		vim.keymap.set("n", "<leader>e", "<cmd>Neotree focus<CR>", { desc = "Focus file explorer" })
		vim.keymap.set(
			"n",
			"<leader>ef",
			"<cmd>Neotree filesystem reveal left<CR>",
			{ desc = "Reveal file in explorer" }
		)
	end,
}
