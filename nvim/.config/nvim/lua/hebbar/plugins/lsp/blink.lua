return {
  "saghen/blink.cmp",
  version = "v1.*",
  dependencies = {
    "L3MON4D3/LuaSnip",
    "rafamadriz/friendly-snippets",
  },
  config = function()
    require("blink.cmp").setup({
      fuzzy = {
        implementation = "prefer_rust",
      },
      keymap = {
        preset = "default",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
      },
      completion = {
        menu = {
          auto_show = true,
        },
        list = {
          selection = {
            -- No item preselected: the first <Tab> lands on the first
            -- option, and <CR> is a plain newline until something is
            -- selected.
            preselect = false,
            auto_insert = false,
          },
        },
        documentation = {
          auto_show = true,
        },
        ghost_text = {
          enabled = false,
        },
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
      },
      cmdline = {
        enabled = true,
        keymap = { preset = "cmdline" },
        completion = {
          menu = { auto_show = true },
        },
      },
      sources = {
        default = { "lsp", "path", "buffer", "snippets" },
      },
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      },
      snippets = {
        preset = "luasnip",
      },
      signature = {
        enabled = true,
      },
    })

    require("luasnip.loaders.from_vscode").lazy_load()
  end,
}
