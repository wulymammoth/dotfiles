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

**Owned state:** Worktree
`/Users/wulymammoth/Desktop/lab/soundcoaster/.worktrees/lea-252-codex-harness-pilot`
on branch `lea-252-codex-harness-pilot`;
`local_checkpoint_commits: forbidden`; `max_fix_rounds: 2`.

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

For each of two or three later medium SoundCoaster tasks, record the approved
envelope, owner interventions, elapsed time, review findings, repair rounds,
runtime-evidence quality, residual defects, and cleanup required. Policy setup
does not count as a run. Afterward, decide whether one thin automation and a
report-only schedule have measurable value, then transfer-test the contract in a
less mature repository before changing the global default.
