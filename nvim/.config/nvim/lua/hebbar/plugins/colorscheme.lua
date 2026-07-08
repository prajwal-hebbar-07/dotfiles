return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        integrations = {
          gitsigns = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
            },
          },
          telescope = true,
          treesitter = true,
          mini = true,
          markdown = true,
        },
      })

      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
