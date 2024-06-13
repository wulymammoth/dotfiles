-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Remove LazyVim keybindings for <S>h, <S>m, <S>l
vim.keymap.del("n", "<S-h>")
vim.keymap.del("n", "<S-l>")

vim.keymap.set("n", "<Leader>og", function()
  require("telescope.builtin").live_grep({ grep_open_files = true })
end, { noremap = true, silent = true })

vim.keymap.set("n", "<Leader>/", function()
  require("telescope").extensions.live_grep_args.live_grep_args()
end, { noremap = true, silent = true })

----- FILE PATHS -----

-- copy file name
vim.api.nvim_set_keymap("n", "<Leader>fn", ':let @*=expand("%") <bar> :echo @*<CR>', { noremap = true, silent = true })
-- copy file relative path
vim.api.nvim_set_keymap("n", "<Leader>fy", ':let @*=expand("%p") <bar> :echo @*<CR>', { noremap = true, silent = true })
-- copy file full path
vim.api.nvim_set_keymap(
  "n",
  "<Leader>ffy",
  ':let @*=expand("%:p") <bar> :echo @*<CR>',
  { noremap = true, silent = true }
)

----- LSP -----

-- virtual text: debug information --
local virtual_text_enabled = true

function ToggleVirtualText()
  virtual_text_enabled = not virtual_text_enabled
  vim.diagnostic.config({
    virtual_text = virtual_text_enabled,
  })
  print("virtual_text: " .. (virtual_text_enabled and "enabled" or "disabled"))
end

vim.api.nvim_set_keymap("n", "<Leader>nv", ":lua ToggleVirtualText()<CR>", { noremap = true, silent = true })

-- inlay hints: type information --
local inlay_hints_enabled = true

function ToggleInlayHints()
  inlay_hints_enabled = not inlay_hints_enabled
  vim.lsp.inlay_hint.enable(inlay_hints_enabled)
  print("inlay_hints: " .. (inlay_hints_enabled and "enabled" or "disabled"))
end

vim.api.nvim_set_keymap("n", "<Leader>nh", ":lua ToggleInlayHints()<CR>", { noremap = true, silent = true })
