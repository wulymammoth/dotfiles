-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Remove LazyVim keybindings for <S>h, <S>m, <S>l
vim.keymap.del("n", "<S-h>")
vim.keymap.del("n", "<S-l>")

vim.keymap.set("n", "<leader>og", function()
  require("telescope.builtin").live_grep({ grep_open_files = true })
end, { noremap = true, silent = true })

vim.keymap.set("n", "fg", function()
  require("telescope").extensions.live_grep_args.live_grep_args()
end, { noremap = true, silent = true })

----- file paths -----
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
