return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>fm",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			mode = "",
			desc = "Format buffer",
		},
	},
	opts = {
		-- Define formatters
		formatters_by_ft = {
			-- Frontend
			javascript = { "prettier", "eslint_d" },
			typescript = { "prettier", "eslint_d" },
			javascriptreact = { "prettier", "eslint_d" },
			typescriptreact = { "prettier", "eslint_d" },
			svelte = { "prettier", "eslint_d" },
			vue = { "prettier", "eslint_d" },
			html = { "prettier" },
			css = { "prettier" },
			scss = { "prettier" },
			less = { "prettier" },
			json = { "prettier" },
			jsonc = { "prettier" },
			yaml = { "yamlfmt" },

			-- Backend
			python = { "isort", "black" },
			go = { "gofmt", "goimports" },

			-- Configuration & Documentation
			markdown = { "prettier" },
			lua = { "stylua" },
			dockerfile = { "hadolint" },

			-- Fallback
			["*"] = { "trim_whitespace", "trim_newlines" },
		},

		format_on_save = function(bufnr)
			-- Disable autoformat for files in certain directories
			local bufname = vim.api.nvim_buf_get_name(bufnr)
			if bufname:match("/node_modules/") or bufname:match("/.git/") then
				return
			end

			return {
				timeout_ms = 500,
				lsp_fallback = true,
				async = false,
			}
		end,

		-- Formatter-specific configuration
		formatters = {
			prettier = {
				prepend_args = { "--config-precedence", "prefer-file" },
			},
			eslint_d = {
				prepend_args = { "--config", ".eslintrc.js" },
			},
			black = {
				args = { "--line-length=88", "--fast" },
			},
			isort = {
				args = { "--profile", "black" },
			},
			stylua = {
				args = {
					"--column-width=120",
					"--line-endings=Unix",
					"--indent-type=Spaces",
					"--indent-width=2",
				},
			},
		},
	},
	init = function()
		-- Ensure formatters are installed
		local mason_registry = require("mason-registry")

		-- List of formatters to install
		local ensure_installed = {
			"prettier",
			"eslint_d",
			"black",
			"isort",
			"stylua",
			"gofmt",
			"goimports",
			"hadolint",
			"yamlfmt",
		}

		-- Install missing formatters
		for _, formatter in ipairs(ensure_installed) do
			if not mason_registry.is_installed(formatter) then
				vim.cmd("MasonInstall " .. formatter)
			end
		end

		-- Register custom key command group
		local wk = require("which-key")
		wk.register({
			f = {
				m = "Format buffer",
				name = "Format",
			},
		}, { prefix = "<leader>" })
	end,
}
