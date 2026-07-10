return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
        float = {
          transparent = true,
        },
        lsp_styles = {
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
          },
        },
        integrations = {
          blink_cmp = true,
          gitsigns = true,
          lsp_trouble = true,
          mason = true,
          render_markdown = true,
          telescope = true,
          treesitter = true,
          mini = true,
        },
      })

      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
