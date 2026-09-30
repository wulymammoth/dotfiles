# Neovim / LazyVim

Stow links this directory to `~/.config/nvim`. Enabled integrations live in
`lazyvim.json`; local plugin files contain only preferences and narrow overrides.

- Elixir uses Expert with upstream stdio and umbrella-project defaults.
  ElixirLS may remain installed as a fallback, but is disabled.
- Python uses BasedPyright and Ruff. Configure the environment in the project
  or use `<leader>cv` (`:VenvSelect`); the editor does not pin an interpreter
  when it starts. Ruff organizes imports before formatting.
- Markdown browser preview uses live-preview.nvim. `<leader>cp` toggles the
  preview; `:LivePreview start`, `close`, and `pick` are also available.
- FzfLua, Blink/Copilot menu completion, LuaSnip, refactoring, and Dadbod remain
  enabled. DAP, Neotest, animation, and Neoconf extras are not enabled.

For configuration checks from the dotfiles repository:

```sh
zsh tests/nvim-config.zsh
NVIM_LOG_FILE=/tmp/nvim-runtime.log nvim -l tests/nvim-runtime.lua
NVIM_RUNTIME_PKG_CACHE="$PWD/tests/fixtures/nvim-stale-dap-pkg.lua" \
  NVIM_LOG_FILE=/tmp/nvim-runtime.log nvim -l tests/nvim-runtime.lua
```

The Lua check requires the configured plugins to be installed. It resolves real
LazyVim options but disables plugin installation and update checks and does not
start language servers. The second Lua invocation verifies that stale package
metadata cannot revive the removed debugger integration.

[LazyVim documentation](https://www.lazyvim.org/)
