return {
	"nvim-lualine/lualine.nvim",
	config = function()
		require("lualine").setup({
			options = {
				theme = "tokyonight",
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "filename" },
				lualine_c = { "encoding", "fileformat", "filetype" },
				lualine_x = { "branch", "diff", "diagnostics" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		})
	end,
}
