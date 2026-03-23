-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.editorconfig = 1 -- enable editorconfig
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.loaded_ruby_provider = 0  -- disable Ruby provider for cross-machine compatibility
vim.g.python3_host_prog = vim.fn.system("which python3"):gsub("\n", "")
vim.g.python_host_prog = vim.fn.system("which python"):gsub("\n", "")

local function executable(bin)
  return vim.fn.executable(bin) == 1
end

local function clipboard_provider()
  if vim.fn.has("macunix") == 1 and executable("pbcopy") and executable("pbpaste") then
    return {
      name = "pbcopy",
      copy = {
        ["+"] = "pbcopy",
        ["*"] = "pbcopy",
      },
      paste = {
        ["+"] = "pbpaste",
        ["*"] = "pbpaste",
      },
      cache_enabled = 0,
    }
  end

  if executable("wl-copy") and executable("wl-paste") then
    return {
      name = "wl-clipboard",
      copy = {
        ["+"] = "wl-copy --foreground --type text/plain",
        ["*"] = "wl-copy --foreground --primary --type text/plain",
      },
      paste = {
        ["+"] = "wl-paste --no-newline",
        ["*"] = "wl-paste --no-newline --primary",
      },
      cache_enabled = 0,
    }
  end

  if executable("xclip") then
    return {
      name = "xclip",
      copy = {
        ["+"] = "xclip -quiet -in -selection clipboard",
        ["*"] = "xclip -quiet -in -selection primary",
      },
      paste = {
        ["+"] = "xclip -o -selection clipboard",
        ["*"] = "xclip -o -selection primary",
      },
      cache_enabled = 0,
    }
  end

  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if ok then
    osc52.name = "osc52"
    osc52.cache_enabled = 0
    return osc52
  end
end

vim.g.clipboard = clipboard_provider()

-- Use the system clipboard whenever a provider is available.
vim.opt.clipboard = "unnamedplus"

vim.o.hlsearch = false -- disable highlight search
vim.o.jumpoptions = "view" -- stop jumping (this is Vim/Neovim default)
-- Set winbar to show relative path from current working directory
vim.o.winbar = "%=%m %{expand('%:.')}"
vim.o.wrap = true -- enable line wrap

vim.opt.hidden = false -- disable 'No Name' buffer
vim.opt.number = true -- Optionally, also enable absolute line numbers for the current line
vim.opt.relativenumber = true -- Enable relative line numbers
vim.opt.swapfile = false -- disable swapfile
