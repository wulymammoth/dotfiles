# Engram task-project launch remediation

## Goal

Close the provider-canary gap where the worker shell received the descriptor's
task project but the Codex-managed Engram MCP child still derived the shared Git
project. Preserve the no-fork architecture and all existing ownership,
instruction, hook-suppression, and verification gates.

## Verified state

- `worktree-session launch` and `resume` retain `ENGRAM_PROJECT` for worker-side
  verification and pass the same descriptor project through Codex's
  `mcp_servers.engram.env.ENGRAM_PROJECT` override.
- An explicitly supplied `ENGRAM_DATA_DIR` is optional, TOML-safe, normalized,
  and accepted only when it is an existing strict child of the task worktree.
- Exact stubbed launch/resume tests cover paths with spaces, quotes, and
  backslashes plus relative, outside, root, and symlink-escape failures.
- A provider-free `codex mcp list --json` probe confirms both per-launch values
  reach the Engram MCP server configuration.
- The design and durable context record runtime owner-thread identity, honest
  expected-versus-observed canary fields, and the default full-history reviewer
  fork contract.
- Fresh independent review found no Critical or Important issues. Its sole
  Minor stale cross-reference was corrected and the scoped re-review returned
  `APPROVED`.
- The implementation was committed on the remediation branch as `554107f`,
  integrated locally to `main` as `d423441`, and passed the full deterministic
  suite again after integration.

## Verification

The following passed from the isolated worktree on base
`ba54337298fefb5975b94b8e9ae52fdbb5fd49e0`:

```sh
zsh -n codex-config/.codex/skills/orchestrating-parallel-worktrees/scripts/worktree-session \
  tests/codex-config-stow.zsh tests/parallel-worktree-session.zsh \
  tests/engram-task-project-isolation.zsh tests/parallel-work-profile.zsh
zsh tests/codex-config-stow.zsh
zsh tests/parallel-worktree-session.zsh
zsh tests/engram-task-project-isolation.zsh
zsh tests/parallel-work-profile.zsh
```

The profile test still prints `PENDING_CANARY` because no offline Codex surface
proves the complete hook/instruction/skill behavior. Earlier live evidence
proved hook suppression, but the repaired task-project path itself has not yet
received a fresh provider-backed canary.

## Next steps and separate gates

The owner separately approved the implementation commit and its local
integration as `d423441`. The installed helper was already a Stow link to the
tracked dotfiles source, so integration also changed the live installed helper
without another Stow command. After that topology was discovered, the owner
chose to keep `d423441` and explicitly accepted the effective activation.

1. Preserve the isolated remediation worktree and verification evidence until
   cleanup is separately approved.
2. A fresh provider-backed canary, any remote push, and cleanup each remain
   separately gated. The accepted activation is not provider-behavior proof.

## Relevant paths

- Worktree: `.worktrees/engram-task-project-remediation`
- Branch: `fix/engram-task-project-remediation`
- Source commit: `554107f`
- Main integration commit: `d423441`
- Helper: `codex-config/.codex/skills/orchestrating-parallel-worktrees/scripts/worktree-session`
- Authoritative design: `docs/superpowers/specs/2026-08-08-parallel-codex-worktree-orchestration-design.md`
