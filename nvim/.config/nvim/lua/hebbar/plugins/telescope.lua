return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        path_display = { "smart" },
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
        },
      },
    })

    pcall(telescope.load_extension, "fzf")

    vim.keymap.set("n", "<leader>pf", builtin.find_files, { desc = "Find files" })
    vim.keymap.set("n", "<leader>pg", builtin.git_files, { desc = "Find Git files" })
    vim.keymap.set("n", "<leader>ps", builtin.live_grep, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>pr", builtin.oldfiles, { desc = "Recent files" })
    vim.keymap.set("n", "<leader>pb", builtin.buffers, { desc = "Buffers" })
    vim.keymap.set("n", "<leader>pk", builtin.keymaps, { desc = "Keymaps" })
    vim.keymap.set("n", "<leader>vh", builtin.help_tags, { desc = "Help tags" })
    vim.keymap.set("n", "<leader>pws", function()
      builtin.grep_string({ search = vim.fn.expand("<cword>") })
    end, { desc = "Search word under cursor" })
  end,
}
