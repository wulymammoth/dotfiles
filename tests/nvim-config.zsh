#!/usr/bin/env zsh

emulate -LR zsh
setopt errexit nounset pipefail

repo_root="${0:A:h:h}"
nvim_root="$repo_root/nvim/.config/nvim"

fail() {
  print -u2 -- "FAIL: $*"
  exit 1
}

lazy_config="$nvim_root/lua/config/lazy.lua"
plugins_dir="$nvim_root/lua/plugins"

rg -q 'version = false' "$lazy_config" \
  || fail "lazy.nvim must follow current plugin commits instead of stale tagged releases"
! rg -q 'version = "\\*"' "$lazy_config" \
  || fail "lazy.nvim must not globally constrain plugins to tagged releases"
rg -q 'checker = \{ enabled = true, notify = false \}' "$lazy_config" \
  || fail "the update checker should run without routine notification noise"

! rg -q 'lazyvim\.plugins\.extras\.' "$lazy_config" \
  || fail "lazyvim.json must be the single source of truth for enabled extras"

[[ ! -e "$plugins_dir/fzf-lua.lua" ]] \
  || fail "the local full FzfLua override must be removed in favor of LazyVim defaults"
[[ ! -e "$plugins_dir/refactoring.lua" ]] \
  || fail "the obsolete refactoring.nvim dependency workaround must be removed"
[[ ! -e "$plugins_dir/vim-fugitive.lua" ]] \
  || fail "Fugitive and Rhubarb must be removed in favor of Snacks gitbrowse and LazyGit"

! rg -q 'nvim-cmp|cmp-buffer|cmp-nvim-lsp|cmp-path|cmp_luasnip|telescope.nvim' \
  "$plugins_dir/disabled.lua" \
  || fail "disabled.lua must not retain exclusions already owned by LazyVim extras"

! rg -Fq 'opts.servers["*"].keys' "$plugins_dir/lsp.lua" \
  || fail "local LSP mappings must not override LazyVim FzfLua mappings"
! rg -Fq 'vim.list_extend' "$plugins_dir/lsp.lua" \
  || fail "local LSP mappings must not override LazyVim FzfLua mappings"

! rg -q 'ASDF_NODEJS_VERSION|/Users/wulymammoth' "$nvim_root/init.lua" \
  || fail "init.lua must not contain obsolete or machine-specific runtime paths"
! rg -q 'python_host_prog' "$nvim_root/lua/config/options.lua" \
  || fail "the removed Python 2 provider must not be configured"

rg -q "^brew 'neovim'$" "$repo_root/homebrew/Brewfile" \
  || fail "the Brewfile must install stable Neovim"
! rg -q "brew 'neovim'.*HEAD" "$repo_root/homebrew/Brewfile" \
  || fail "the Brewfile must not install Neovim HEAD"

fzf_exports="$repo_root/zsh/.exports"
! rg -Fq 'export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' "$fzf_exports" \
  || fail "FZF options must not multiply whenever a nested interactive shell starts"
rg -q "^export FZF_DEFAULT_OPTS='" "$fzf_exports" \
  || fail "FZF options must be assigned deterministically"

print -- "PASS: Neovim configuration follows current LazyVim ownership boundaries"
