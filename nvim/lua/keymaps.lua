local keymap = vim.keymap

keymap.set("n", ";", ":", { noremap = true, desc = "Use ; to enter command mode" })

-- Commenting
keymap.set("n", "<leader>/", "<Plug>(comment_toggle_linewise_current)", { desc = "Comment Line" })
keymap.set("x", "/", "<Plug>(comment_toggle_linewise_visual)", { desc = "Comment Visual Mode" })

-- nvim tree
keymap.set("n", "\\", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" })
keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })

-- Telescope
keymap.set("n", "<leader>sh", "Telescope help_tags", { desc = "[S]earch [H]elp" })
keymap.set("n", "<leader>sk", "Telescope keymaps", { desc = "[S]earch [K]eymaps" })
keymap.set("n", "<leader>sf", "Telescope find_files", { desc = "[S]earch [F]iles" })
keymap.set("n", "<leader>ss", "Telescope builtin", { desc = "[S]earch [S]elect Telescope" })
keymap.set("n", "<leader>sw", "Telescope grep_string", { desc = "[S]earch current [W]ord" })
keymap.set("n", "<leader>sg", "Telescope live_grep", { desc = "[S]earch by [G]rep" })
keymap.set("n", "<leader>sd", "Telescope diagnostics", { desc = "[S]earch [D]iagnostics" })
keymap.set("n", "<leader><leader>", "Telescope buffers", { desc = "[ ] Find existing buffers" })
keymap.set(
	"n",
	"<leader>st",
	":TodoTelescope<CR>",
	{ noremap = true, silent = true, desc = "Todo Comments Telescope Mode" }
)
keymap.set(
	"n",
	"<leader>t1",
	":TodoTelescope keywords=ISSUE,FIX,FIXME,BUG<CR>",
	{ noremap = true, silent = true, desc = "Todo Comments Telescope Mode" }
)
keymap.set(
	"n",
	"<leader>t2",
	":TodoTelescope keywords=WARN,WARNING<CR>",
	{ noremap = true, silent = true, desc = "Todo Comments Telescope Mode" }
)

-- Movement or window movement
keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Movement by words
keymap.set("n", "<M-h>", "b")
keymap.set("n", "<M-l>", "w")
keymap.set("i", "<M-h>", "<C-o>b")
keymap.set("i", "<M-l>", "<C-o>w")

-- Save File
keymap.set("n", "<C-s>", ":w<CR>")
keymap.set("i", "<C-s>", "<ESC>:w<CR>")

-- Split windows in nvim
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", {})
keymap.set("n", "<leader>sx", "<cmd>close<CR>", {})

-- Movement to middle of the screen
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- additional preferences
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
keymap.set("n", "<leader>h", ":nohlsearch<CR>")
