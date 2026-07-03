local markdown_preview_refresh_events = {
	"CursorHold",
	"CursorHoldI",
	"CursorMoved",
	"CursorMovedI",
	"BufWrite",
	"InsertLeave",
}

local function clear_markdown_preview_refresh(bufnr)
	local group = "MKDP_REFRESH_INIT" .. bufnr

	for _, event in ipairs(markdown_preview_refresh_events) do
		pcall(vim.api.nvim_clear_autocmds, {
			group = group,
			buffer = bufnr,
			event = event,
		})
	end
end

local function with_buffer(bufnr, callback)
	if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
		return
	end

	vim.api.nvim_buf_call(bufnr, callback)
end

local function open_markdown_preview_once()
	local bufnr = vim.api.nvim_get_current_buf()

	vim.fn["mkdp#util#open_preview_page"]()

	-- markdown-preview.nvim has no no-refresh mode, so open/update once and
	-- remove only the refresh triggers while keeping close-on-exit behavior.
	for _, delay in ipairs({ 300, 1000 }) do
		vim.defer_fn(function()
			with_buffer(bufnr, function()
				pcall(vim.fn["mkdp#rpc#preview_refresh"])
			end)
		end, delay)
	end

	for _, delay in ipairs({ 500, 1500 }) do
		vim.defer_fn(function()
			clear_markdown_preview_refresh(bufnr)
		end, delay)
	end
end

return {
	{
		"iamcco/markdown-preview.nvim",
		build = "cd app && npm install --no-package-lock && git checkout -- yarn.lock",
		cmd = {
			"MarkdownPreview",
			"MarkdownPreviewOnce",
			"MarkdownPreviewStop",
			"MarkdownPreviewToggle",
		},
		ft = { "markdown" },
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreviewOnce<CR>", desc = "Open Markdown preview" },
			{ "<leader>ms", "<cmd>MarkdownPreviewStop<CR>", desc = "Stop Markdown preview" },
		},
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
			vim.g.mkdp_auto_start = 0
			vim.g.mkdp_auto_close = 1
			vim.g.mkdp_refresh_slow = 1
			vim.g.mkdp_combine_preview = 0
			vim.g.mkdp_combine_preview_auto_refresh = 0
			vim.g.mkdp_theme = "dark"
		end,
		config = function()
			vim.api.nvim_create_user_command("MarkdownPreviewOnce", open_markdown_preview_once, {
				desc = "Open Markdown preview without live refresh",
			})
		end,
	},
}
