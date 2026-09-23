require "nvchad.options"

-- Yank, delete and change stay inside Vim. Space y and Space Y are the only
-- keys that reach the system clipboard — see lua/mappings.lua.
local o = vim.o
o.clipboard = ""

-- Swap, undo and backup never land in a project tree.
local state = vim.fn.stdpath "state"
o.directory = state .. "/swap//"
o.undodir = state .. "/undo//"
o.backupdir = state .. "/backup//"
