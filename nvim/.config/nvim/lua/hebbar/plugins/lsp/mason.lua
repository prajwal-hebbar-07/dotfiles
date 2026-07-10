return {
  "mason-org/mason.nvim",
  lazy = false,
  dependencies = {
    "mason-org/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "neovim/nvim-lspconfig",
  },
  config = function()
    require("mason").setup({
      ui = {
        border = "rounded",
        icons = {
          package_installed = "OK",
          package_pending = "->",
          package_uninstalled = "NO",
        },
      },
    })

    require("mason-lspconfig").setup({
      automatic_enable = false,
      ensure_installed = {
        "bashls",
        "cssls",
        "html",
        "jsonls",
        "lua_ls",
        "marksman",
        "pyright",
        "tailwindcss",
        "ts_ls",
        "yamlls",
      },
    })

    require("mason-tool-installer").setup({
      ensure_installed = {
        "biome",
        "black",
        "isort",
        "mdformat",
        "prettier",
        "prettierd",
        "pylint",
        "debugpy",
        "js-debug-adapter",
        "shfmt",
        "stylua",
      },
    })
  end,
}
