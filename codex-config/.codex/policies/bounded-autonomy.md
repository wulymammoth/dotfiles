# Bounded Autonomous Work

This policy is progressive disclosure for the global `AGENTS.md`. It applies
only when the user explicitly approves a named plan or goal for bounded
autonomous execution. The normal development and approval rules apply at all
other times.

## Required Approval Envelope

Record these fields in the approved plan before execution:

- goal and definition of done;
- repository, base revision, owned worktree path, and task branch;
- allowed file or subsystem scope;
- exact permitted local commands and network reads;
- `local_checkpoint_commits: allowed|forbidden` (default: `forbidden`);
- risk class and required deterministic, runtime-local, and external evidence;
- `max_fix_rounds`, no greater than `2` during the pilot;
- prohibited actions and expiration at `LOCAL_READY` or `BLOCKED`.

Approval does not extend beyond these fields. Stop when an ambiguity or material
change would alter behavior, scope, risk, acceptance criteria, or side effects.

## State Machine

```text
PREFLIGHT -> EXECUTE -> VERIFY -> REVIEW -> EVIDENCE -> LOCAL_READY
                              ^       |
                              +-- FIX +

Any state -----------------------------------------------> BLOCKED
```

There is deliberately no autonomous `SHIPPED` state.

### PREFLIGHT

1. Reconcile current code, Git/worktree state, active plan, and repository
   contracts. Current repository evidence outranks notes and memory.
2. Create and verify exactly one harness-owned isolated worktree from the named
   base revision. If isolation fails, stop; never fall back to a current or dirty
   checkout.
3. Do not create nested executor worktrees. Do not reset, remove, prune, or
   delete unrelated worktrees or branches.
4. Confirm every required command and evidence category before editing.

### EXECUTE

1. Keep all changes within the approved scope and owned worktree.
2. Use TDD for behavior changes when practical.
3. Never bypass hooks, secret scanning, security checks, or repository policy.
4. Create local commits only when `local_checkpoint_commits` is `allowed`, and
   only on the owned task branch. Otherwise preserve an uncommitted diff.
5. Use one execution authority. During the initial pilot, GSD may select or plan
   work; Superpowers subagent-driven development executes and reviews it. Do not
   invoke raw GSD autonomous execution, shipping, nested worktree management, or
   cleanup.

### VERIFY

1. Run the repository's named canonical verification contract and relevant
   focused checks. Prefer existing commands to speculative wrapper scripts.
2. Treat failures, timeouts, missing commands, malformed output, and skipped
   required checks as blocking.
3. Record exact commands, exit status, and the revision or diff they verified.

### REVIEW AND FIX

1. Use a fresh reviewer appropriate to the declared risk.
2. Critical and Important findings block. Only Minor findings may be parked
   without owner input, and each needs a rationale.
3. Reviewer/tool failure or a missing/malformed review artifact blocks.
4. Re-run affected verification after fixes. Stop when `max_fix_rounds` is
   exhausted; never turn an incomplete fix loop into success.

### EVIDENCE

Classify proof as:

- `deterministic`: tests, types, lint, build, and policy checks;
- `runtime-local`: local browser/simulator behavior and persistence flows;
- `external`: provider, production, paid, real-device, store, or similar proof.

Builds, screenshots, code review, backend checks, and code-only UI audits do not
stand in for required end-to-end runtime proof. If external evidence is required
but lacks separate authorization, return `BLOCKED (EVIDENCE_NEEDED)`.

## Terminal Contract

At `LOCAL_READY` or `BLOCKED`, preserve the owned worktree and report:

- goal, scope, base revision, worktree, and branch;
- changed files and local commits, if any;
- verification commands and outcomes;
- review findings, fixes, and remaining Minor debt;
- runtime evidence obtained, not applicable, or needed;
- terminal state, reason, and the smallest next owner decision;
- intervention count and avoidable friction for pilot evaluation.

Neither terminal state authorizes push, pull-request or issue/tracker mutation,
review submission, merge, deployment or release, production/provider/paid
calls, destructive data changes, authentication or secret changes, provisioning,
or real-device/store actions. Each class remains separately approved.

## Pilot Promotion Gate

Run this contract manually on two or three real medium tasks, then once in a
less mature repository. Build a reusable skill, automatic review, or scheduled
task only for repetition demonstrated by those runs. Scheduled automation starts
report-only; hosted or production mutations remain outside this policy.
