-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- (Buffer `]b`/`[b`, `<leader>bd`, window nav, etc. already come from LazyVim.)

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap("n", "<leader><leader>", "<cmd>source %<CR>", { desc = "Source current file" })
keymap("n", "<C-c>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
keymap("n", "Q", "<nop>", opts)

-- Move / reselect
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Keep cursor stable
keymap("n", "J", "mzJ`z", opts)
keymap("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

-- Registers
keymap("x", "p", [["_dP]], { desc = "Paste without replacing register" })
keymap({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })
keymap("n", "x", [["_x]], opts)

keymap("n", "<leader>sw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], {
  desc = "Replace word under cursor",
})
keymap("n", "<leader>X", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })

-- Splits
keymap("n", "<leader>sv", "<C-w>v", { desc = "Split vertically" })
keymap("n", "<leader>sh", "<C-w>s", { desc = "Split horizontally" })
keymap("n", "<leader>se", "<C-w>=", { desc = "Equalize splits" })
keymap("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close split" })

-- Tabs
keymap("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open tab" })
keymap("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close tab" })
keymap("n", "<leader>tn", "<cmd>tabnext<CR>", { desc = "Next tab" })
keymap("n", "<leader>tp", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
keymap("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current file in tab" })

-- Terminal
keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Enter terminal normal mode" })
keymap("t", "<C-h>", "<cmd>wincmd h<CR>", { desc = "Move to left split" })
keymap("t", "<C-j>", "<cmd>wincmd j<CR>", { desc = "Move to lower split" })
keymap("t", "<C-k>", "<cmd>wincmd k<CR>", { desc = "Move to upper split" })
keymap("t", "<C-l>", "<cmd>wincmd l<CR>", { desc = "Move to right split" })

keymap("n", "<leader>fp", function()
  local path = vim.fn.expand("%:~")
  vim.fn.setreg("+", path)
  vim.notify("Copied file path: " .. path)
end, { desc = "Copy file path" })
