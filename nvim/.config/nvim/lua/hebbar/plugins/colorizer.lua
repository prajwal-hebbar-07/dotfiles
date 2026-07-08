return {
  "NvChad/nvim-colorizer.lua",
  ft = { "html", "css", "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte", "astro" },
  opts = {
    user_commands = true,
    filetypes = {
      "*",
      css = { tailwind = true },
      html = { tailwind = true },
      javascriptreact = { tailwind = true },
      typescriptreact = { tailwind = true },
    },
  },
}
