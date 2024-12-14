return {
	"mfussenegger/nvim-lint",
	event = {
		"BufReadPre",
		"BufNewFile",
	},
	dependencies = {
		"williamboman/mason.nvim",
	},
	config = function()
		local lint = require("lint")

		-- Configure linters for different filetypes
		lint.linters_by_ft = {
			-- Web Development
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			vue = { "eslint_d" },

			-- Python
			python = { "ruff", "pylint" }, -- ruff is faster than pylint

			-- Go
			go = { "golangci-lint" },

			-- Docker and Configuration
			dockerfile = { "hadolint" },
			yaml = { "yamllint" },

			-- Shell Scripts
			sh = { "shellcheck" },
			bash = { "shellcheck" },

			-- CSS/SCSS
			css = { "stylelint" },
			scss = { "stylelint" },

			-- HTML
			html = { "tidy" },

			-- JSON
			json = { "jsonlint" },

			-- GraphQL
			graphql = { "gqlint" },
		}

		-- Ensure linters are installed via Mason
		local mason_registry = require("mason-registry")
		local ensure_installed = {
			-- JavaScript/TypeScript
			"eslint_d",
			"prettier",

			-- Python
			"ruff",
			"pylint",

			-- Go
			"golangci-lint",

			-- Docker/YAML
			"hadolint",
			"yamllint",

			-- Shell
			"shellcheck",

			-- CSS/SCSS
			"stylelint",

			-- HTML
			"tidy",

			-- JSON
			"jsonlint",

			-- GraphQL
			"gqlint",
		}

		-- Auto-install linters if not already installed
		for _, linter in ipairs(ensure_installed) do
			if not mason_registry.is_installed(linter) then
				vim.cmd("MasonInstall " .. linter)
			end
		end

		-- Configure specific linter settings
		lint.linters.ruff = {
			cmd = "ruff",
			args = { "check", "--format", "text", "-" },
			stdin = true,
		}

		-- Create autocmd group for linting
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		-- Setup autocommands for automatic linting
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
			group = lint_augroup,
			callback = function()
				-- Don't lint if the file is too large
				local max_filesize = 100 * 1024 -- 100 KB
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
				if ok and stats and stats.size > max_filesize then
					return
				end

				lint.try_lint()
			end,
		})

		-- Keymaps
		local function lint_and_show_diagnostics()
			lint.try_lint()
			vim.diagnostic.setloclist({ open = true })
		end

		vim.keymap.set("n", "<leader>ll", lint_and_show_diagnostics, { desc = "Trigger linting and show diagnostics" })
		vim.keymap.set("n", "<leader>lf", function()
			vim.cmd("EslintFixAll")
		end, { desc = "Fix all ESLint issues" })

		-- Status line integration (if you use lualine)
		local function get_lint_status()
			local bufnr = vim.api.nvim_get_current_buf()
			local diagnostics = vim.diagnostic.get(bufnr)
			local count = {
				errors = 0,
				warnings = 0,
				info = 0,
				hints = 0,
			}

			for _, diagnostic in ipairs(diagnostics) do
				if diagnostic.severity == vim.diagnostic.severity.ERROR then
					count.errors = count.errors + 1
				elseif diagnostic.severity == vim.diagnostic.severity.WARN then
					count.warnings = count.warnings + 1
				elseif diagnostic.severity == vim.diagnostic.severity.INFO then
					count.info = count.info + 1
				elseif diagnostic.severity == vim.diagnostic.severity.HINT then
					count.hints = count.hints + 1
				end
			end

			return count
		end

		-- Make lint_status available globally for statusline usage
		_G.lint_status = get_lint_status
	end,
}
