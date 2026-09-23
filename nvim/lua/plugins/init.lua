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
}
