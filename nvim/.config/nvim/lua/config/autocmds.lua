-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.api.nvim_create_autocmd("FileType", {
  pattern = "codecompanion",
  callback = function(event)
    -- CodeCompanion chat buffers must be modifiable to accept input
    vim.bo[event.buf].modifiable = true
  end,
})
