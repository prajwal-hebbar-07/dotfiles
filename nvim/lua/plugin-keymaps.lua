local set = vim.keymap.set

-- todo comments
set("n", "<leader>ft", ":TodoTelescope<CR>", { noremap = true, silent = true, desc = "Todo Comments Telescope Mode" })

-- lazygit
set("n", "<leader>lg", "<cmd>LazyGit<cr>", { desc = "Open Lazy Git" })

-- commenting
set("n", "<leader>/", "<Plug>(comment_toggle_linewise_current)", { desc = "Comment line" })
set("x", "<leader>/", "<Plug>(comment_toggle_linewise_visual)", { desc = "Visual mode comment" })

-- nvim tree
set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" })
set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })

-- telescope
set("n", "<leader>tf", ":Telescope find_files<CR>", { desc = "Telescope find files" })
set("n", "<leader>tg", ":Telescope live_grep<CR>", { desc = "Telescope find files" })
