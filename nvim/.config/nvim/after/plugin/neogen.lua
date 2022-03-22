require('neogen').setup()

local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<Leader>ng', ':lua require("neogen").generate()<CR>', opts)
