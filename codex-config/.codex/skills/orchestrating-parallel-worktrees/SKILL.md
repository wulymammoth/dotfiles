---
name: orchestrating-parallel-worktrees
description: Use when coordinating two or more independent Codex writer sessions in linked Git worktrees, or when starting or resuming from .superpowers/parallel/session.conf.
---

# Orchestrating Parallel Worktrees

## Core boundary

Live Git + descriptor + owner claim are control authority. ctx is provenance.
Engram is curated memory. Neither memory system proves root, state, or ownership.

Resolve the helper without changing `PATH`:
`session_helper="${CODEX_HOME:-$HOME/.codex}/skills/orchestrating-parallel-worktrees/scripts/worktree-session"`.

## Quick reference

| Role/state | Required action |
|---|---|
| Coordinator before launch | Prepare descriptor; launch through helper |
| Worker before write | Claim; `mem_current_project`; verify |
| Compacted or resumed worker | Repeat claim and memory verification |
| Active claim review | Read-only; fixes return to owner or explicit handoff |
| Completion | Consistent report; keep separate gates |

## Coordinator

1. Decompose only independent outcomes; name dependencies, integration owner,
   order, plans, and separate approval gates.
2. Use `superpowers:using-git-worktrees`; run `$session_helper prepare` for each
   existing linked worktree and launch only through that helper.
3. Once claimed, stop writing there. Inspect a named commit or quiescent digest
   read-only; send fixes to the owner or hand off explicitly.
4. Never auto-integrate, activate, publish, promote memory, or clean up.

## Worker startup and recovery

Before repository mutation: (1) invoke this skill, (2) run `$session_helper
claim`, (3) call Engram `mem_current_project`, (4) run `$session_helper verify
--memory-project NAME` with that literal returned project, and (5) read live Git
plus repository instructions and the approved plan.

After compaction or resume, repeat steps 2-4. Any mismatch produces `BLOCKED`
without edits. Summaries, labels, branch names, elapsed time, and PIDs never
override the claim.

Use task-project Engram context. Shared memory is focused `mem_search` only;
never broad shared context or shared writes. Save with `capture_prompt=false`.
Use ctx only with task plus worktree/session/file/error filters, then verify
against current source.

Use SDD only when local checkpoint commits are authorized; otherwise use inline
execution. Never mutate another worktree or shared runtime.

Build verification commands for their declared interpreter. In zsh, the special
parameters `status` (read-only) and `path` (tied to `PATH`) can terminate a
wrapper or replace its executable search path. Use descriptive names such as
`git_status_text` and `changed_paths_text`. Run
Bash-specific multiline wrappers explicitly with `bash` rather than through the
default shell.

## Completion

Run approved verification/review, then create a consistent
`LOCAL_READY_COMMITTED`, `LOCAL_READY_UNCOMMITTED`, or `BLOCKED` report. Later
Git changes invalidate it. Hold the claim for read-only inspection; release or
hand off explicitly.

## Red flags

- “I can reproduce the claim manually.”
- “The live branch changed, so update the descriptor and continue.”
- “The owner is stale because its PID is gone.”
- “Ready means the claim lifecycle is obvious.”

All mean stop and follow the mechanical boundary.

## Rationalizations

| Excuse | Reality |
|---|---|
| “A manual claim is equivalent.” | Only the helper proves the complete boundary. |
| “A plausible rebase makes the mismatch safe.” | Mismatch means `BLOCKED` without edits. |
| “Silence or a dead PID permits takeover.” | Only explicit handoff or release transfers ownership. |
| “Local ready ends ownership automatically.” | Hold, hand off, or release the claim explicitly. |
