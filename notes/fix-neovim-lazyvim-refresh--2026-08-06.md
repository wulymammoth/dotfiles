# Neovim and LazyVim refresh — 2026-08-06

## What works

- Neovim remains on current stable 0.12.4 and LazyVim remains on 16.0.0.
- Stable 0.12.4 is now the only installed Homebrew Neovim keg. The separately
  approved quarantine-and-verify cleanup removed the inactive broken HEAD keg
  without changing the active binary, links, linkage, notifier behavior, or
  warm startup performance.
- lazy.nvim now follows current plugin commits instead of globally preferring
  stale tagged releases.
- Trouble is installed from current `main` at `bd67efe`, whose Treesitter
  decoration provider uses Neovim 0.12's `_on_range` callback. The minimal
  redraw reproduction that previously emitted repeated `trouble.treesitter`
  errors now completes with an empty Neovim log.
- Snacks notifier stores, displays, and renders a real TUI smoke notification.
- FzfLua uses the maintained LazyVim extra configuration; the three custom
  search mappings remain available after `VeryLazy`.
- LazyVim's FzfLua-backed `gd`, `gr`, and `gI` LSP mappings resolve after the
  base mappings instead of being overridden by local direct-buffer mappings.
- `FZF_DEFAULT_OPTS` is idempotent across repeated shell sourcing instead of
  duplicating its border and color arguments in each nested interactive shell.
- Fugitive, Rhubarb, Telescope, and nvim-web-devicons are absent from the active
  60-plugin lock and install tree. Snacks gitbrowse, LazyGit, FzfLua, and
  mini.icons provide their retained workflows.
- Every lock entry matches its installed Git HEAD, no lock entry or installed
  plugin directory is orphaned, and all managed plugin checkouts are clean.
- The approved cleanup removed the legacy `parser/` and `parser-info/`
  directories from the nvim-treesitter plugin checkout. The official
  synchronous update reports all parsers current without warnings. A separately
  approved cleanup also removed the obsolete site `jsonc.so`, its revision
  metadata, and its broken query symlink; current nvim-treesitter maps the
  `jsonc` filetype to the `json` parser.
- Warm headless startup measured 20.6–22.5 ms after the refresh, down from the
  pre-refresh audit sample of approximately 44.5 ms.

## Verification

- `tests/nvim-config.zsh`
- all repository Zsh tests; the SSH-agent test requires normal launchd access
  outside the filesystem sandbox
- `luacheck ... --globals vim` on changed and retained Neovim Lua files
- isolated fresh Lazy sync under `/tmp/codex-nvim-refresh-20260806`
- active `Lazy sync` and `Lazy update`
- current nvim-treesitter synchronous parser update script
- minimal Trouble/Treesitter redraw reproduction against isolated and active
  plugin data
- TUI Snacks notification history/render/window smoke test
- FzfLua health check outside the sandbox so its local RPC socket can start
- resolved plugin, keymap, lock-to-HEAD, orphan-directory, and dirty-checkout
  audits

## Next

- Restart existing Neovim processes so they load the updated Trouble module and
  refreshed configuration.
- The reviewed local commit and legacy plugin-directory cleanup were separately
  approved. The subsequent obsolete JSONC parser cleanup was also separately
  approved, as was the bounded broken Homebrew HEAD-keg cleanup. No push or pull
  request is included.

## Continue

1. Check `git status` on `fix/neovim-lazyvim-refresh`.
2. Re-run `/bin/zsh tests/nvim-config.zsh` and the active Trouble reproduction
   if any Neovim configuration changes.
3. Keep any push as a separate authorization gate.
