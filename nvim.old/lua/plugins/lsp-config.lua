return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"cssls",
					"tailwindcss",
					"dockerls",
					"emmet_ls",
					"html",
					"eslint",
					"ts_ls",
					"jsonls",
					"marksman",
				},
				automatic_installation = true,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local lspconfig = require("lspconfig")

			lspconfig.lua_ls.setup({
				capabilities = capabilities,
			})

			lspconfig.cssls.setup({
				capabilities = capabilities,
			})

			lspconfig.tailwindcss.setup({
				capabilities = capabilities,
			})

			lspconfig.dockerls.setup({
				capabilities = capabilities,
			})

			lspconfig.emmet_ls.setup({
				capabilities = capabilities,
			})

			lspconfig.html.setup({
				capabilities = capabilities,
			})

			lspconfig.eslint.setup({
				capabilities = capabilities,
			})

			lspconfig.ts_ls.setup({
				capabilities = capabilities,
			})

			lspconfig.jsonls.setup({
				capabilities = capabilities,
			})

			lspconfig.marksman.setup({
				capabilities = capabilities,
			})

			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "<leader>gD", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
			vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", {})
			vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", {})
			vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", {})
			vim.keymap.set("n", "<leader>dd", "<cmd>Telescope diagnostics bufnr=0<CR>", {})
			vim.keymap.set("n", "<leader>dv", vim.diagnostic.open_float, {})
		end,
	},
}
