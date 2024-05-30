-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.cmd([[highlight Visual ctermfg=white ctermbg=black guifg=white guibg=black]])

vim.diagnostic.config({
  virtual_text = false, -- Disable inline diagnostics
  signs = true, -- Keep diagnostics in the gutter
  underline = true, -- Underline diagnostics in the code (optional)
  update_in_insert = false, -- Update diagnostics in insert mode (optional)
})

vim.o.hlsearch = false -- disable highlight search
vim.o.wrap = true

vim.opt.hidden = false -- disable 'No Name' buffer
vim.opt.number = true -- Optionally, also enable absolute line numbers for the current line
vim.opt.relativenumber = true -- Enable relative line numbers
vim.opt.swapfile = false -- disable swapfile
