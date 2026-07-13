return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "norg", "rmd", "org" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      heading = {
        sign = false,
      },
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      bullet = {
        enabled = true,
      },
      checkbox = {
        enabled = true,
      },
      html = {
        comment = {
          conceal = false,
        },
      },
    },
  },
  {
    -- Live preview in the browser: opens the current markdown file in a
    -- browser tab that re-renders as you edit, so you can flip to the browser
    -- to read a plan and come back to nvim to keep editing the command.
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    -- Run synchronously so lazy.nvim does not finish the build before the
    -- plugin's asynchronous Vimscript installer downloads the server binary.
    build = "cd app && ./install.sh",
    init = function()
      -- Keep the preview tab open when switching buffers so it survives a
      -- trip back to nvim; don't steal focus from the editor on open.
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_preview_options = { disable_sync_scroll = 0 }
    end,
  },
}
