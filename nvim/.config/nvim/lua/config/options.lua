-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.editorconfig = 1 -- enable editorconfig
vim.g.lazyvim_python_lsp = "pyright"
vim.g.lazyvim_python_ruff = "ruff_lsp"
vim.g.loaded_ruby_provider = 1
vim.g.python3_host_prog = vim.fn.system("which python3"):gsub("\n", "")
vim.g.ruby_host_prog = vim.fn.system("which ruby"):gsub("\n", "")

vim.o.hlsearch = false -- disable highlight search
vim.o.jumpoptions = "view" -- stop jumping (this is Vim/Neovim default)
vim.o.winbar = "%=%m %f" -- set the window bar to display relative path
vim.o.wrap = true -- enable line wrap

vim.opt.hidden = false -- disable 'No Name' buffer
vim.opt.number = true -- Optionally, also enable absolute line numbers for the current line
vim.opt.relativenumber = true -- Enable relative line numbers
vim.opt.swapfile = false -- disable swapfile
