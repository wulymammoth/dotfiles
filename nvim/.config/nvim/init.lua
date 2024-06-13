-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- set hightlight color and background
vim.cmd([[highlight Visual ctermfg=white ctermbg=black guifg=white guibg=black]])

vim.g.editorconfig = 1 -- enable editorconfig

vim.o.hlsearch = false -- disable highlight search
vim.o.winbar = "%=%m %f" -- Set the window bar to display relative path
vim.o.wrap = true -- enable line wrap

vim.opt.hidden = false -- disable 'No Name' buffer
vim.opt.number = true -- Optionally, also enable absolute line numbers for the current line
vim.opt.relativenumber = true -- Enable relative line numbers
vim.opt.swapfile = false -- disable swapfile
