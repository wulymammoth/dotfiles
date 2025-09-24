-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- ensure Neovim spawns pick up a usable Node.js for tree-sitter builds
if not vim.env.ASDF_NODEJS_VERSION or vim.env.ASDF_NODEJS_VERSION == "" then
  vim.env.ASDF_NODEJS_VERSION = "24.8.0"
end

-- disable perl provider to remove warnings
vim.g.loaded_perl_provider = 0

vim.cmd([[highlight Visual ctermfg=white ctermbg=black guifg=white guibg=black]]) -- set hightlight color and background
