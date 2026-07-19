-- No tab/buffer line at the top (showtabline = 0 alone won't hold because
-- bufferline forces it back on once multiple buffers are open).
return {
  "akinsho/bufferline.nvim",
  enabled = false,
}
