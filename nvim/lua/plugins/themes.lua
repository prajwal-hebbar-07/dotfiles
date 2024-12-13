return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				-- Main Configuration
				flavour = "mocha",
				background = { light = "latte", dark = "mocha" },
				transparent_background = false,
				show_end_of_buffer = false,
				dim_inactive = {
					enabled = false,
					shade = "dark",
					percentage = 0.15,
				},

				-- Better syntax highlighting integrations
				integrations = {
					cmp = true,
					treesitter = true,
					telescope = {
						enabled = true,
						style = "nvchad",
					},
					mason = true,
					native_lsp = {
						enabled = true,
						virtual_text = {
							errors = { "italic" },
							hints = { "italic" },
							warnings = { "italic" },
							information = { "italic" },
						},
						underlines = {
							errors = { "underline" },
							hints = { "underline" },
							warnings = { "underline" },
							information = { "underline" },
						},
						inlay_hints = {
							background = true,
						},
					},
					indent_blankline = {
						enabled = true,
						colored_indent_levels = true,
					},
					noice = true,
					notify = true,
					neotree = true,
					dap = {
						enabled = true,
						enable_ui = true,
					},

					-- Git integration
					gitsigns = true,
					gitgutter = true,

					-- Special integrations for web development
					semantic_tokens = true,
					ts_rainbow2 = true, -- For better bracket pair colorization
				},

				-- Custom color assignments
				custom_highlights = {
					-- Improve React/JSX visibility
					["@tag"] = { fg = "#89b4fa" }, -- Brighter JSX tags
					["@tag.delimiter"] = { fg = "#94e2d5" }, -- Distinct JSX brackets
					["@constructor"] = { fg = "#f5c2e7" }, -- React components

					-- Better TypeScript highlighting
					["@type"] = { fg = "#89b4fa" }, -- Type annotations
					["@type.builtin"] = { fg = "#f38ba8" }, -- Built-in types
					["@property"] = { fg = "#a6e3a1" }, -- Object properties

					-- Enhanced Python readability
					["@function.builtin.python"] = { fg = "#f5c2e7" },
					["@type.python"] = { fg = "#89b4fa" },

					-- Better Go syntax
					["@function.go"] = { fg = "#89b4fa" },
					["@type.go"] = { fg = "#f5c2e7" },

					-- Enhanced Docker syntax
					["@keyword.dockerfile"] = { fg = "#f38ba8", style = { "bold" } },
					["@parameter.dockerfile"] = { fg = "#a6e3a1" },
				},

				-- Color palette overrides
				color_overrides = {
					mocha = {
						-- Adjusted base colors for better contrast
						base = "#1e1e2e",
						mantle = "#181825",
						crust = "#11111b",

						-- Enhanced syntax colors
						text = "#cdd6f4",
						subtext1 = "#bac2de",
						subtext0 = "#a6adc8",
						overlay2 = "#9399b2",
						overlay1 = "#7f849c",
						overlay0 = "#6c7086",
						surface2 = "#585b70",
						surface1 = "#45475a",
						surface0 = "#313244",

						-- Brighter accents for better visibility
						blue = "#89b4fa",
						lavender = "#b4befe",
						sapphire = "#74c7ec",
						sky = "#89dceb",
						teal = "#94e2d5",
						green = "#a6e3a1",
						yellow = "#f9e2af",
						peach = "#fab387",
						maroon = "#eba0ac",
						red = "#f38ba8",
						mauve = "#cba6f7",
						pink = "#f5c2e7",
						flamingo = "#f2cdcd",
						rosewater = "#f5e0dc",
					},
				},

				-- Compilation and styles
				compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
				styles = {
					comments = { "italic" },
					conditionals = { "italic" },
					loops = {},
					functions = {},
					keywords = { "bold" },
					strings = {},
					variables = {},
					numbers = {},
					booleans = { "bold" },
					properties = {},
					types = { "bold" },
					operators = {},
				},
			})

			-- Set the colorscheme
			vim.cmd.colorscheme("catppuccin")

			-- Additional theme-related settings
			vim.opt.termguicolors = true

			-- Set unified background for better readability
			vim.api.nvim_set_hl(0, "Normal", { bg = "#1e1e2e" })
			vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1e1e2e" })

			-- Better line number contrast
			vim.api.nvim_set_hl(0, "LineNr", { fg = "#6c7086", bold = true })
			vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#cba6f7", bold = true })
		end,
	},
}
