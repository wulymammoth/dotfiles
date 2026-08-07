# Concurrent Codex Session Coordination — 2026-08-07

## Working State

- Branch/worktree: `docs/concurrent-codex-session-coordination` at
  `/private/tmp/dotfiles-concurrent-session-coordination`.
- LEA-254 tracks the cross-repository policy and SoundCoaster specialization.
- The owner approved the local checkpoint commit. Push, live Stow mutation, and
  GitHub mutation remain unapproved.

## Decisions

- Global policy permits one active writer session per writable checkout/branch
  and mutable hosted artifact. Its executor may dispatch scoped workers and
  retains integration responsibility; review verdicts require a named commit or
  explicitly quiescent checkpoint.
- Shared runtimes remain exclusive unless isolation is proven.
- High-overlap work uses a named integration owner rather than blanket
  serialization.
- Post-compaction summaries are reconciled with live provenance before action.
- No mutable session lease registry is introduced.

## Verification

- `zsh tests/codex-config-stow.zsh` passes.
- `git diff --check` passes.

## Next Step

Record the approved local checkpoint, then request separate push and PR
authorization.

## Canonical Pointers

- `codex-config/.codex/AGENTS.md`
- `docs/codex-harness-autonomy.md`
