-- Decrease update time (default: 4000)
vim.opt.updatetime = 250 -- Faster response time
vim.opt.timeoutlen = 300 -- Shorter key sequence timeout

-- Better backup strategy
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true -- Persistent undo history
vim.opt.undolevels = 10000

-- Improved file handling
vim.opt.fileencoding = "utf-8"
vim.opt.autoread = true -- Auto-reload files changed outside vim

-- Search improvements
vim.opt.hlsearch = true
vim.opt.incsearch = true -- Show search matches while typing
vim.opt.inccommand = "split" -- Show replacements in a split window

-- UI Enhancements
vim.opt.termguicolors = true -- Enable 24-bit RGB colors
vim.opt.signcolumn = "yes" -- Always show sign column
vim.opt.colorcolumn = "80" -- Line length marker
vim.opt.scrolloff = 8 -- Minimum lines to keep above/below cursor
vim.opt.sidescrolloff = 8 -- Minimum columns to keep left/right of cursor

-- Split behavior
vim.opt.splitright = true -- Open vertical splits to the right
vim.opt.splitbelow = true -- Open horizontal splits below

-- Command line
vim.opt.cmdheight = 2 -- More space for messages

-- Code folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99 -- Start with all folds open
vim.opt.foldenable = true -- Enable folding

-- Word wrapping
vim.opt.wrap = false -- Disable line wrapping
vim.opt.whichwrap:append("<,>,[,],h,l") -- Allow keys to move across lines

-- Better completion
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.pumheight = 10 -- Maximum number of items in popup menu

-- Performance
vim.opt.lazyredraw = true -- Don't redraw screen while executing macros
vim.opt.redrawtime = 1500 -- Time limit for syntax highlighting
vim.opt.synmaxcol = 200 -- Max column for syntax highlighting

-- History
vim.opt.history = 500 -- Remember more commands

-- Line Numbers (keep existing)
vim.opt.relativenumber = true
vim.opt.number = true

-- Tabs & Indentation (keep existing)
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true

-- Mouse Mode (keep existing)
vim.opt.mouse = "a"

-- Line Highlight (keep existing)
vim.opt.cursorline = false

-- Clipboard Copy (keep existing)
vim.opt.clipboard:append("unnamedplus")

-- Search Settings (keep existing)
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Proper Backspace setting (keep existing)
vim.opt.backspace = "indent,eol,start"
