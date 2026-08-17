# Simplified worktree memory policy handoff

Date: 2026-08-16

Status: **Implementation integrated locally and active for fresh sessions; this
milestone note is uncommitted.**

## Goal

Remove Engram task-project ceremony and automatic coordinator behavior from
ordinary single-task work while retaining deterministic checkout ownership,
explicit multi-writer coordination, and fail-closed integration safety.

## What works

- Ordinary single-owner task work uses one isolated worktree and one visible
  foreground Codex owner session without a descriptor, claim, plan digest,
  `mem_current_project`, or per-task Engram project.
- The tracked `parallel-work` profile disables both the Engram plugin and the
  Engram MCP server. Task sessions recover from their Codex transcript, live Git,
  and committed task-local plans or notes.
- Descriptor and claim machinery remains available only for explicit multi-writer
  orchestration. New descriptors use schema v2 and contain no memory fields.
- Existing schema-v1 descriptors remain supported through closeout. Their memory
  fields are parsed only for compatibility and are not injected into new Codex
  worker environments.
- Ownership, startup-checkout boundaries, integration ownership, and the separate
  commit, integration, push, activation, and cleanup gates remain enforced.

## Implementation and activation

The implementation was committed as
`d30c9c53ae637df4dbce6f9d58013693c17635d3` (`fix(codex): simplify worktree
memory policy`) on `fix/simplify-worktree-memory-policy` and integrated locally
to `main` at the same commit.

The installed Codex configuration and helper paths are Stow links into the
primary checkout, so the local `main` integration also activated the simplified
policy for fresh sessions. No additional Stow command was required.

## Verification

The committed implementation passed:

```text
zsh tests/codex-config-stow.zsh             PASS
zsh tests/parallel-work-profile.zsh         PASS
zsh tests/parallel-worktree-session.zsh     PASS
zsh tests/binstall.zsh                      PASS
git diff HEAD^ HEAD --check                 exit 0
```

Fresh independent review and scoped re-review found no remaining findings.
The profile suite still reports a `PENDING_CANARY` boundary because deterministic
local checks do not prove provider behavior. That optional canary is not required
for deterministic local closeout.

The schema-v1 completion report can show a stale target-base freshness SHA after
integration advances `main`. That is expected historical evidence and does not
need repair solely because integration moved the target branch.

## Next steps and separate gates

1. Review this note and obtain explicit approval before committing it on
   `fix/simplify-worktree-memory-policy`.
2. Integrate the note commit from a fresh session rooted at the primary checkout;
   the linked-worktree owner must not mutate the primary checkout cross-root.
3. Decide separately whether to push local `main` to `origin/main`.
4. From the linked-worktree owner session, release or hand off the descriptor
   claim. Then, with separate cleanup approval, remove the merged linked worktree
   and delete the merged task branch from the primary checkout.
5. Run the optional provider-backed canary only if separately approved.

Before any further write in the current schema-v1 worktree, reconcile live Git
and repeat `worktree-session guard`, `claim`, the exact Engram project check for
`dotfiles-simplify-worktree-memory-policy`, and mechanical verification.

## Relevant files

- `docs/superpowers/plans/2026-08-16-simplify-worktree-memory-policy.md`
- `codex-config/.codex/AGENTS.md`
- `codex-config/.codex/parallel-work.config.toml`
- `codex-config/.codex/skills/orchestrating-parallel-worktrees/SKILL.md`
- `codex-config/.codex/skills/orchestrating-parallel-worktrees/scripts/worktree-session`
- `tests/codex-config-stow.zsh`
- `tests/parallel-work-profile.zsh`
- `tests/parallel-worktree-session.zsh`
