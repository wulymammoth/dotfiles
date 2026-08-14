# Engram Worktree Enforcement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prevent a Codex session rooted in a primary checkout or an unprepared linked worktree from silently becoming a concurrent implementation writer, while preserving task-scoped Engram containment until upstream fork/merge support is available.

**Architecture:** Keep the accepted no-fork boundary: one task, branch, worktree, owner, and task-scoped Engram project. Add a read-only `guard` classifier at session startup, check task-project uniqueness against every linked worktree descriptor, and make the session-root/write boundary explicit in global policy. Do not merge task projects automatically; reviewed durable discoveries are promoted deliberately to canonical project memory.

**Tech Stack:** Zsh, Git worktree porcelain/config files, GNU Stow, shell regression tests, Markdown policy/design documentation.

## Global Constraints

- Work only in `/Users/wulymammoth/dotfiles/.worktrees/engram-worktree-enforcement` on `fix/engram-worktree-enforcement`, based on `8787192912319008592371f2cbfd26c5b0cb20b8`.
- Preserve the existing `parallel-work` profile and task-scoped `ENGRAM_PROJECT` launch boundary.
- Do not implement automatic Engram project merging or last-writer-wins reconciliation.
- Do not modify or terminate existing Codex sessions, SoundCoaster worktrees, hosted artifacts, trackers, or provider configuration.
- Local commits are forbidden until the owner separately approves the final verified diff and proposed commit message.
- Use TDD for helper and policy behavior: observe focused regression failures before implementation.

---

### Task 1: Fail-closed startup classification and task-project uniqueness

**Files:**
- Modify: `tests/parallel-worktree-session.zsh`
- Modify: `codex-config/.codex/skills/orchestrating-parallel-worktrees/scripts/worktree-session`

**Interfaces:**
- Consumes: existing descriptor schema v1, `current_root`, `descriptor_preflight`, and `memory.taskProject`.
- Produces: `worktree-session guard`; `assert_task_project_unique ROOT PROJECT`; stable outputs `COORDINATOR_ONLY`, `PREPARED_UNCLAIMED`, and `WRITER_BOUNDARY`.

- [x] **Step 1: Add failing guard regression cases**

  Add tests proving that `guard` classifies the primary checkout as coordination-only, rejects an unprepared linked worktree, rejects a prepared worktree without the task-project environment, reports a prepared unclaimed worker boundary, and rejects an owner mismatch.

- [x] **Step 2: Run the focused suite and verify RED**

  Run: `zsh tests/parallel-worktree-session.zsh`

  Expected: FAIL because `worktree-session` does not recognize `guard`.

- [x] **Step 3: Implement the minimal `guard` command**

  `guard` must be read-only. In a primary checkout it prints a coordination-only classification. In a linked worktree it requires a safe descriptor, exact branch/base/plan identity, the descriptor's `ENGRAM_PROJECT`, and—when an owner claim exists—the current `CODEX_THREAD_ID` to match it. It never creates a claim or descriptor.

- [x] **Step 4: Add failing uniqueness regression cases**

  Add two linked worktrees to one fixture. Prove that preparing the second descriptor with an already-used `memory.taskProject` fails, and that later descriptor drift to a duplicate makes the first worker's `guard`/`claim` preflight fail.

- [x] **Step 5: Run the focused suite and verify RED**

  Run: `zsh tests/parallel-worktree-session.zsh`

  Expected: FAIL because descriptors are not yet checked against sibling worktrees.

- [x] **Step 6: Implement task-project uniqueness checks**

  Parse `git worktree list --porcelain -z`, inspect only regular non-symlink sibling descriptors, and reject duplicate task projects with both physical roots in the error. Run the check during prepare and every descriptor preflight so post-launch drift fails closed.

- [x] **Step 7: Run the focused suite and verify GREEN**

  Run: `zsh tests/parallel-worktree-session.zsh`

  Expected: PASS with `PASS: parallel worktree session boundaries`.

### Task 2: Make the session-root boundary an explicit global contract

**Files:**
- Modify: `tests/codex-config-stow.zsh`
- Modify: `codex-config/.codex/AGENTS.md`
- Modify: `codex-config/.codex/skills/orchestrating-parallel-worktrees/SKILL.md`

**Interfaces:**
- Consumes: the new `worktree-session guard` classifications.
- Produces: a mandatory startup sequence for all linked worktrees and a prohibition on cross-worktree implementation from a primary coordinator session.

- [x] **Step 1: Add failing policy assertions**

  Require the global policy to name `worktree-session guard`, `COORDINATOR_ONLY`, the startup-root-only write boundary, the narrow plan/descriptor bootstrap exception, and the prohibition on using `workdir`, `git -C`, or absolute paths to implement in another checkout.

- [x] **Step 2: Run the policy suite and verify RED**

  Run: `zsh tests/codex-config-stow.zsh`

  Expected: FAIL on the first missing enforcement phrase.

- [x] **Step 3: Update global and skill guidance**

  Require `guard` whenever the current checkout is linked, whether or not a descriptor exists. Define primary checkout sessions as coordinators for parallel work, permit only plan/descriptor preparation before handoff, and require a fresh helper-launched writer for implementation. Preserve the active-conversation-over-recovery-memory precedence rule.

- [x] **Step 4: Run the policy suite and verify GREEN**

  Run: `zsh tests/codex-config-stow.zsh`

  Expected: PASS with `PASS: Codex global and progressive policy Stow package`.

### Task 3: Document the amended decision and operator recovery flow

**Files:**
- Modify: `README.md`
- Modify: `.Codex-context.md`
- Modify: `docs/superpowers/specs/2026-08-08-parallel-codex-worktree-orchestration-design.md`
- Create: `notes/fix-engram-worktree-enforcement--2026-08-13.md`

**Interfaces:**
- Consumes: tested guard behavior and upstream Engram issue #587's still-unimplemented fork/three-way-merge design.
- Produces: restart instructions and a durable distinction between temporary containment and final memory convergence.

- [x] **Step 1: Amend the durable design**

  Record that the original task-project mechanism remains valid containment, the observed incident was launcher bypass, linked worktrees share a canonical project under default Engram detection, and issue #587 is the preferred future same-project/data-directory fork plus three-way merge architecture once implemented and qualified.

- [x] **Step 2: Document existing-session recovery**

  Require each unsafe session to stop mutations, capture a Git-backed or chat handoff, exit without resuming the old thread, prepare a descriptor for the existing worktree, and launch a fresh session through the helper. State that uncommitted files stay in the worktree and the contaminated canonical memory is retained as historical recovery data rather than deleted or blindly merged.

- [x] **Step 3: Run documentation and full deterministic verification**

  Run:

  ```sh
  zsh -n codex-config/.codex/skills/orchestrating-parallel-worktrees/scripts/worktree-session \
    tests/codex-config-stow.zsh tests/parallel-worktree-session.zsh \
    tests/engram-task-project-isolation.zsh tests/parallel-work-profile.zsh
  zsh tests/codex-config-stow.zsh
  zsh tests/parallel-worktree-session.zsh
  zsh tests/engram-task-project-isolation.zsh
  zsh tests/parallel-work-profile.zsh
  git diff --check
  ```

  Expected: all suites PASS; the profile suite retains its honest `PENDING_CANARY` line because static checks do not prove provider behavior.

- [x] **Step 4: Stop at the commit gate**

  Review the complete diff, propose `fix(codex): enforce isolated worktree sessions`, and ask the owner for explicit commit approval. Do not commit, integrate, activate, push, terminate sessions, or clean worktrees in this task.
