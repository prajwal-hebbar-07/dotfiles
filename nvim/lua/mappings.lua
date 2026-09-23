require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- The system clipboard, on purpose and never by accident.
map({ "n", "x" }, "<leader>y", '"+y', { desc = "clipboard copy motion or selection" })
map("n", "<leader>Y", '"+yy', { desc = "clipboard copy line" })
