-- Rosé Pine, transparent + enriched syntax highlighting.
--
-- Mirrors the Helix `rose_pine_transparent` theme: the same scope→palette
-- mapping (types=foam, keywords=pine, functions=rose, ...) ported onto Neovim's
-- Treesitter capture groups, a transparent editor so wezterm's blur shows
-- through, and solid "card" popups so floating UI doesn't wash out.
return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      variant = "main", -- matches Helix's `rose_pine` (dark)
      dark_variant = "main",
      styles = {
        italic = true,
        bold = true,
        transparency = true,
      },
      highlight_groups = {
        -- Solid, elevated popup cards over the transparent editor
        NormalFloat = { bg = "surface" },
        FloatBorder = { fg = "iris", bg = "surface" },
        Pmenu = { fg = "subtle", bg = "surface" },
        PmenuSel = { fg = "base", bg = "iris", bold = true },
        PmenuSbar = { bg = "overlay" },
        PmenuThumb = { bg = "iris" },

        -- Types & namespaces
        ["@type"] = { fg = "foam" },
        ["@type.builtin"] = { fg = "foam", italic = true },
        ["@type.definition"] = { fg = "foam" },
        ["@type.parameter"] = { fg = "iris" }, -- generics <T>
        ["@constructor"] = { fg = "foam" },
        ["@module"] = { fg = "iris" }, -- Go packages, TS namespaces
        ["@lsp.type.enumMember"] = { fg = "rose" }, -- enum variants

        -- Keywords
        ["@keyword"] = { fg = "pine" },
        ["@keyword.function"] = { fg = "pine" }, -- func / function / def
        ["@keyword.conditional"] = { fg = "pine" },
        ["@keyword.repeat"] = { fg = "pine" },
        ["@keyword.import"] = { fg = "iris" }, -- import / from / require
        ["@keyword.return"] = { fg = "pine", italic = true },
        ["@keyword.exception"] = { fg = "love" }, -- try / catch / throw / panic
        ["@keyword.directive"] = { fg = "iris" }, -- pragmas, "use client"
        ["@keyword.modifier"] = { fg = "pine", italic = true }, -- async / static / const
        ["@keyword.type"] = { fg = "foam" }, -- class / struct / interface
        ["@keyword.operator"] = { fg = "subtle" },
        ["@operator"] = { fg = "subtle" },

        -- Functions
        ["@function"] = { fg = "rose" },
        ["@function.call"] = { fg = "rose" },
        ["@function.method"] = { fg = "rose" },
        ["@function.method.call"] = { fg = "rose" },
        ["@function.builtin"] = { fg = "love" },
        ["@function.macro"] = { fg = "iris" },

        -- Variables & members
        ["@variable"] = { fg = "text" },
        ["@variable.builtin"] = { fg = "love" }, -- this / self
        ["@variable.parameter"] = { fg = "iris" },
        ["@variable.member"] = { fg = "foam" }, -- obj.field
        ["@property"] = { fg = "foam" },
        ["@label"] = { fg = "foam" },
        ["@attribute"] = { fg = "iris" }, -- JSX/HTML attrs, decorators

        -- Tags (JSX / HTML)
        ["@tag"] = { fg = "foam" },
        ["@tag.builtin"] = { fg = "foam", bold = true },
        ["@tag.attribute"] = { fg = "iris" },
        ["@tag.delimiter"] = { fg = "subtle" },

        -- Constants, numbers, strings
        ["@constant"] = { fg = "foam" },
        ["@constant.builtin"] = { fg = "love" },
        ["@boolean"] = { fg = "rose" },
        ["@character"] = { fg = "gold" },
        ["@character.special"] = { fg = "pine" }, -- escapes
        ["@string"] = { fg = "gold" },
        ["@string.escape"] = { fg = "pine" },
        ["@string.regexp"] = { fg = "foam" },
        ["@string.special.url"] = { fg = "iris", underline = true },
        ["@string.special.path"] = { fg = "gold" },
        ["@number"] = { fg = "gold" },
        ["@number.float"] = { fg = "gold" },

        -- Punctuation
        ["@punctuation.delimiter"] = { fg = "subtle" },
        ["@punctuation.bracket"] = { fg = "subtle" },
        ["@punctuation.special"] = { fg = "rose" }, -- template ${}, JSX braces

        -- Comments
        ["@comment"] = { fg = "muted", italic = true },
        ["@comment.documentation"] = { fg = "subtle", italic = true },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "rose-pine" },
  },
}
