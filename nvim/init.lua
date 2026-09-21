-- ─────────────────────────────────────────────────────────────────────────────
-- Neovim — Pale Knight
--
-- A terminal editor in the same colours as the rest of the workshop. This file
-- is the only entrypoint: no Lua module tree, no plugins, no plugin manager, no
-- network. Starting `nvim` with nothing but this file must work.
--
-- Source of truth: dotfiles/nvim/init.lua  (~/.config/nvim/init.lua -> here)
-- Maps: Space ? lists every map this config defines.
-- ─────────────────────────────────────────────────────────────────────────────


-- ── Palette ──────────────────────────────────────────────────────────────────
-- Shared with tmux/tmux.conf, ghostty/themes/pale-knight and zsh/zshrc. Void is
-- the live terminal ground, so an empty buffer and the terminal are one surface.
-- Green and red are Ghostty's ANSI 2 and 1: diff and git colour.
local c = {
  void      = '#0f111a', -- the abyss, deepest background (matches ghostty)
  crypt     = '#32334a', -- status bar ground
  shade     = '#444364', -- raised cell / selection
  stone     = '#696e93', -- dim text, separators
  ash       = '#9297ba', -- punctuation, quiet structure
  bone      = '#a6accd', -- body text
  pale      = '#d4d7f1', -- pale king white, active text
  soul      = '#5cb1d2', -- cyan, focus and life
  lifeblood = '#86a4e1', -- blue, secondary accent
  infection = '#c39e5c', -- amber, wants attention
  essence   = '#ba92d5', -- violet, quiet metadata
  green     = '#91b171', -- ghostty ANSI 2 — added
  red       = '#da8c8d', -- ghostty ANSI 1 — removed
}


-- ── Leader ───────────────────────────────────────────────────────────────────
-- Space, set before any map. Ctrl-S is never mapped: tmux holds it as prefix.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '


-- ── Options ──────────────────────────────────────────────────────────────────
local o = vim.opt

o.termguicolors = true
o.number = true                -- absolute numbers; no relative jumping
o.signcolumn = 'yes'           -- reserved, so diagnostics never shift the text
o.cursorline = true
o.laststatus = 3               -- one statusline for all splits
o.showmode = false
o.scrolloff = 4
o.splitbelow = true
o.splitright = true
o.mouse = 'a'
o.confirm = true               -- Space q on a dirty buffer asks instead of failing

o.ignorecase = true            -- case-insensitive unless the pattern has a capital
o.smartcase = true
o.inccommand = 'nosplit'

o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2

-- Junk never lands in a project tree: swap, undo and write-backups all live in
-- Neovim's own state directory, which is also the default. Stated explicitly
-- because it is the difference between reviewing a repo and polluting it.
local state = vim.fn.stdpath('state')
o.directory = state .. '/swap//'
o.undodir = state .. '/undo//'
o.backupdir = state .. '/backup//'
o.backup = false
o.undofile = true


-- ── Clipboard ────────────────────────────────────────────────────────────────
-- Neovim finds the right tool by itself when a session owns a clipboard:
-- pbcopy on macOS, wl-copy under Wayland, xclip or xsel under X11. When none
-- of those can reach the clipboard you are actually looking at — over SSH, or
-- on a Linux box with no display server — hand the bytes to the terminal with
-- OSC 52 instead; tmux forwards it (set-clipboard on/external, the default).
o.clipboard = 'unnamedplus'

local function session_clipboard()
  if vim.fn.executable('pbcopy') == 1 then
    return true
  end
  if vim.env.WAYLAND_DISPLAY and vim.fn.executable('wl-copy') == 1 then
    return true
  end
  if vim.env.DISPLAY and (vim.fn.executable('xclip') == 1 or vim.fn.executable('xsel') == 1) then
    return true
  end
  return false
end

if vim.env.SSH_TTY or not session_clipboard() then
  local ok, osc52 = pcall(require, 'vim.ui.clipboard.osc52')
  if ok then
    vim.g.clipboard = {
      name = 'OSC 52',
      copy = { ['+'] = osc52.copy('+'), ['*'] = osc52.copy('*') },
      paste = { ['+'] = osc52.paste('+'), ['*'] = osc52.paste('*') },
    }
  end
end


-- ── Theme ────────────────────────────────────────────────────────────────────
-- Built-in syntax only at this point, so these are the groups Vim's own syntax
-- files and the UI use. Accents are equal weight by design: hue carries the
-- meaning, nothing shouts.
for group, spec in pairs({
  Normal         = { fg = c.bone, bg = c.void },
  NormalFloat    = { fg = c.bone, bg = c.crypt },
  FloatBorder    = { fg = c.shade, bg = c.crypt },
  FloatTitle     = { fg = c.pale, bg = c.crypt, bold = true },
  Cursor         = { fg = c.void, bg = c.soul },
  CursorLine     = { bg = c.crypt },
  CursorLineNr   = { fg = c.pale },
  LineNr         = { fg = c.stone },
  SignColumn     = { bg = c.void, fg = c.stone },
  ColorColumn    = { bg = c.crypt },
  WinSeparator   = { fg = c.shade, bg = c.void },
  Visual         = { fg = c.pale, bg = c.shade },
  Search         = { fg = c.void, bg = c.infection },
  IncSearch      = { fg = c.void, bg = c.soul },
  CurSearch      = { fg = c.void, bg = c.soul },
  MatchParen     = { fg = c.pale, bg = c.shade, bold = true },
  Folded         = { fg = c.stone, bg = c.crypt },
  NonText        = { fg = c.shade },
  Whitespace     = { fg = c.shade },
  EndOfBuffer    = { fg = c.void },
  Directory      = { fg = c.lifeblood },
  Title          = { fg = c.pale, bold = true },
  Question       = { fg = c.soul },
  MoreMsg        = { fg = c.soul },
  ModeMsg        = { fg = c.ash },
  WarningMsg     = { fg = c.infection },
  ErrorMsg       = { fg = c.red },
  StatusLine     = { fg = c.bone, bg = c.crypt },
  StatusLineNC   = { fg = c.stone, bg = c.crypt },
  TabLine        = { fg = c.stone, bg = c.crypt },
  TabLineSel     = { fg = c.pale, bg = c.shade },
  TabLineFill    = { bg = c.void },
  WinBar         = { fg = c.ash, bg = c.void },
  WinBarNC       = { fg = c.stone, bg = c.void },
  Pmenu          = { fg = c.bone, bg = c.crypt },
  PmenuSel       = { fg = c.pale, bg = c.shade },
  PmenuSbar      = { bg = c.crypt },
  PmenuThumb     = { bg = c.shade },

  Comment        = { fg = c.stone, italic = true },
  Constant       = { fg = c.infection },
  String         = { fg = c.green },
  Character      = { fg = c.green },
  Number         = { fg = c.infection },
  Boolean        = { fg = c.infection },
  Float          = { fg = c.infection },
  Identifier     = { fg = c.bone },
  Function       = { fg = c.lifeblood },
  Statement      = { fg = c.essence },
  Keyword        = { fg = c.essence },
  Operator       = { fg = c.soul },
  PreProc        = { fg = c.essence },
  Type           = { fg = c.soul },
  Structure      = { fg = c.soul },
  Special        = { fg = c.soul },
  Delimiter      = { fg = c.ash },
  Underlined     = { fg = c.lifeblood, underline = true },
  Todo           = { fg = c.void, bg = c.infection, bold = true },
  Error          = { fg = c.red },

  DiffAdd        = { fg = c.green },
  DiffChange     = { fg = c.lifeblood },
  DiffDelete     = { fg = c.red },
  DiffText       = { fg = c.pale, bg = c.shade },

  DiagnosticError = { fg = c.red },
  DiagnosticWarn  = { fg = c.infection },
  DiagnosticInfo  = { fg = c.soul },
  DiagnosticHint  = { fg = c.stone },
  DiagnosticOk    = { fg = c.green },

  -- Hunk signs and the statusline segments: defined here, before the plugins
  -- load, so gitsigns keeps these instead of inventing its own.
  GitSignsAdd    = { fg = c.green, bg = c.void },
  GitSignsChange = { fg = c.infection, bg = c.void },
  GitSignsDelete = { fg = c.red, bg = c.void },
  StatusLineHead = { fg = c.soul, bg = c.crypt },
  StatusLineAdd  = { fg = c.green, bg = c.crypt },
  StatusLineMod  = { fg = c.infection, bg = c.crypt },
  StatusLineDel  = { fg = c.red, bg = c.crypt },
  StatusLineErr  = { fg = c.red, bg = c.crypt },
  StatusLineWarn = { fg = c.infection, bg = c.crypt },
  StatusLineInfo = { fg = c.soul, bg = c.crypt },
  StatusLineHint = { fg = c.stone, bg = c.crypt },
}) do
  vim.api.nvim_set_hl(0, group, spec)
end


-- ── Maps ─────────────────────────────────────────────────────────────────────
-- Every map goes through `map`, so Space ? cannot drift out of date. `q` in
-- normal mode stays the macro key; Ctrl-S belongs to tmux.
local cheats = {}

local function map(mode, lhs, rhs, desc)
  cheats[#cheats + 1] = { lhs, desc }
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

local function cheatsheet()
  local chunks = { { 'Pale Knight maps\n', 'Title' } }
  for _, entry in ipairs(cheats) do
    local lhs = entry[1]:gsub('<leader>', 'Space ')
    chunks[#chunks + 1] = { ('  %-12s'):format(lhs), 'Identifier' }
    chunks[#chunks + 1] = { entry[2] .. '\n' }
  end
  vim.api.nvim_echo(chunks, false, {})
end

map('n', '<leader>w', '<cmd>write<cr>', 'write this file')
map('n', '<leader>q', '<cmd>quit<cr>', 'quit this window')
map('n', '<leader>x', '<cmd>wall | qall<cr>', 'write everything and quit')
map('n', '<leader>?', cheatsheet, 'list these maps')


-- ── Plugins ──────────────────────────────────────────────────────────────────
-- lazy.nvim clones itself and every plugin into Neovim's data directory. This
-- repo holds the spec and `lazy-lock.json` (which lazy keeps next to this file,
-- in stdpath('config')) — never a plugin source tree.
--
-- Every plugin is optional at runtime: if the clone never happened, if there is
-- no network, or if a parser fails to build, everything above this line still
-- works. That is what the guards are for, not defensiveness for its own sake.
local uv = vim.uv or vim.loop
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not uv.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  })
end

-- Treesitter off for machine-written files: a 900 kB lockfile or a minified
-- bundle would otherwise parse on every glance.
local function pathological(_, buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local stat = name ~= '' and uv.fs_stat(name) or nil
  if stat and stat.size > 512 * 1024 then
    return true
  end
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, 8, false)) do
    if #line > 2000 then
      return true
    end
  end
  return false
end

if uv.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
  local ok, lazy = pcall(require, 'lazy')
  if ok then
    pcall(lazy.setup, {
      { 'folke/lazy.nvim', version = '*' }, -- the installer manages itself
      {
        -- ponytail: the frozen master branch, because its `configs.setup` is one
        -- call; move to the `main` rewrite when a parser it lacks is needed.
        'nvim-treesitter/nvim-treesitter',
        branch = 'master',
        build = ':TSUpdate',
        config = function()
          require('nvim-treesitter.configs').setup({
            -- The locked language set. Tailwind is CSS/HTML/JS context, so it
            -- has no parser of its own; markdown_inline is markdown's other half.
            ensure_installed = {
              'javascript', 'typescript', 'tsx', 'html', 'css',
              'go', 'odin',
              'lua', 'bash', 'json', 'yaml', 'toml',
              'markdown', 'markdown_inline', 'gitcommit', 'diff',
            },
            auto_install = true, -- a language met later installs itself
            highlight = { enable = true, disable = pathological },
          })
        end,
      },
      {
        'neovim/nvim-lspconfig',
        config = function()
          -- Servers come from PATH — whatever nvm, brew, or go install already
          -- put there. A version directory is never written into this file, and
          -- a language whose server is absent simply has no LSP.
          local servers = {
            ts_ls = 'typescript-language-server', -- JS, TS, TSX, Node/Express
            tailwindcss = 'tailwindcss-language-server',
            html = 'vscode-html-language-server',
            cssls = 'vscode-css-language-server',
            jsonls = 'vscode-json-language-server',
            gopls = 'gopls',
            ols = 'ols',
            lua_ls = 'lua-language-server',
          }
          local present = {}
          for name, binary in pairs(servers) do
            if vim.fn.executable(binary) == 1 then
              present[#present + 1] = name
            end
          end
          vim.lsp.enable(present)
        end,
      },
      {
        'ibhagwan/fzf-lua',
        config = function()
          -- `fzf_colors = true` derives fzf's chrome from the highlight groups
          -- above, so the picker is the same Pale Knight as $FZF_DEFAULT_OPTS
          -- in the shell instead of fzf-lua's own theme. Glyphs match too.
          require('fzf-lua').setup({
            fzf_colors = true,
            winopts = { border = 'rounded', preview = { border = 'rounded' } },
            fzf_opts = {
              ['--layout'] = 'reverse',
              ['--info'] = 'inline-right',
              ['--pointer'] = '❯',
              ['--marker'] = '◆',
              ['--scrollbar'] = '▌',
            },
          })
        end,
      },
      {
        'lewis6991/gitsigns.nvim',
        config = function()
          require('gitsigns').setup({
            signs = {
              add = { text = '│' },
              change = { text = '│' },
              delete = { text = '▁' },
              topdelete = { text = '▔' },
              changedelete = { text = '~' },
              untracked = { text = '┆' },
            },
          })
        end,
      },
    }, {
      change_detection = { notify = false },
      ui = { border = 'rounded' },
    })
  end
end


-- ── Language intelligence ────────────────────────────────────────────────────
-- These maps and this autocmd cost nothing when no server attached: they are
-- defined once here rather than rebuilt per buffer.
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { prefix = '·', spacing = 2 },
  signs = { text = { [vim.diagnostic.severity.ERROR] = 'E', [vim.diagnostic.severity.WARN] = 'W',
                     [vim.diagnostic.severity.INFO] = 'I', [vim.diagnostic.severity.HINT] = 'H' } },
})

-- Completion is Neovim's own LSP completion. No completion plugin.
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

map('n', 'gd', vim.lsp.buf.definition, 'go to definition')
map('n', 'gD', vim.lsp.buf.declaration, 'go to declaration')
map('n', 'gi', vim.lsp.buf.implementation, 'go to implementation')
map('n', 'gy', vim.lsp.buf.type_definition, 'go to type definition')
map('n', 'gr', vim.lsp.buf.references, 'list references')
map('n', 'K', vim.lsp.buf.hover, 'hover documentation')
map('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'previous diagnostic')
map('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'next diagnostic')
map({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, 'code action')
map('n', '<leader>rn', vim.lsp.buf.rename, 'rename symbol')
-- Format on request only. Never on save: the buffer is not rewritten under you.
map({ 'n', 'x' }, '<leader>F', function() vim.lsp.buf.format({ async = true }) end, 'format (LSP)')


-- ── Find and review ──────────────────────────────────────────────────────────
-- Pickers and hunk motions resolve their plugin at call time, so a machine
-- where the clone never happened just gets a one-line message.
local function pick(fn)
  return function()
    local ok_fzf, fzf = pcall(require, 'fzf-lua')
    if ok_fzf then
      fzf[fn]()
    else
      vim.notify('fzf-lua is not installed', vim.log.levels.WARN)
    end
  end
end

map('n', '<leader>f', pick('files'), 'find files')
map('n', '<leader>g', pick('live_grep'), 'grep the tree')
map('n', '<leader>b', pick('buffers'), 'switch buffer')
map('n', '<leader>/', pick('grep_cword'), 'grep the word under the cursor')

local function hunk(direction)
  return function()
    -- In a diff (git difftool, nvim -d) ]c and [c are already hunk motions.
    if vim.wo.diff then
      return vim.cmd.normal({ direction == 'next' and ']c' or '[c', bang = true })
    end
    local ok_gs, gs = pcall(require, 'gitsigns')
    if ok_gs then
      gs.nav_hunk(direction)
    end
  end
end

map('n', ']c', hunk('next'), 'next git hunk')
map('n', '[c', hunk('prev'), 'previous git hunk')
map('n', '<leader>p', function()
  local ok_gs, gs = pcall(require, 'gitsigns')
  if ok_gs then
    gs.preview_hunk()
  end
end, 'preview this git hunk')


-- ── Statusline ───────────────────────────────────────────────────────────────
-- Hand-rolled: path, branch, hunk counts, diagnostic counts, position. A
-- statusline plugin would be a second theme to keep in step with this file.
local severities = {
  { vim.diagnostic.severity.ERROR, 'StatusLineErr', 'E' },
  { vim.diagnostic.severity.WARN, 'StatusLineWarn', 'W' },
  { vim.diagnostic.severity.INFO, 'StatusLineInfo', 'I' },
  { vim.diagnostic.severity.HINT, 'StatusLineHint', 'H' },
}

function _G.pk_statusline()
  local out = { '%#StatusLine# %f %m%r' }

  local git = vim.b.gitsigns_status_dict
  if git then
    if git.head and git.head ~= '' then
      out[#out + 1] = ('%%#StatusLineHead#  %s'):format(git.head)
    end
    for _, seg in ipairs({
      { git.added, 'StatusLineAdd', '+' },
      { git.changed, 'StatusLineMod', '~' },
      { git.removed, 'StatusLineDel', '-' },
    }) do
      if (seg[1] or 0) > 0 then
        out[#out + 1] = ('%%#%s# %s%d'):format(seg[2], seg[3], seg[1])
      end
    end
  end

  local counts = vim.diagnostic.count(0)
  for _, seg in ipairs(severities) do
    local n = counts[seg[1]] or 0
    if n > 0 then
      out[#out + 1] = ('%%#%s# %s%d'):format(seg[2], seg[3], n)
    end
  end

  out[#out + 1] = '%#StatusLine#%= %l:%c  %P '
  return table.concat(out)
end

vim.o.statusline = '%!v:lua.pk_statusline()'
