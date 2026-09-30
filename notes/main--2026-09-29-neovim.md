# Neovim audit cleanup — 2026-09-29

## Scope and ownership

The user approved the preceding Neovim/LazyVim audit recommendations, then
clarified that LuaSnip is sometimes used, DAP is never used, Neotest has not been
used for a long while, and refactoring/Dadbod are occasionally used. Animation
and Neoconf have no known intentional use. Mason Swift/Xcode tools and oxfmt
have no known external use; independent Homebrew Swift tools must be preserved.

Single writer in the startup checkout `/Users/wulymammoth/dotfiles`, branch
`main`, initial HEAD `3a0dbfd2e632b94c67192730d6fef8e39eb40fa3`, initially clean.
No worktree orchestration, Git publication, credential change, or device action
was selected. `git fetch origin main` completed; origin/main and HEAD matched.

## What works

- Neovim 0.12.5 and LazyVim 16.0.1 were already current. Existing plugin revisions
  were retained; no broad plugin or language-tool update was performed.
- Expert inherits upstream `--stdio`, Surface filetypes, and umbrella-root
  handling, is managed by Mason, and is the sole enabled Elixir server.
  Installed ElixirLS is retained as a disabled fallback.
- BasedPyright no longer forces a startup interpreter or full-document sync.
  The Python extra retains BasedPyright/Ruff and venv-selector.
- Ruff organizes imports before formatting. The ineffective top-level Conform
  timeout was removed, preserving LazyVim's three-second effective default.
- DAP, Neotest, mini.animate and Neoconf extras were removed. LuaSnip, FzfLua,
  Blink/Copilot completion, refactoring and Dadbod remain enabled.
- Removed stale Neodev settings and the unused native-inline-completion hook.
- Replaced markdown-preview.nvim with live-preview.nvim; `<leader>cp` still
  toggles the browser preview and FzfLua remains the preview picker.
- The replacement plugin is installed in the active data tree at the verified
  revision `a6307fa`. The active configuration resolves 46 plugins, down from 60.
- Source changes remain uncommitted and reviewable. The local lazy lock is
  intentionally ignored by Git, as before.

## Verification

- `zsh tests/nvim-config.zsh`: PASS.
- `nvim -l tests/nvim-runtime.lua` with temporary log/state/cache: PASS against
  installed plugins. Initial regression run reproduced the missing stdio,
  forced Python interpreter, ineffective timeout and unused DAP configuration.
- LuaCheck on all Neovim Lua files and the runtime check: zero warnings/errors.
- Expert initialized over stdio against a disposable dependency-free Mix
  project; attached client list contained only Expert, without ElixirLS.
- BasedPyright resolved a package installed only in a disposable project's venv;
  BasedPyright and Ruff attached together, with no unresolved-import diagnostic.
- Real Ruff organized and formatted a fixture and was idempotent on a second run.
- Browser-preview shortcut started/stopped the actual loopback server and its
  HTML renderer returned HTTP 200. This proves server/shortcut integration;
  a visual browser comparison was not performed.
- The first cold Mix format timed out at a newly effective 1000 ms limit; a warm
  run passed. The override was removed rather than introducing that regression.
  Final formatter verification uses LazyVim's original 3000 ms default.
- The first disposable plugin setup used symlinks under lazy.nvim's managed
  directory, which lazy.nvim treated as uninstalled. Correcting the test-only
  local-plugin setup allowed the actual LSP integration checks to run.
- HTTP validation must send `Accept: text/html`; plain curl correctly receives
  raw Markdown and cannot establish that the HTML renderer is served.

## Outstanding installed cleanup

Two pre-existing Neovim processes (91747 and 91748) were open on
`/Users/wulymammoth/Desktop/lab/2026-09-09-soundcoaster-mobbin-ux-research.md`.
The user was asked to save and close these before removing installed artifacts.
They were not terminated by the agent. At this checkpoint cleanup is pending:
61 plugin directories remain installed, while the active configuration needs 46;
all 38 Mason packages remain installed.

Prepared cleanup removes these 15 obsolete plugin directories:
markdown-preview.nvim, mason-nvim-dap.nvim, mini.animate, neoconf.nvim, neotest,
neotest-elixir, neotest-python, neotest-rspec, nvim-dap, nvim-dap-python,
nvim-dap-ruby, nvim-dap-ui, nvim-dap-virtual-text, nvim-nio,
one-small-step-for-vimkind.

Prepared Mason cleanup removes these 9 unused packages:
typescript-language-server, js-debug-adapter, oxfmt, swiftformat, swiftlint,
xcbeautify, xcode-build-server, xcodegen, xcodeprojectcli.
Vtsls and disabled ElixirLS remain. Shell/config inspection found no references
to the Mason Swift tools; SwiftFormat, SwiftLint, XcodeGen and xcbeautify resolve
to independent `/opt/homebrew/bin` installations and are preserved.

## Continue

1. Reconcile root, HEAD, branch and dirty state. Existing authorization covers
   the named local cleanup; no Git delivery is authorized.
2. Verify the old editors have closed with a read-only host process check.
   Do not kill them or run cleanup while another Neovim process is open.
3. Check the prepared backups and manifest at
   `/tmp/neovim-audit-cleanup-20260929/`. They include original configuration,
   `mason-packages-backup.tar.gz` and `removed-plugins-backup.tar.gz`.
4. The prepared `/tmp/neovim-audit-cleanup-20260929/cleanup.lua` checks for other
   Neovim processes, the exact clean plugin list and clean Git checkouts before
   using Lazy clean and Mason's uninstall API. Run from the startup checkout,
   with host permissions for the approved local filesystem effects:

   ```sh
   NVIM_LOG_FILE=/tmp/neovim-audit-cleanup-20260929/cleanup.log \
     XDG_STATE_HOME=/tmp/neovim-audit-cleanup-20260929/cleanup-state \
     XDG_CACHE_HOME=/tmp/neovim-audit-cleanup-20260929/cleanup-cache \
     nvim -l /tmp/neovim-audit-cleanup-20260929/cleanup.lua
   ```

5. Verify 46 lock entries/installed plugins with matching clean HEADs, 29 Mason
   packages, no dangling managed links, unchanged Homebrew Swift tool paths,
   passing source/runtime checks and `git diff --check`. Update this record.
6. Restart Neovim to use the changed integrations. Existing processes retain
   their old loaded configuration.

Detailed local receipts and disposable fixtures are under
`/tmp/neovim-audit-cleanup-20260929/`; they are not durable release evidence.


## Startup regression follow-up — 2026-09-30

The user reported `Failed to run config for nvim-dap`, ending in a nonexistent
`setup` call. The active package cache still contained nvim-dap-python's
rockspec metadata, whose nested spec reintroduced nvim-dap after its extras
were removed. Optional language integrations then contributed options without
the DAP core configuration, causing Lazy's automatic `dap.setup(opts)` call.
The earlier runtime check disabled package metadata and missed this path.

- Added explicit exclusions for nvim-dap and nvim-dap-python in disabled.lua.
- The runtime check now includes the actual active package cache by default.
- Added a portable captured stale-cache fixture and a documented second test
  invocation so coverage survives removal of the old installed directories.
- Observed the real-cache regression fail before the fix and pass afterward.
- Normal headless startup with the copied real cache and normal package/rockspec
  handling passed with zero Lazy configuration errors and no DAP activation.
- The retained stale-cache fixture, existing configuration check and LuaCheck
  also passed; `git diff --check` was clean.
- A read-only host check confirmed the same two pre-existing editor processes
  remain open, so installed cleanup is still pending. Restart is needed to load
  the new source exclusions in existing processes.


## Delivery authorization — 2026-09-30

The user accepted the result and requested cleanup, commit and push. Destination
is the existing `main` branch on `origin`; no PR, merge or deployment is involved.
Final source checks passed, and a refreshed origin/main matched local HEAD.
Both backup archives were opened and checked against the exact cleanup manifest.
The first cleanup attempt after the user reported saving/closing the editors
stopped before any mutations because the original process pair remained on
terminal ttys011. Explicit permission to terminate that saved session was
requested; installed cleanup remains guarded until it exits.
