---
name: orchestrating-parallel-worktrees
description: Use when coordinating two or more independent Codex writer sessions in linked Git worktrees, or when starting or resuming from .superpowers/parallel/session.conf.
---

# Orchestrating Parallel Worktrees

## Core boundary

Live Git plus the descriptor and owner claim are the multi-writer control
authority. During parallel work, the startup checkout is the only writable
checkout. Do not implement in another checkout through `workdir`, `git -C`, or absolute paths.

This skill is opt-in for two or more writer sessions, or mandatory when an
existing `.superpowers/parallel/session.conf` already selects the protocol. A
sole owner in a pre-created worktree does not need this skill, a descriptor, or
a claim.

Resolve the helper without changing `PATH`:
`session_helper="${CODEX_HOME:-$HOME/.codex}/skills/orchestrating-parallel-worktrees/scripts/worktree-session"`.

## Quick reference

| Role/state | Required action |
|---|---|
| Sole owner, no descriptor | Work in the startup checkout without this protocol |
| Coordinator before launch | Run `worktree-session guard`; keep `COORDINATOR_ONLY`; prepare and launch |
| Selected orchestration but unprepared worktree | Stop without writes; return preparation to the coordinator |
| Prepared writer before write | Guard, claim, and reconcile live state |
| Compacted or resumed writer | Repeat guard, claim, and live-state reconciliation |
| Active claim review | Remain read-only; send fixes to the owner or hand off explicitly |
| Completion | Produce a consistent report and preserve separate approval gates |

## Coordinator

1. Decompose only independent outcomes. Name dependencies, file ownership, the
   integration owner, reconciliation order, plans, and separate approval gates.
2. Run `worktree-session guard` from the primary checkout and keep its
   `COORDINATOR_ONLY` boundary. The only cross-root writes allowed before
   handoff are the approved plan and descriptor created during the narrow plan and descriptor bootstrap.
3. Run `$session_helper prepare` for each existing linked worktree and launch
   only through that helper. Once orchestration is selected, a missing or
   malformed descriptor is a blocker rather than permission to write.
4. Once claimed, stop writing there. Inspect a named commit or explicitly
   quiescent digest read-only; send fixes to the owner or hand off explicitly.
5. Never auto-integrate, activate, publish, write canonical memory, or clean up.

## Writer startup and recovery

Before repository mutation in a prepared multi-writer checkout: (1) invoke this
skill, (2) run `$session_helper guard`, (3) run `$session_helper claim`, (4)
reconcile the physical root, branch, HEAD, dirty state, active task, and owned
mutable artifacts, and (5) read current repository instructions and the approved
plan. After compaction or resume, repeat guard, claim, and reconciliation before
further work. Any mismatch produces `BLOCKED` without edits.

Schema-v2 descriptors contain no memory boundary. Existing schema-v1 descriptors
remain accepted until their work closes, but their legacy memory fields are only
structural compatibility data and are not injected into Codex. Transcript/resume,
live Git, and task-local plans or notes carry working context; historical lookup
never establishes current ownership.

Use SDD only when local checkpoint commits are authorized; otherwise use inline
execution. Never mutate another worktree or shared runtime.

Build verification commands for their declared interpreter. In zsh, the special
parameters `status` (read-only) and `path` (tied to `PATH`) can terminate a
wrapper or replace its executable search path. Use descriptive variables such as
`git_status_text` and `changed_paths_text`. Run Bash-specific multiline wrappers
explicitly with `bash` rather than through the default shell.

## Completion

Run approved verification and review, then create a consistent
`LOCAL_READY_COMMITTED`, `LOCAL_READY_UNCOMMITTED`, or `BLOCKED` report. Later
Git changes invalidate it. Hold the claim for read-only inspection; release or
hand off explicitly.

## Red flags

- “A task-ID prompt automatically makes me a coordinator.”
- “A sole-owner worktree needs a descriptor just because it is linked.”
- “I can reproduce an existing claim manually.”
- “The live branch changed, so update the descriptor and continue.”
- “The owner is stale because its PID is gone.”
- “Ready means the claim lifecycle is obvious.”

All mean stop and apply the correct boundary: ordinary sole ownership when no
orchestration exists, or the mechanical descriptor and claim protocol when it
does.

## Rationalizations

| Excuse | Reality |
|---|---|
| “A task-ID implies cross-root authority.” | It authorizes neither coordination nor writes in another checkout. |
| “A manual claim is equivalent.” | Only the helper proves the complete multi-writer boundary. |
| “A plausible rebase makes the mismatch safe.” | Descriptor mismatch means `BLOCKED` without edits. |
| “Silence or a dead PID permits takeover.” | Only explicit handoff or release transfers ownership. |
| “Local ready ends ownership automatically.” | Hold, hand off, or release the claim explicitly. |
