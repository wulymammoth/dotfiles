# Bounded Autonomous Work

This policy is progressive disclosure for the global `AGENTS.md`. It applies
only when the user explicitly approves a named plan or goal for bounded
autonomous execution. The normal development and approval rules apply at all
other times.

## Required Approval Envelope

Record a literal envelope in the approved plan before execution. Use this shape;
do not leave a field implicit:

```yaml
goal: <named local outcome>
definition_of_done: <observable acceptance criteria>
repository: <absolute path>
base_revision: <full commit SHA>
worktree: <absolute owned path>
task_branch: <branch>
scope: [<allowed path or subsystem>]
commands: [<permitted local command>]
network_reads: [<allowed read or none>]
execution_authority: superpowers_sdd | inline_policy_executor
local_checkpoint_commits: allowed | forbidden
goal_mode: off | continuity_only
goal_reference: <none iff off; approved plan/envelope reference iff continuity_only>
retry_policy:
  mode: fail_fast
  operations: []
risk_class: low | normal | high
evidence:
  deterministic: [<at least one required command or proof>]
  runtime-local: [<required proof or not_applicable>]
  external: [<required proof or not_applicable>]
max_fix_rounds: 2
prohibited_actions: [<explicit action>]
terminal_states: [LOCAL_READY, BLOCKED]
```

Defaults are `local_checkpoint_commits: forbidden`, `goal_mode: off`, a
fail-fast retry policy with one attempt, and at most two fix rounds across the
entire bounded run. A bounded retry replaces the default with this per-operation
shape:

```yaml
retry_policy:
  mode: bounded
  operations:
    - name: <exact operation>
      retryable_failures: [<exact transient failure class>]
      replay_safety: read_only | idempotent | reconcile_first
      reconciliation: <exact check for reconcile_first; otherwise none>
      max_attempts: 2
      backoff: <declared backoff or none>
```

The same unchanged operation may run at most twice during the pilot. A fix round
begins when implementation changes in response to one or more review findings
and ends after affected verification and scoped re-review. Task-level,
specification, quality, security, runtime, and final-review fixes all consume the
same run-wide budget. Retry attempts and fix rounds are different budgets.

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
5. Confirm that the selected execution authority is compatible with the commit
   setting. `superpowers_sdd` requires `local_checkpoint_commits: allowed`;
   otherwise select `inline_policy_executor` or stop `BLOCKED`.

### EXECUTE

1. Keep all changes within the approved scope and owned worktree.
2. Use TDD for behavior changes when practical.
3. Never bypass hooks, secret scanning, security checks, or repository policy.
4. Create local commits only when `local_checkpoint_commits` is `allowed`, and
   only on the owned task branch. Otherwise preserve an uncommitted diff.
5. Use exactly the `execution_authority` named in the envelope. GSD may select or
   plan work, but its output feeds the one approved plan; GSD does not execute,
   review-fix, ship, create nested worktrees, or clean up inside a bounded run.

### INSTALLED-SKILL ADAPTER

The tracked policy overrides conflicting installer defaults without editing the
installed skills:

- For `superpowers_sdd`, the harness creates and verifies the sole owned worktree
  before dispatch. Never allow the skill to create a nested worktree or fall
  back to the current checkout. Local task-branch commits must be explicitly
  allowed because SDD review packages depend on commit ranges.
- The envelope's run-wide `max_fix_rounds` replaces SDD's per-task and final-wave
  defaults. At the cap, an unresolved Critical or Important finding returns
  `BLOCKED` unless the owner explicitly waives it. Missing or malformed reviewer
  output remains blocking.
- Replace SDD's branch-finishing step with this policy's terminal contract. Do
  not invoke branch-finishing, push, pull-request, merge, shipping, or cleanup
  behavior from the installed workflow.
- For `inline_policy_executor`, the active Codex agent edits only the approved
  worktree and leaves an uncommitted diff when commits are forbidden. It still
  dispatches a fresh independent reviewer and obeys the same verification,
  evidence, finding, and fix-round gates.
- Do not invoke `gsd-autonomous`, `gsd-execute-phase`, `gsd-quick`, `gsd-fast`,
  `gsd-code-review-fix`, `gsd-ship`, or equivalent GSD execution, mutation, or
  cleanup workflows inside the bounded run.

Repository-owned commands remain the verification authority. Executor reports
and reviewer opinions are evidence, not substitutes for those commands.

### VERIFY

1. Run the repository's named canonical verification contract and relevant
   focused checks. Prefer existing commands to speculative wrapper scripts.
2. Treat failures, timeouts, missing commands, malformed output, and skipped
   required checks as blocking.
3. Record exact commands, exit status, and the revision or diff they verified.

### GOAL CONTINUITY AND RETRIES

- `goal_mode: off` creates no persistent Goal. `continuity_only` may preserve the
  approved objective after the envelope is complete, but its objective must
  point to `goal_reference` instead of duplicating plan state.
- Goal state, token budget, and automatic continuation never relax scope,
  verification, review, evidence, retry, or approval gates. Recover current Git,
  plan, and repository state before continuing after any interruption.
- When all `LOCAL_READY` conditions hold, mark an active native Goal complete
  immediately before emitting the terminal report. A `BLOCKED` run never
  completes its Goal. Mark it blocked only when the native Goal contract permits;
  otherwise report `active (execution halted)`. Any automatic continuation may
  only restate the recorded blocker and, when permitted, transition the native
  Goal to blocked; it must not inspect the repository, call other tools or
  networks, or resume execution after the envelope has expired.
- Retry only an operation and failure class allowed by `retry_policy`. An
  undeclared repeated failure, a non-transient failure, exhausted attempts, or
  ambiguous completion without envelope-proven replay safety stops the run
  `BLOCKED`. Retry after a partial or unknown outcome only when the operation is
  read-only or idempotent, or after the named reconciliation proves replay safe.
  Do not keep prompting or retrying unchanged work.

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

If Goal mode is active, include its reference and final status. Report retry
attempts separately from repair rounds.

Neither terminal state authorizes push, pull-request or issue/tracker mutation,
review submission, merge, deployment or release, production/provider/paid
calls, destructive data changes, authentication or secret changes, provisioning,
or real-device/store actions. Each class remains separately approved.

## Pilot Promotion Gate

Record every attempted run, including `BLOCKED` runs, and declare a comparable
pre-automation baseline plus a fixed observation window for interventions,
elapsed time, escaped defects, evidence ambiguity, cost, and cleanup. A run
qualifies only when it preserves scope and isolation, completes canonical
verification and required evidence, receives fresh review, has no unwaived
Critical or Important finding at `LOCAL_READY`, and reports accurately.

Run the contract manually on two or three real medium tasks. A candidate must
represent the same avoidable friction in at least two recorded attempts with the
same deterministic trigger and bounded inputs, and the sample must include at
least two qualifying runs. Do not discard blockers from the denominator. A scope
or worktree escape vetoes promotion until its root cause is fixed and a later
qualifying run proves the correction.

Transfer-test the manual contract once in a less mature repository to confirm
that the friction generalizes. Only then, under a separately approved plan,
build at most one thin report-only prototype and run a bounded canary against the
declared baseline and observation window. The canary itself must reach
`LOCAL_READY` and qualify. Promote it for reuse only if it removes the repeated
process intervention with zero acceptance-criteria restatements, zero prompts
merely to request required review or verification, and no increase in escaped
defects, ambiguous evidence, cost, or cleanup. Hosted or production mutations
remain outside this policy.
