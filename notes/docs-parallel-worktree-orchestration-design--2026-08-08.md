# Parallel Codex Worktree Orchestration Progress

Date: 2026-08-09

Design status: **Implemented locally; activation and adversarial canary
pending**.

## Scope and revisions

- Worktree: `/Users/wulymammoth/dotfiles/.worktrees/parallel-worktree-orchestration-design`
- Branch: `docs/parallel-worktree-orchestration-design`
- Base: `727ecc4466c092d1c7a401a475f4488a59ae5666`
- Current HEAD: `08a3bee6f04d983dfdd794ba17ff9d705cdb08c1`
- Foundation checkpoint: `f33d585` — deterministic profile, helper, and tests
- Skill checkpoint: `08a3bee` — provider-tested skill, scenarios, evidence,
  and packaging regression

No Engram or Superpowers source was changed. The implementation remains in the
isolated dotfiles worktree.

## Evidence obtained

### Deterministic foundation

The complete Tasks 1-8 local gate ran from the isolated worktree:

```sh
zsh -n codex-config/.codex/skills/orchestrating-parallel-worktrees/scripts/worktree-session
zsh -n tests/codex-config-stow.zsh tests/parallel-worktree-session.zsh tests/engram-task-project-isolation.zsh tests/parallel-work-profile.zsh
zsh tests/codex-config-stow.zsh
zsh tests/parallel-worktree-session.zsh
zsh tests/engram-task-project-isolation.zsh
zsh tests/parallel-work-profile.zsh
wc -w codex-config/.codex/skills/orchestrating-parallel-worktrees/SKILL.md
rg -n '^name: orchestrating-parallel-worktrees$|^description: Use when' codex-config/.codex/skills/orchestrating-parallel-worktrees/SKILL.md
git diff --check
```

Results:

- Stow packaging: PASS
- parallel worktree session boundaries: PASS
- Engram process-level task projects are isolated: PASS
- profile syntax and base MCP retention: PASS
- skill length: 466 words; frontmatter discovery checks: PASS
- whitespace checks: PASS
- profile hook behavior:
  `PENDING_CANARY: no safe offline Codex surface proved hook suppression plus policy and Superpowers loading`

These are deterministic/provider-free proofs. The profile result is not live
hook-behavior proof.

### Provider-backed skill evaluation

The owner authorized exactly 22 fresh-context runs. Evidence is retained in
`docs/superpowers/evals/2026-08-08-parallel-worktree-orchestration-skill.md`:

- RED pressure scenarios: 6 runs, 2 PASS / 4 FAIL
- wording micro-tests: 5 controls at 0/5 exact; 5 guided at 5/5 exact
- GREEN pressure scenarios: 6 runs, 6 PASS / 0 FAIL
- retries: 0
- evaluated-agent repository or hosted mutations: 0

A fresh independent review found no Critical, Important, or Minor findings.
The retained record contains the plan-required scoring and short quotations,
not full replayable provider transcripts.

### Task 9 policy regression

The new assertions were run before policy changed:

```sh
zsh tests/codex-config-stow.zsh
```

Expected RED:

```text
FAIL: global AGENTS policy is missing: .superpowers/parallel/session.conf
```

After adding the concise prepared-session rule, the same command returned:

```text
PASS: Codex global and progressive policy Stow package
```

### Final Task 9 deterministic verification

The exact Task 9 command set ran from the isolated worktree:

```sh
zsh -n codex-config/.codex/skills/orchestrating-parallel-worktrees/scripts/worktree-session
zsh -n tests/parallel-worktree-session.zsh
zsh -n tests/engram-task-project-isolation.zsh
zsh -n tests/parallel-work-profile.zsh
zsh tests/parallel-worktree-session.zsh
zsh tests/engram-task-project-isolation.zsh
zsh tests/parallel-work-profile.zsh
zsh tests/codex-config-stow.zsh
! rg -n '(^|[^[:alnum:]_])eval([^[:alnum:]_]|$)' codex-config/.codex/skills/orchestrating-parallel-worktrees/scripts/worktree-session
git diff --check
git status --short --branch
git status --short --ignored
```

Result: `TASK9_FINAL_DETERMINISTIC_PASS`. All four suites passed, syntax checks
passed, the helper contains no shell `eval`, and diff checks passed. The profile
again returned the literal `PENDING_CANARY` boundary above.

### Goal-backward review and durable memory

A fresh high-capability read-only review returned `LOCAL_READY_DOCS` with zero
Critical, Important, or Minor findings. Acceptance criteria 1–3, 5–8, and 10
passed; criteria 4 and 9 remain `PENDING_APPROVED_GATE`. Deterministic cases
1–16 passed; case 17 remains `PENDING_APPROVED_GATE` because no offline surface
proves live hook suppression.

The review also confirmed that no Engram or Superpowers source changed, wrong
identity inputs fail closed, concurrent claim has one winner, completion reports
stale after tested Git mutations, the helper contains no integration/fetch/
activation/publication/promotion/cleanup operation, and static checks are not
labeled behavioral proof.

After accepting that review, the orchestrator updated project Engram topic
`architecture/parallel-worktree-orchestration` with `capture_prompt=false` and
pointers to the approved specification and tested sources. It does not copy
mutable claim or dirty-worktree state.

## Current working-tree status

After Task 9 documentation edits and deterministic verification:

```text
## docs/parallel-worktree-orchestration-design...main [ahead 2]
 M .Codex-context.md
 M README.md
 M codex-config/.codex/AGENTS.md
 M tests/codex-config-stow.zsh
?? notes/docs-parallel-worktree-orchestration-design--2026-08-08.md
!! docs/superpowers/plans/2026-08-08-parallel-codex-worktree-orchestration.md
!! docs/superpowers/specs/2026-08-08-parallel-codex-worktree-orchestration-design.md
```

The approved plan and specification are ignored by the repository and accounted
for explicitly. The note is the only planned untracked file.

## Not claimed

- No live Stow activation or mutation of `~/.codex` occurred.
- Live Engram hook suppression remains `PENDING_CANARY`.
- No contradictory multi-worker adversarial canary ran.
- No claim is made about current ctx index health.
- No push, integration, pull request, tracker mutation, memory promotion, or
  worktree/branch cleanup occurred.

## Continuation

Request the smallest next approval: the local documentation checkpoint
`docs(codex): document parallel worktree orchestration`. Do not stage or commit,
activate, run a live canary, push, integrate, or clean up without the applicable
separate approval.
