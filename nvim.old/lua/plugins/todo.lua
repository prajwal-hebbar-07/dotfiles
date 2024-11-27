return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {}, -- Plugin configuration options go here
	config = function()
		require("todo-comments").setup({})
		-- Keymaps should be set after setup
	end,
}
