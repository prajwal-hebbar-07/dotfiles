return {
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		{ "nvim-telescope/telescope-ui-select.nvim" },
		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		-- Add project management capability
		{ "nvim-telescope/telescope-project.nvim" },
		-- Add file browser
		{ "nvim-telescope/telescope-file-browser.nvim" },
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")
		local fb_actions = require("telescope").extensions.file_browser.actions

		telescope.setup({
			defaults = {
				file_ignore_patterns = {
					-- Common web development patterns to ignore
					"node_modules",
					"build",
					"dist",
					".git",
					".next",
					"package-lock.json",
					"yarn.lock",
					"%.lock",
					-- Python
					"__pycache__",
					".venv",
					"venv",
					-- Go
					"go.sum",
					-- Docker
					"docker-compose.*.yml",
					-- Coverage and test reports
					"coverage",
					".nyc_output",
					-- ENV files
					".env.*",
					-- Mobile development
					"ios/Pods",
					"android/app/build",
				},
				mappings = {
					i = {
						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,
						["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
						["<C-s>"] = actions.select_horizontal,
						["<C-v>"] = actions.select_vertical,
						["<C-t>"] = actions.select_tab,
						["<C-/>"] = actions.which_key, -- Show all mappings
					},
				},
				preview = {
					filesize_limit = 1, -- Don't preview files over 1MB
					timeout = 150, -- Reduce preview timeout
				},
			},
			pickers = {
				find_files = {
					hidden = true,
					-- Add common web development file types
					find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
				},
				live_grep = {
					-- Add file type specific searches
					additional_args = function(opts)
						return { "--type-add", "web:*.{js,ts,jsx,tsx,html,css,scss,vue,svelte}" }
					end,
				},
				buffers = {
					show_all_buffers = true,
					sort_mru = true,
					mappings = {
						i = {
							["<C-d>"] = actions.delete_buffer,
						},
					},
				},
			},
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
				file_browser = {
					-- File browser configuration
					hidden = true,
					respect_gitignore = true,
					mappings = {
						i = {
							["<C-c>"] = fb_actions.create,
							["<C-r>"] = fb_actions.rename,
							["<C-h>"] = fb_actions.toggle_hidden,
							["<C-x>"] = fb_actions.remove,
						},
					},
				},
				project = {
					base_dirs = {
						"~/Projects",
						"~/Work",
					},
					hidden_files = false,
				},
			},
		})

		-- Load extensions
		pcall(telescope.load_extension, "fzf")
		pcall(telescope.load_extension, "ui-select")
		pcall(telescope.load_extension, "file_browser")
		pcall(telescope.load_extension, "project")

		-- Enhanced keymaps for web development workflow
		local builtin = require("telescope.builtin")

		-- File navigation
		vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })
		vim.keymap.set("n", "<leader>fb", "<cmd>Telescope file_browser<cr>", { desc = "[F]ile [B]rowser" })
		vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "[F]ind [R]ecent files" })

		-- Project management
		vim.keymap.set("n", "<leader>fp", "<cmd>Telescope project<cr>", { desc = "[F]ind [P]roject" })

		-- Code navigation
		vim.keymap.set("n", "<leader>fs", builtin.treesitter, { desc = "[F]ind [S]ymbols" })
		vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[F]ind [D]iagnostics" })
		vim.keymap.set("n", "<leader>fr", builtin.lsp_references, { desc = "[F]ind [R]eferences" })
		vim.keymap.set("n", "<leader>fi", builtin.lsp_implementations, { desc = "[F]ind [I]mplementations" })

		-- Web development specific
		vim.keymap.set("n", "<leader>fc", function()
			builtin.find_files({
				prompt_title = "Find Components",
				search_dirs = { "components", "src/components" },
			})
		end, { desc = "[F]ind [C]omponents" })

		vim.keymap.set("n", "<leader>fp", function()
			builtin.find_files({
				prompt_title = "Find Pages",
				search_dirs = { "pages", "src/pages" },
			})
		end, { desc = "[F]ind [P]ages" })

		-- Docker/CI files search
		vim.keymap.set("n", "<leader>fk", function()
			builtin.find_files({
				prompt_title = "Find Infrastructure Files",
				search_dirs = { "kubernetes", "k8s", ".github", "docker" },
			})
		end, { desc = "[F]ind [K]ubernetes/Docker files" })

		-- Enhanced buffer management
		local buffer_searcher = function()
			builtin.buffers({
				sort_mru = true,
				ignore_current_buffer = true,
				previewer = false,
			})
		end

		vim.keymap.set("n", "<leader><leader>", buffer_searcher, { desc = "Find buffers" })
	end,
}
