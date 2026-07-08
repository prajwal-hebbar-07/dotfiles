local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap("n", "<leader><leader>", "<cmd>source %<CR>", { desc = "Source current file" })
keymap("n", "<C-c>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

keymap("n", "J", "mzJ`z", opts)
keymap("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

keymap("x", "p", [["_dP]], { desc = "Paste without replacing register" })
keymap({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })
keymap("n", "x", [["_x]], opts)

keymap("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], {
  desc = "Replace word under cursor",
})
keymap("n", "<leader>X", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })

keymap("n", "<leader>sv", "<C-w>v", { desc = "Split vertically" })
keymap("n", "<leader>sh", "<C-w>s", { desc = "Split horizontally" })
keymap("n", "<leader>se", "<C-w>=", { desc = "Equalize splits" })
keymap("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close split" })

keymap("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open tab" })
keymap("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close tab" })
keymap("n", "<leader>tn", "<cmd>tabnext<CR>", { desc = "Next tab" })
keymap("n", "<leader>tp", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
keymap("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current file in tab" })

keymap("n", "<leader>fp", function()
  local path = vim.fn.expand("%:~")
  vim.fn.setreg("+", path)
  vim.notify("Copied file path: " .. path)
end, { desc = "Copy file path" })

keymap("n", "<leader>lr", function()
  vim.cmd("LspRestart")
  vim.notify("LSP restarted")
end, { desc = "Restart LSP" })
