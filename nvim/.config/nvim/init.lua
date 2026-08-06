-- Ensure user-installed binaries are available to plugins and spawned processes.
local local_bin = vim.fn.expand("~/.local/bin")
local path = vim.env.PATH or ""
if not vim.tbl_contains(vim.split(path, ":", { plain = true }), local_bin) then
  vim.env.PATH = local_bin .. ":" .. path
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.cmd([[highlight Visual ctermfg=white ctermbg=black guifg=white guibg=black]]) -- set hightlight color and background
