return {
	{
		"mason-org/mason.nvim",
		build = ":MasonUpdate",
		opts = {
			ui = {
				border = "rounded",
			},
		},
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"bash-language-server",
				"eslint_d",
				"json-lsp",
				"lua-language-server",
				"marksman",
				"prettierd",
				"pyright",
				"ruff",
				"shellcheck",
				"shfmt",
				"stylua",
				"typescript-language-server",
				"yaml-language-server",
			},
			auto_update = false,
			run_on_start = true,
			start_delay = 3000,
		},
	},

	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
					{ name = "buffer" },
				},
			})
		end,
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"mason-org/mason.nvim",
		},
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
				callback = function(event)
					local bufnr = event.buf

					local function nmap(lhs, rhs, desc)
						vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
					end

					nmap("gd", vim.lsp.buf.definition, "Go to definition")
					nmap("gD", vim.lsp.buf.declaration, "Go to declaration")
					nmap("gi", vim.lsp.buf.implementation, "Go to implementation")
					nmap("gr", vim.lsp.buf.references, "Go to references")
					nmap("K", vim.lsp.buf.hover, "Hover documentation")
					nmap("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
					nmap("<leader>ca", vim.lsp.buf.code_action, "Code action")
				end,
			})

			local servers = {
				bashls = {},
				jsonls = {},
				marksman = {},
				pyright = {},
				ts_ls = {},
				yamlls = {},
				lua_ls = {
					settings = {
						Lua = {
							diagnostics = {
								globals = { "vim" },
							},
							workspace = {
								checkThirdParty = false,
							},
							telemetry = {
								enable = false,
							},
						},
					},
				},
			}

			for server, config in pairs(servers) do
				config.capabilities = capabilities
				vim.lsp.config(server, config)
				vim.lsp.enable(server)
			end
		end,
	},

	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				desc = "Format file",
			},
		},
		opts = {
			format_on_save = {
				timeout_ms = 1000,
				lsp_format = "fallback",
			},
			formatters_by_ft = {
				bash = { "shfmt" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettierd", "prettier", stop_after_first = true },
				lua = { "stylua" },
				markdown = { "prettierd", "prettier", stop_after_first = true },
				python = { "ruff_format" },
				sh = { "shfmt" },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
			},
		},
	},

	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufWritePost", "InsertLeave" },
		config = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				javascript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				python = { "ruff" },
				sh = { "shellcheck" },
				typescript = { "eslint_d" },
				typescriptreact = { "eslint_d" },
			}

			vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
				group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
}
