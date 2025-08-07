-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Remove LazyVim keybindings for <S>h, <S>m, <S>l
vim.keymap.del("n", "<S-h>")
vim.keymap.del("n", "<S-l>")

--- SEARCH ---
vim.keymap.set("n", "<Leader>og", function()
  require("fzf-lua").grep({ grep_open_files = true })
end, { noremap = true, silent = true })

vim.keymap.set("n", "<Leader>//", function()
  local dir = vim.fn.input("Search in dir: ", "./", "dir")
  if dir and dir ~= "" then
    require("fzf-lua").live_grep({ cwd = dir })
  end
end, { noremap = true, silent = true })

-- search resume
vim.keymap.set("n", "<Leader>rs", function()
  require("fzf-lua").resume()
end, { noremap = true, silent = true })

--- FILE PATHS ---

-- Copy file name
vim.keymap.set("n", "<Leader>fn", function()
  vim.fn.setreg("*", vim.fn.expand("%"))
  print(vim.fn.getreg("*"))
end, { noremap = true, silent = true })

-- Copy file relative path
vim.keymap.set("n", "<Leader>fy", function()
  vim.fn.setreg("*", vim.fn.expand("%:."))
  print(vim.fn.getreg("*"))
end, { noremap = true, silent = true })

-- Copy file full path
vim.keymap.set("n", "<Leader>ffy", function()
  vim.fn.setreg("*", vim.fn.expand("%:p"))
  print(vim.fn.getreg("*"))
end, { noremap = true, silent = true })

--- LSP ---

-- Virtual text: debug information
local virtual_text_enabled = true
vim.keymap.set("n", "<Leader>vt", function()
  virtual_text_enabled = not virtual_text_enabled
  vim.diagnostic.config({ virtual_text = virtual_text_enabled })
  print("virtual_text: " .. (virtual_text_enabled and "enabled" or "disabled"))
end, { noremap = true, silent = true })

-- Inlay hints: type information
local inlay_hints_enabled = true
vim.keymap.set("n", "<Leader>ih", function()
  inlay_hints_enabled = not inlay_hints_enabled
  vim.lsp.inlay_hint.enable(inlay_hints_enabled)
  print("inlay_hints: " .. (inlay_hints_enabled and "enabled" or "disabled"))
end, { noremap = true, silent = true })
