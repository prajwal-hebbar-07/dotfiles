vim.g.netrw_banner = 0

local opt = vim.opt

opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.numberwidth = 4
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.mouse = "a"
opt.clipboard:append("unnamedplus")
opt.confirm = true
opt.autoread = true

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = false
opt.wrap = false

opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.fn.mkdir(opt.undodir:get()[1], "p")

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.inccommand = "split"

opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.updatetime = 100
opt.timeoutlen = 400
opt.pumheight = 10
opt.colorcolumn = "0"
opt.guicursor = ""
opt.isfname:append("@-@")
opt.virtualedit = "block"
opt.breakindent = true
opt.smoothscroll = true
opt.list = true
opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}

opt.showmode = false
opt.laststatus = 3
opt.showtabline = 1
opt.winborder = "rounded"
opt.fillchars = {
  eob = " ",
  fold = " ",
  foldclose = "",
  foldopen = "",
  foldsep = " ",
}

opt.foldenable = true
opt.foldmethod = "manual"
opt.foldlevel = 99
opt.foldcolumn = "0"

opt.sessionoptions = { "buffers", "curdir", "folds", "help", "tabpages", "winsize", "winpos", "terminal", "localoptions" }
opt.diffopt:append({ "algorithm:histogram", "linematch:60" })
opt.shortmess:append("I")
