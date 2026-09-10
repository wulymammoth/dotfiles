# Codex GSD retirement, 2026-09-10

The owner authorized local cleanup in `/Users/wulymammoth/dotfiles` through
`/private/tmp/codex-gsd-cleanup-handoff-2026-09-10/HANDOFF.md`. The startup checkout
was clean on `main` at `7d5464fc6656162d0119b4174befb40e77b0ff9e`. That commit
contains the five changes formerly uncommitted in the handoff; all five file
hashes matched. No patch replay, reset, or competing writer was needed.

## Applied scope

- Removed 31 `agents.gsd-*` registrations and archived 31 TOML plus 31 Markdown
  agent files outside discovery. Built-in `default`, `worker`, and `explorer`
  configuration remains untouched; no replacement catalog was added.
- Removed eight exact GSD hook entries: four PreToolUse, two PostToolUse, and two
  SessionStart. Preserved all `hooks.state` records. Archived nine hook files,
  including the unregistered statusline, the 185-file `get-shit-done` runtime,
  and its installation manifest. Registration counts do not prove past execution.
- Retained all 142 disabled GSD skill entries and their shared files under
  `~/.agents/skills` (74 top-level GSD directories, including the nested `gsd`
  tree). Claude's `~/.claude/skills/gsd` link uses that shared tree. No Codex-owned
  GSD skill directory remained to archive. Disabled Codex-oriented wrappers
  reference the archived runtime and require restoration before reuse.
- Restored global `gpt-6-astra` / `medium`: live reasoning was `high`, unlike the
  handoff snapshot. The existing Stow-linked `parallel-work` profile still
  inherits model/reasoning and retains its service-tier and Engram settings.
- Kept `scripts/codex-memory-policy.py` unchanged with its native API, version,
  path, provenance, and unrelated-setting safeguards. Profile verification now
  starts with a clean fixture; repair assertions moved from Stow checks to the
  dedicated repair suite. The existing native repair tests retain dry-run,
  apply, idempotence, instruction, and preservation coverage.
- Changed the launch/resume prompt to invoke the installed
  `orchestrating-parallel-worktrees` name. Guard, claim, handoff, ownership, and
  shared-runtime boundaries are unchanged.

## Private archive and restore

Archive: `~/.local/state/codex-archives/gsd-20260910T132014Z/`.
It contains 73 archived paths / 257 files, `manifest.json` with original locations
and SHA256 hashes, a private `config-before.toml`, `config-after.sha256`, and
`RESTORE.md`. The archive directory is mode 0700; the config backup is mode 0600.
A prior preflight-only backup at `gsd-20260910T131930Z` contains no moved runtime
files and was retained. Neither archive belongs in Git or a discovery directory.

Follow the archive's `RESTORE.md`: verify hashes, restore only to absent original
paths, then merge the selected GSD registrations through native `config/batchWrite`
with a fresh expected version. Do not overwrite the whole global config or
`hooks.state`; reconcile later user changes. Skill reactivation is a separate
explicit decision. Preserve shared installations and project history.

The native edit preserved all unrelated parsed configuration, including auth,
connectors, plugins, memory settings, skill disablements, and hook state. Hashes
confirmed 779 shared skill/Superpowers files unchanged, and the installed profile
link retained its destination. No project `.planning/` data or memory data was
modified.

## Evidence and limits

- Launcher regression: the revised expectation failed on the old skill name;
  the corrected launch/resume behavior passes the worktree-session suite.
- `zsh tests/parallel-work-profile.zsh` and `zsh tests/codex-config-stow.zsh`: pass.
- `zsh tests/parallel-worktree-session.zsh`: pass.
- Dedicated memory-policy suite: 24 tests pass. No repair implementation changes.
- Fresh native `config/read`: Astra/medium, no GSD agent tables. Filesystem
  verification: no GSD agent files, hook files, or Codex runtime remain active.
- Fresh native `skills/list` with reload: zero enabled GSD skills, all 14
  Superpowers skills enabled, zero discovery errors.
- No GSD hooks remain registered; `hooks.state` matches the private backup.
- Fresh `origin/main` equaled startup HEAD; no base divergence. `git diff --check`
  passed. Changes were local and uncommitted at the verification checkpoint.
  The owner subsequently authorized committing the cleanup and pushing `main`
  to `origin`; private configuration and archives remain outside Git. No plugin
  refresh was performed.

Sandboxed live app-server initialization failed because it could not initialize
Codex's SQLite state. The authorized native reads/write succeeded outside that
sandbox. Native reads normalize the legacy `guardian_subagent` reviewer alias to
`auto_review`; this normalization was accounted for without changing the raw
unrelated setting. Codex 0.154.0's schema has no standalone agent-list endpoint,
and app-server does not accept `--profile`. Profile checks therefore prove the
tracked overlay, native CLI parsing, retained MCP command/availability, and local
instruction rendering, without claiming a full worker launch or live hook canary.
This conversation retains its original advertised agent catalog. Its active
model/reasoning selector cannot be changed through the available tools; global
medium was verified, but session-only Astra/high was not independently verified.

[Official agent documentation](https://learn.chatgpt.com/docs/agent-configuration/subagents)
confirms standalone agent discovery and the three built-in roles.
[Official profile documentation](https://learn.chatgpt.com/docs/config-file/config-advanced#profiles)
explains the named file overlay and inheritance. These informed the cleanup;
installed native reads and local tests establish the reported machine state.
