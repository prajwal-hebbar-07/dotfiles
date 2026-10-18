return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      -- Tailwind is CSS/HTML/JS context, so it has no parser of its own;
      -- markdown_inline is markdown's other half.
      ensure_installed = {
        "javascript", "typescript", "tsx", "html", "css",
        "go", "odin",
        "lua", "luadoc", "bash", "json", "yaml", "toml",
        "markdown", "markdown_inline", "gitcommit", "diff",
        "vim", "vimdoc", "printf",
      },
      auto_install = true, -- a language met later installs itself
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- Live markdown preview in Brave; renders mermaid, KaTeX, PlantUML.
  -- build downloads the prebuilt server, so no node/yarn step.
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    -- prebuilt server binary; synchronous so headless `Lazy build` works
    build = "cd app && ./install.sh",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_browser = "Brave Browser" -- macOS app name, passed to `open -a`
      vim.g.mkdp_auto_close = 0 -- keep the tab when switching buffers
      vim.g.mkdp_theme = "dark"
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "markdown preview toggle (Brave)" },
    },
  },
}
