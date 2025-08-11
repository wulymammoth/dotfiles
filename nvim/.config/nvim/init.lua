-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- disable perl provider to remove warnings
vim.g.loaded_perl_provider = 0

vim.cmd([[highlight Visual ctermfg=white ctermbg=black guifg=white guibg=black]]) -- set hightlight color and background
