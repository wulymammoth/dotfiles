# Codex Harness Pilot Implementation Plan

**Goal:** Make the accepted bounded-autonomy contract globally available and
prepare SoundCoaster for measured, low-prompt pilot runs without adding a custom
orchestrator.

**Architecture:** Dotfiles owns the cross-project safety contract through a
short global activation rule and one progressive-disclosure policy. Each pilot
repository owns its authority map and verification/evidence routing. Runs stop
at a preserved `LOCAL_READY` or `BLOCKED` worktree.

**Tech stack:** Markdown policy, GNU Stow, zsh regression tests, Git worktrees,
and SoundCoaster's existing pnpm verification contract.

## Global Constraints

- Do not modify installer-managed GSD, Superpowers, ctx, or Engram files.
- Do not create local commits unless the owner separately approves them.
- Do not push, mutate GitHub or Linear, merge, deploy, release, access
  production/providers, incur paid calls, or perform real-device/store actions.
- Preserve every unrelated dirty checkout and worktree.
- A pilot worktree must be owned by an existing or owner-approved Linear issue
  because SoundCoaster's merged worktree contract requires a canonical
  `lea-<number>-<slug>` branch.
- Documentation/tooling-only pilot preparation needs deterministic checks and a
  fresh diff review; it does not need UI, simulator, provider, or production
  evidence.

---

## Task 1: Track the Cross-Project Contract

**Files:**

- Create: `docs/codex-harness-autonomy.md`
- Create: `codex-config/.codex/policies/bounded-autonomy.md`
- Modify: `codex-config/.codex/AGENTS.md`
- Modify: `README.md`

**Produces:** An accepted design, a normative opt-in policy, and a concise
activation rule available to every Codex session without loading the detailed
policy by default.

- [x] Record the challenged decision, rejected alternatives, state machine,
  approval envelope, evidence classes, review rules, rollout, and success gate.
- [x] Add the bounded-autonomy activation rule after the normal development
  workflow so the default per-commit rule remains clear.
- [x] Document that `codex-config` now stows supporting policy documents while
  leaving `~/.codex` as a real private-state directory.
- [x] Run `git diff --check` and scan for contradictions between the concise and
  detailed policies.

## Task 2: Verify and Activate the Stow Package

**Files:**

- Create: `tests/codex-config-stow.zsh`

**Produces:** A regression check proving that Stow links the global policy and
supporting document without folding or disturbing private Codex state.

- [x] Build a temporary target containing a sentinel file under `.codex/`.
- [x] Stow `codex-config` with `--no-folding` into that target.
- [x] Assert that `.codex` remains a real directory, both tracked policy files
  resolve into this repository, and the sentinel is unchanged.
- [x] Assert `make stow-apply` and `make stow-list` retain the state-adjacent
  `codex-config` package contract.
- [x] Run `zsh tests/codex-config-stow.zsh`.
- [x] Run `make stow-preview`; inspect the proposed new policy link and reject
  any private-state change. Because the full target also previews unrelated
  package links, do not use the broad apply target for this change.
- [x] Run `stow --no-folding -v codex-config`, then confirm
  `~/.codex/policies/bounded-autonomy.md` resolves to the tracked source.

TDD note: the policy text is documentation, not application behavior. The Stow
packaging behavior receives a focused regression test before activation.

## Task 3: Prepare the SoundCoaster Pilot

**Precondition:** Refresh the local remote reference and fast-forward the clean
primary `main` to merged PR 42. Use an existing issue only if its scope owns this
work; otherwise obtain separate approval to create a narrowly scoped Linear
issue. Do not invent or reuse an unrelated issue number. The owner approved this
gate and `LEA-252` now owns the pilot.

**Historical owned state:** Worktree
`/Users/wulymammoth/Desktop/lab/soundcoaster/.worktrees/lea-252-codex-harness-pilot`
on branch `lea-252-codex-harness-pilot`;
`local_checkpoint_commits: forbidden`; `max_fix_rounds: 2`.

Task 3 predates the expanded envelope schema. Retrospectively, the active Codex
agent executed inline and no native Goal or retry was used. That classification
is not contemporaneous approval evidence and does not make this setup task a
qualifying run.

**Files:**

- Create: `docs/README.md`
- Modify: `AGENTS.md`

**Produces:** Progressive startup routing and an authority/verification map,
without rewriting historical context or adding speculative scripts.

- [x] Run `pnpm worktree:check` in the new worktree and stop on any failure.
- [x] Add a compact `docs/README.md` covering authority order, task-to-document
  routing, existing verification/runtime commands, and the distinction between
  current authority, continuation notes, and historical evidence.
- [x] Change startup instructions to read `docs/README.md`, inspect only
  task-relevant headings/sections of `README.md`, `main.md`, and
  `.Codex-context.md`, refresh Git/tracker state rather than trusting embedded
  state, and prefer the latest matching branch progress note.
- [x] Preserve the merged worktree and UI evidence rules unchanged.
- [x] Run `pnpm worktree:check`, `pnpm tooling:check`, and `git diff --check`.
- [x] Run a fresh diff review. Critical or Important findings block; fix and
  re-check at most twice.
- [x] Report `LOCAL_READY` with the worktree preserved. Do not commit, push,
  create a PR, or update Linear.

The first patch intentionally does **not** add `agent:status`, documentation
lint, a generic `agent:smoke`, scheduled PR polling, or an autopilot skill. Two
or three real medium-task pilots must show which of those mechanisms would
remove repeated friction before they are implemented.

## Task 4: Evaluate Real Runs

Before the first attempt, name the comparable pre-automation baseline and a
fixed escaped-defect observation window. If no comparable historical task
exists, use the first manual attempt as the baseline and do not make a promotion
claim until later comparable measurements exist.

For every attempted medium SoundCoaster task, including one that ends
`BLOCKED`, record:

- the approved goal, definition of done, base, worktree, branch, scope, commands,
  network reads, execution authority, commit setting, Goal mode/reference,
  retry policy, risk, evidence classes, fix cap, and prohibited actions;
- start/end time and terminal state;
- every owner intervention, classified as product/risk judgment or avoidable
  process friction;
- verification outcomes, retry attempts, review findings, repair rounds,
  runtime-evidence quality, residual debt, and cleanup required;
- any acceptance-criteria restatement, repeated request for required review or
  verification, escaped defect, scope escape, or unrelated-state disturbance.

Policy setup does not count. A run qualifies only when isolation and scope hold,
canonical verification and required evidence complete, a fresh review completes,
no unwaived Critical or Important finding remains at `LOCAL_READY`, and the
terminal report is accurate. Keep all attempts in the denominator. A scope or
worktree escape, unrelated-state disturbance, or unexplained policy failure
vetoes promotion until its root cause is fixed and a later qualifying run proves
the correction.

After two or three planned attempts:

1. Report the total attempt count, qualifying count, every blocker, and the
   baseline measurements; do not select only successful runs.
2. Identify friction that appeared in at least two recorded attempts with the
   same trigger, bounded input, and desired report-only output. Require at least
   two qualifying runs in the sample.
3. Reject a universal mechanism when the signal is limited to one path, risk
   class, provider, or repository.
4. Transfer-test the refined manual contract once in a less mature repository
   and confirm that the candidate friction generalizes.
5. Only then, under a separate approved plan, implement at most one thin
   report-only prototype.
6. Run one bounded canary that reaches `LOCAL_READY` and qualifies against the
   same baseline and observation window. Promote the prototype for reuse only if
   it removes the repeated process intervention without increasing defects,
   evidence ambiguity, cost, or cleanup.

Candidates remain conditional: repeated status-wait friction may justify an
event-driven report; repeated high-signal findings may justify scoped native
review; repeated documentation drift that escapes deterministic checks may
justify a report-only freshness audit. None may auto-write, submit a hosted
review, merge, deploy, or release.

## Task 5: Retire The Superseded SoundCoaster Proposal

The July 2026 multi-vendor governance proposal is historical, not an active
implementation plan. It produced no substantive external review and no CLI,
workflow, or repository integration. This design preserves its useful lessons:
separate authority from history, minimize reviewer inputs, isolate writable
state, and fail closed on unavailable evidence.

The unique payload is untracked and therefore is not protected by a
no-unique-commits check:

- `docs/agent-governance/architecture.md`
- `docs/agent-governance/memory-backend-evaluation.md`
- `docs/agent-governance/reviewer-protocol.md`
- `docs/agent-governance/security-model.md`
- `plans/agent-governance-setup.md`

Before any separate destructive-action approval, re-verify worktree
`/Users/wulymammoth/Desktop/lab/soundcoaster-agent-governance` and branch
`chore/agent-governance-planning` have no unique commits; record each untracked
file's exact path, size, and SHA-256; and obtain an explicit retain, archive, or
destroy disposition for each one. Also inventory the exact symlinks and targets
under `/private/tmp/soundcoaster-governance-bootstrap` and
`/private/tmp/soundcoaster-governance-review-tools`; these roots contain
dangling symlinks and are not empty. Remove only the paths named in that later
approval, and stop if any inventory has drifted. Do not merge or revive the
proposed coordinator, memory bakeoff, or multi-vendor quorum.
