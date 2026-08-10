# Parallel Codex Worktree Handoff

Date: 2026-08-10

Status: **Locally integrated and active; real-task qualification pending.**

## Goal

Preserve the current, evidence-backed state of the no-fork parallel Codex
worktree foundation so a new human or Codex session can resume without treating
Engram, ctx, a stale note, or a terminal label as current ownership.

## Authoritative current state

- The foundation checkpoint immediately before this handoff was `6b4889f`
  (`fix(codex): guard zsh reserved parameters in parallel work`). Commit
  `fcffc17` introduced this note; reconcile live Git before relying on either
  dated checkpoint.
- The operating invariant is one task, task branch, linked worktree, active
  top-level writer, and task-scoped Engram project. An integration owner is
  required before overlapping results are reconciled.
- Live Git plus the prepared descriptor and owner claim control writes. ctx is
  task-qualified provenance; Engram is curated memory. Neither memory system
  grants ownership or proves current checkout state.
- The tracked [`worktree-session`](../codex-config/.codex/skills/orchestrating-parallel-worktrees/scripts/worktree-session)
  helper owns prepare, claim, verification, launch/resume, completion, handoff,
  release, and read-only integration checks.
- The tracked [global instructions](../codex-config/.codex/AGENTS.md),
  [parallel-work profile](../codex-config/.codex/parallel-work.config.toml), and
  [orchestration skill](../codex-config/.codex/skills/orchestrating-parallel-worktrees/SKILL.md)
  are active through Stow links. New Codex sessions load the current sources;
  already-running sessions may retain older instructions.
- No evidence justifies an Engram or Superpowers fork. The failures observed in
  provider-backed runs were canary construction, run-contract, working-directory,
  conflict-envelope, or shell-command failures rather than cross-task memory or
  provenance leakage.
- Linear LEA-252 and LEA-254 are completed historical trackers. Do not reopen or
  reuse them for a future product-task pilot. A real pilot should be owned by
  the actual tasks selected from the relevant repository backlog.
- Immediately before `fcffc17`, local `main` was ten commits ahead of the
  cached `origin/main`. The count changed when this handoff was committed and
  can change again, so compute it from live refs. Fetch/reconciliation and push
  are separate approval gates; the cached remote ref is not proof of current
  hosted state.

The durable architecture and approval model remain in
[`docs/codex-harness-autonomy.md`](../docs/codex-harness-autonomy.md). The older
[`2026-08-08 orchestration note`](docs-parallel-worktree-orchestration-design--2026-08-08.md)
is a historical pre-activation checkpoint, not the current run state.

## Evidence and current verdict

### Deterministic foundation

The following suites pass on integrated `main`:

```sh
zsh tests/codex-config-stow.zsh
zsh tests/parallel-worktree-session.zsh
zsh tests/parallel-work-profile.zsh
git diff --check
```

The helper and tests establish exact root/branch/base/plan identity, atomic
thread-owned claims, task-project MCP overrides, strict completion evidence,
and fail-closed handoff and release behavior. The profile test intentionally
retains its static `PENDING_CANARY` message because static configuration cannot
prove provider behavior.

### Provider-backed evidence

Three disposable runs produced useful but deliberately non-qualifying evidence:

1. **A9C3224F:** task-project process overrides, decoy rejection, hidden-context
   suppression, hook suppression, ownership, child lineage, committed Alpha,
   and isolated uncommitted Beta behavior passed. The run was `BLOCKED` because
   its literal zero-retry envelope was breached and downstream resume and
   integration proof did not run.
2. **0399eddb:** task-project and ownership isolation held. The run was
   `BLOCKED` when an Alpha child used the canary root instead of its exact
   worktree and Beta treated a normal Engram `judgment_required` envelope as a
   fatal error.
3. **Thin pilot 053504:** both independent writers selected their correct task
   projects and remained isolated, but both generated zsh wrappers that assigned
   to read-only `status`. The stable guard at `6b4889f` now requires descriptive
   variables such as `git_status_text` and explicit Bash for Bash-specific
   multiline wrappers.

These runs support the no-fork design. They do **not** prove unattended
end-to-end parallel development, same-thread resume, automatic integration, or
production readiness. Do not run another synthetic mega-canary merely to
accumulate evidence.

## Crash, compaction, or restart recovery

### What persists

- Git commits, branches, linked worktrees, tracked and untracked diffs, prepared
  descriptors, owner claims, completion reports, and retained local evidence
  remain on disk unless explicitly removed.
- Engram observations and summaries persist, and ctx can recover source-session
  provenance after its index is current.
- A crash does not automatically commit, merge, push, release a claim, transfer
  ownership, activate hosted state, or clean anything up.

### Required first actions

Start from current source rather than this snapshot alone:

```sh
repo_root=/Users/wulymammoth/dotfiles
git -C "$repo_root" branch --show-current
git -C "$repo_root" rev-parse HEAD
git -C "$repo_root" status --short --branch
git -C "$repo_root" worktree list --porcelain
```

Then:

1. Identify the exact task worktree and branch. Inspect `README.md`, the
   branch-named Markdown file, `Codex.local.md`, and `.Codex-context.md` when
   present.
2. Call Engram `mem_context` for recovery. Use focused `mem_search` only when
   needed, and verify every retrieved claim against current Git and source.
3. Use ctx with concrete identifiers such as the task ID, branch, worktree,
   filename, error, commit, or canary ID and a small result limit. Inspect a
   focused event window rather than treating a transcript summary as authority.
4. If `.superpowers/parallel/session.conf` exists, invoke the orchestration
   skill, repeat the helper claim, call `mem_current_project`, and pass that
   literal result to helper verification before the next write.
5. Re-read any active plan or bounded envelope and its remaining approval
   gates. Never infer authority from elapsed time, a dead PID, a branch label,
   or an apparently abandoned claim.

At initial authoring, and only while no approved handoff-note commit exists, the
prepared recovery point is:

```text
worktree: /Users/wulymammoth/dotfiles/.worktrees/parallel-worktree-handoff
branch: docs/parallel-worktree-handoff
base: 6b4889fab410ea16b88c1aee85cfdb5a3c8c7736
expected changed path: notes/docs-parallel-worktree-handoff--2026-08-10.md
commit authority: not granted until the owner explicitly approves it
```

If a later approved commit or integration exists, reconcile it from live Git
and its approval record instead of forcing this pre-commit snapshot. Otherwise,
if any identity, ownership, scope, or diff check disagrees with this recovery
point, stop `BLOCKED` and report the mismatch. Do not reset, overwrite, release,
or clean state merely to make the snapshot match.

## Next controlled pilot

Use two existing, low-risk development tasks whose code and runtime scopes do
not overlap. Formal tracker IDs are useful when the repository requires them,
but named tasks are otherwise sufficient; do not invent meta-issues solely for
validation.

For each task:

1. Create one task branch, linked worktree, top-level writer, and task-scoped
   Engram project.
2. Launch with the tracked helper and exact absolute worktree. Start fresh
   Codex sessions so they load the active instructions.
3. Allow at most one explicitly bounded self-correction for the named
   deterministic failure classes; record interventions rather than silently
   retrying.
4. Keep integration read-only until both task results are quiescent and the
   owner separately approves reconciliation.
5. Treat any cross-task memory, prompt, provenance, ownership, file, or runtime
   leakage as a veto. Ordinary task bugs do not by themselves justify a fork.

## Remaining approval gates

This note grants none of the actions below. Reconcile whether a later explicit
approval already completed one before treating it as pending:

- commit and locally integrate this handoff note;
- fetch/reconcile and push the ten local dotfiles commits;
- comment on Linear LEA-254 for optional historical discoverability;
- choose and launch the two real pilot tasks;
- run provider-backed sessions or access shared runtimes;
- release retained claims or remove any canary, branch, worktree, database, or
  private evidence.

No tracker mutation, hosted action, push, provider call, or cleanup is implied
by this note.

## Retained local evidence

The current machine retains the disposable run roots below. They are useful
diagnostic evidence, not repository authority, and their existence must be
rechecked before use:

```text
/private/tmp/parallel-adversarial-canary-a9c3224f
/private/tmp/parallel-adversarial-canary-0399eddb
/private/tmp/parallel-thin-pilot-053504
```

Each run's `.canary-evidence/TERMINAL-REPORT.md` is its terminal verdict. Keep
the run roots unchanged unless the owner separately approves cleanup.
