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
    build = function()
      -- Load the plugin first so its autoload/ is on the runtimepath, then
      -- pull down the prebuilt preview binary (no yarn/npm install needed).
      vim.cmd("Lazy load markdown-preview.nvim")
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      -- Keep the preview tab open when switching buffers so it survives a
      -- trip back to nvim; don't steal focus from the editor on open.
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_preview_options = { disable_sync_scroll = 0 }
    end,
  },
}
