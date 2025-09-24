# Neovim Tree-sitter Node Version Issue

## Summary
Neovim's Treesitter installer failed when compiling the `heex` parser with the error:

```
[nvim-treesitter/install/heex] error: Error during "tree-sitter build": No version is set for command tree-sitter
Consider adding one of the following versions in your config file at ~/.cache/nvim/tree-sitter-heex/.tool-versions
nodejs 24.8.0
nodejs 22.19.0
nodejs 23.7.0
```

The problem was triggered by the Treesitter grammar checkout keeping a tracked `.tool-versions` file containing `nodejs lts`. Asdf no longer supports non-deterministic entries like `lts` in `.tool-versions`, so whenever Treesitter ran, it looked for a Node alias that didn't exist and refused to run the shimmed `tree-sitter` CLI.

## Fix
1. Install an actual LTS version of Node via asdf (22.19.0) so the alias can point to something concrete:
   ```bash
   asdf install nodejs 22.19.0
   npm_config_prefix=$HOME/.asdf/installs/nodejs/22.19.0 ASDF_NODEJS_VERSION=22.19.0 npm install -g tree-sitter-cli
   asdf reshim nodejs
   ```
   This provides `tree-sitter` binaries for the 22.x LTS line, keeping compatibility with the `nodejs lts` hint.

2. Ensure Neovim sessions export a known Node version so the shim resolves consistently even when Treesitter rewrites `.tool-versions` during updates:
   ```lua
   -- ~/.config/nvim/init.lua
   if not vim.env.ASDF_NODEJS_VERSION or vim.env.ASDF_NODEJS_VERSION == "" then
     vim.env.ASDF_NODEJS_VERSION = "24.8.0"
   end
   ```

## Notes
- The parser checkout under `~/.cache/nvim/tree-sitter-heex` is a git repository. Resets happen on each update, so manual edits to `.tool-versions` will be reverted. The environment override avoids the need to change those files.
- `tree-sitter --version` now resolves inside Neovim and on the command line.
- If you switch your preferred Node version, update both the installed LTS version and the override in `init.lua` to match.
