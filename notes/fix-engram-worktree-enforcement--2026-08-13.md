# Engram Worktree Enforcement Handoff

Date: 2026-08-13

Status: **`LOCAL_READY_UNCOMMITTED`; verified locally and inactive**.

## Goal

Prevent concurrent Codex sessions from silently sharing Engram recovery context
after bypassing the prepared worktree launcher, without inventing a lossy merge
protocol or rolling back task-scoped containment.

## Decision

Retain one task, branch, linked worktree, active owner, and task-scoped Engram
project as the temporary isolation tuple. Enforce adoption with a read-only
startup guard, unique task projects, and a startup-checkout-only implementation
boundary. Do not automatically merge task projects into canonical memory.

Engram issue #587 remains the preferred future direction once implemented and
qualified: one logical project, per-worktree stores, fork points, and lossless
three-way merge.

## Implemented locally

- Added `worktree-session guard` with `COORDINATOR_ONLY`,
  `PREPARED_UNCLAIMED`, and `WRITER_BOUNDARY` classifications.
- Made unprepared linked checkouts and task-project/environment mismatches fail
  before mutation.
- Rejected duplicate `memory.taskProject` values at preparation and at every
  descriptor preflight so later drift also fails closed.
- Required workers to run `guard`, `claim`, `mem_current_project`, and `verify`
  before writing and after compaction or resume.
- Defined the Codex startup checkout as its only implementation root. A primary
  coordinator has only a narrow approved-plan and descriptor bootstrap
  exception across roots.
- Documented recovery for sessions that bypassed the helper.

## Existing-session recovery

For every affected active session:

1. Stop repository writes and record its exact root, branch, HEAD, porcelain
   status, current goal, verification state, and remaining work.
2. Leave uncommitted files in that linked worktree and exit the old thread.
3. Do not resume the old session ID. Prepare a unique descriptor for the
   existing worktree and launch a fresh helper-managed worker.
4. Reconcile the handoff against live Git and pass `guard`, `claim`,
   `mem_current_project`, and `verify` before another write.

Preserve already-interleaved canonical Engram entries as historical recovery
data; do not delete them or blindly merge task projects.

At the final read-only 2026-08-13 reconciliation, SoundCoaster contained no
`.superpowers/parallel/session.conf` files. The three affected linked worktrees
were still present and dirty:

- LEA-146 at `c16303b`: one modified design file;
- LEA-253 at `7eaa20f`: modified and untracked web UI, test, visual harness,
  and screenshot files;
- LEA-265 at `85d47a4`: two modified mobile files.

Two distinct live Codex code-mode sessions were still rooted at the
SoundCoaster primary checkout. This snapshot is recovery evidence, not current
authority; re-run Git and process checks before handoff or termination.

## Verification

Focused RED/GREEN cycles passed for the startup guard, duplicate-project
rejection, runtime drift, bootstrap prompt, and global-policy assertions.
The current tree then passed:

```text
zsh -n worktree-session and all four test scripts                 exit 0
zsh tests/codex-config-stow.zsh                                  PASS
zsh tests/parallel-worktree-session.zsh                          PASS
zsh tests/engram-task-project-isolation.zsh                      PASS
zsh tests/parallel-work-profile.zsh                              PASS
git diff --check                                                  exit 0
```

The profile suite still reports the honest
`PENDING_CANARY: no safe offline Codex surface proved hook suppression plus
policy and Superpowers loading`. This change does not claim new provider-backed
proof.

## Activation and approval gates

The implementation worktree is:

```text
/Users/wulymammoth/dotfiles/.worktrees/engram-worktree-enforcement
```

Branch `fix/engram-worktree-enforcement` remains based on
`8787192912319008592371f2cbfd26c5b0cb20b8`. No commit, integration, Stow
activation, provider canary, push, session termination, or cleanup is included
in the current authorization. Installed Stow links still resolve to the primary
`main` checkout, so these changes are not live.

The implementation plan is under the repository's ignored
`docs/superpowers/` rule. If the owner approves including it in the milestone
commit, stage that one plan explicitly with `git add -f`; do not broaden the
ignore rule or stage other ignored runtime artifacts.

## Relevant files

- `codex-config/.codex/skills/orchestrating-parallel-worktrees/scripts/worktree-session`
- `codex-config/.codex/skills/orchestrating-parallel-worktrees/SKILL.md`
- `codex-config/.codex/AGENTS.md`
- `tests/parallel-worktree-session.zsh`
- `tests/codex-config-stow.zsh`
- `docs/superpowers/specs/2026-08-08-parallel-codex-worktree-orchestration-design.md`
- `docs/superpowers/plans/2026-08-13-engram-worktree-enforcement.md`
