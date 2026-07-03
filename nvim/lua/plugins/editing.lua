local treesitter_languages = {
	"bash",
	"css",
	"html",
	"javascript",
	"json",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"python",
	"query",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

local treesitter_install_languages = vim.tbl_filter(function(language)
	return language ~= "vim"
end, treesitter_languages)

local treesitter_filetypes = {
	"bash",
	"css",
	"html",
	"javascript",
	"javascriptreact",
	"json",
	"lua",
	"markdown",
	"python",
	"query",
	"sh",
	"typescript",
	"typescriptreact",
	"vim",
	"vimdoc",
	"yaml",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = function()
			package.loaded["nvim-treesitter"] = nil
			package.loaded["nvim-treesitter.parsers"] = nil

			local treesitter = require("nvim-treesitter")

			treesitter.install(treesitter_install_languages):wait(300000)
			treesitter.update(treesitter_install_languages):wait(300000)
		end,
		config = function()
			require("nvim-treesitter").setup()

			local installed = {}
			for _, language in ipairs(treesitter_languages) do
				installed[language] = true
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
				pattern = treesitter_filetypes,
				callback = function(event)
					local filetype = vim.bo[event.buf].filetype
					local language = vim.treesitter.language.get_lang(filetype) or filetype

					if not installed[language] then
						return
					end

					pcall(vim.treesitter.start, event.buf, language)
					vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({})

			local ok, cmp = pcall(require, "cmp")
			if ok then
				local cmp_autopairs = require("nvim-autopairs.completion.cmp")
				cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
			end
		end,
	},
}
