return {
	{
		"hrsh7th/cmp-nvim-lsp",
		event = "InsertEnter",
	},
	{
		"hrsh7th/cmp-buffer",
		event = "InsertEnter",
	},
	{
		"hrsh7th/cmp-path",
		event = "InsertEnter",
	},
	{
		"hrsh7th/cmp-cmdline",
		event = "CmdlineEnter",
	},
	{
		"L3MON4D3/LuaSnip",
		event = "InsertEnter",
		dependencies = {
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()

			-- Web Development Snippets
			luasnip.add_snippets("typescript", {
				luasnip.snippet("us", { luasnip.text_node("const [, set] = useState()") }),
				luasnip.snippet("ue", { luasnip.text_node("useEffect(() => {\n  \n}, [])") }),
				luasnip.snippet("api", {
					luasnip.text_node(
						"async () => {\n  try {\n    \n  } catch (error) {\n    console.error(error);\n  }\n}"
					),
				}),
			})

			-- React Native Snippets
			luasnip.add_snippets("typescriptreact", {
				luasnip.snippet("rnstyle", { luasnip.text_node("const styles = StyleSheet.create({\n  \n})") }),
				luasnip.snippet("rncomp", {
					luasnip.text_node(
						"import React from 'react'\nimport { View, StyleSheet } from 'react-native'\n\nexport const Component = () => {\n  return (\n    <View style={styles.container}>\n      \n    </View>\n  )\n}\n\nconst styles = StyleSheet.create({\n  container: {\n    flex: 1,\n  },\n})"
					),
				}),
			})

			-- Python Snippets
			luasnip.add_snippets("python", {
				luasnip.snippet("adef", { luasnip.text_node("async def ") }),
				luasnip.snippet(
					"tryex",
					{ luasnip.text_node("try:\n    \nexcept Exception as e:\n    print(f'Error: {e}')") }
				),
			})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"onsails/lspkind.nvim",
			"windwp/nvim-autopairs",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")
			local autopairs = require("nvim-autopairs.completion.cmp")

			local has_words_before = function()
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered({
						winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
					}),
					documentation = cmp.config.window.bordered({
						winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
					}),
				},
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text",
						maxwidth = 50,
						ellipsis_char = "...",
						before = function(entry, vim_item)
							-- Show source name
							vim_item.menu = ({
								nvim_lsp = "[LSP]",
								luasnip = "[Snippet]",
								buffer = "[Buffer]",
								path = "[Path]",
							})[entry.source.name]
							return vim_item
						end,
					}),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{
						name = "nvim_lsp",
						priority = 1000,
						entry_filter = function(entry, ctx)
							local kind = require("cmp.types").lsp.CompletionItemKind[entry:get_kind()]
							if ctx.filetype == "markdown" then
								return true
							end
							return kind == "Function"
								or kind == "Method"
								or kind == "Class"
								or kind == "Module"
								or kind == "Variable"
								or kind == "Keyword"
						end,
					},
					{ name = "luasnip", priority = 750 },
					{ name = "buffer", priority = 500 },
					{ name = "path", priority = 250 },
				}),
				experimental = {
					ghost_text = true,
				},
			})

			-- Set up autopairs integration
			cmp.event:on("confirm_done", autopairs.on_confirm_done())

			-- Command line completion
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "cmdline" },
					{ name = "path" },
				},
			})

			-- Search completion
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})
		end,
	},
}
