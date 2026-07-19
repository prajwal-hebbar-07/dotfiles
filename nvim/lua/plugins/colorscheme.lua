-- Tokyo Night (night), fully transparent + enriched syntax highlighting.
--
-- transparent = true clears the editor AND every float, so wezterm's blur shows
-- through everywhere — no per-plugin surface patching. styles.floats/sidebars
-- pin the picker, which-key, explorer, notifier, etc. to transparent too.
-- on_highlights adds extra treesitter colors on top of tokyonight's defaults and
-- force-clears the snacks/which-key backgrounds as belt-and-suspenders.
return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
        comments = { italic = true },
        keywords = { italic = true },
      },
      on_highlights = function(hl, c)
        -- Belt-and-suspenders: keep all floating UI see-through even if a
        -- plugin integration sets its own background.
        hl.NormalFloat = { bg = "none" }
        hl.FloatBorder = { fg = c.blue, bg = "none" }
        for _, g in ipairs({
          "SnacksPickerBox",
          "SnacksPickerList",
          "SnacksPickerInput",
          "SnacksPickerPreview",
          "SnacksNormal",
          "WhichKeyNormal",
          "TelescopeNormal",
          "BlinkCmpMenu",
          "NoiceCmdlinePopup",
        }) do
          hl[g] = { bg = "none" }
        end
        hl.SnacksPickerBorder = { fg = c.blue, bg = "none" }
        hl.WhichKeyBorder = { fg = c.blue, bg = "none" }

        -- Extra syntax richness on top of tokyonight's palette.
        hl["@type.builtin"] = { fg = c.cyan, italic = true }
        hl["@type.parameter"] = { fg = c.magenta } -- generics <T>
        hl["@constructor"] = { fg = c.cyan }
        hl["@module"] = { fg = c.cyan } -- Go packages, TS namespaces
        hl["@lsp.type.enumMember"] = { fg = c.orange }
        hl["@keyword.import"] = { fg = c.cyan }
        hl["@keyword.exception"] = { fg = c.red }
        hl["@keyword.return"] = { fg = c.magenta, italic = true }
        hl["@keyword.coroutine"] = { fg = c.magenta, italic = true } -- async/await
        hl["@variable.member"] = { fg = c.green1 } -- obj.field
        hl["@variable.builtin"] = { fg = c.red } -- this / self
        hl["@property"] = { fg = c.green1 }
        hl["@attribute"] = { fg = c.orange } -- decorators, JSX/HTML attrs
        hl["@tag.attribute"] = { fg = c.orange }
        hl["@tag.builtin"] = { fg = c.blue, bold = true }
        hl["@string.escape"] = { fg = c.magenta }
        hl["@string.special.url"] = { fg = c.cyan, underline = true }
        hl["@punctuation.special"] = { fg = c.magenta } -- template ${}, JSX braces
        hl["@boolean"] = { fg = c.orange }
        hl["@number.float"] = { fg = c.orange }
        hl["@comment.documentation"] = { fg = c.yellow, italic = true }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "tokyonight" },
  },
}
