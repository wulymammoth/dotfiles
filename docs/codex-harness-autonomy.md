# Codex Harness and Bounded Autonomy Design

**Status:** Accepted on 2026-08-05; reconciled and re-approved on 2026-08-06

**Scope:** Cross-project Codex workflow policy, followed by repository-local pilots

**Decision owner:** Repository owner

## Summary

Reduce repeated owner prompting by giving Codex a better repository harness and
a larger **local** execution envelope, not by removing product or risk judgment.
An autonomous run may take one approved goal through implementation,
verification, review, bounded repair, and runtime-evidence collection in one
isolated worktree. It ends at `LOCAL_READY` or `BLOCKED`; shipping and other
consequential actions remain separately approved.

The first implementation is deliberately a policy and pilot, not a new
orchestrator. Existing tools supply the layers:

- the repository supplies current authority and exact verification commands;
- GSD may help select and plan milestone or phase work;
- one named execution authority supplies implementation and dispatches fresh
  review: Superpowers subagent-driven development when local task commits are
  approved, otherwise the inline policy executor;
- ctx retrieves source-session provenance when it is actually needed;
- Engram preserves curated decisions and discoveries;
- Codex Goal mode is optional execution continuity after the goal and contract
  are already clear.

## Why This Is Smaller Than the Initial Recommendation

The core lessons from OpenAI's
[harness-engineering report](https://openai.com/index/harness-engineering/) do
transfer: make the repository legible, turn recurring expectations into
executable checks, preserve evidence, and improve the environment rather than
repeating instructions. Their scale and staffing do not transfer directly to
an indie-developer portfolio, so their automation topology is not a template.

The challenge found four reasons to narrow the rollout:

1. Installed GSD and Superpowers workflows overlap and sometimes have different
   failure and commit semantics. Composing both as autonomous executors would
   create two authorities rather than a stronger loop.
2. Goal mode preserves an objective but does not create acceptance criteria,
   runtime observability, or a safe retry policy. It is an execution convenience,
   not the reliability boundary.
3. Scheduled PR polling, universal automatic review, and weekly documentation
   agents have not been shown to be the current bottleneck.
4. A prior SoundCoaster governance design grew into a large custom CLI and
   multi-vendor review system before one real pilot. It stalled on vendor,
   privacy, and account constraints and is now materially stale.

## Disposition Of The Four Constraints

The constraints are resolved by narrowing authority, not by composing more
automation:

1. Every run names one `execution_authority`. GSD remains optional
   selection/planning input. Superpowers SDD may execute only when local
   task-branch commits are approved; commit-forbidden runs use the inline policy
   executor. The tracked policy overrides installed worktree fallback, repair,
   finding-parking, branch-finishing, and cleanup behavior.
2. Goal mode remains `off` or `continuity_only`. The approved plan supplies the
   acceptance, evidence, and terminal contract. A declared retry policy governs
   transient command/tool attempts separately from fix rounds.
3. Scheduled polling, universal review, and documentation agents remain an
   evidence question. Two or three real medium-task attempts plus a manual
   contract transfer test must confirm the same repeated friction before one
   separately approved report-only prototype is built and canaried.
4. The unimplemented SoundCoaster governance proposal is superseded. Preserve
   only this compact retrospective; removal of its stale worktree, branch, and
   untracked planning files is a separate destructive-action gate.

Installer-managed GSD and Superpowers files remain untouched. Their ordinary,
explicitly invoked workflows outside a bounded run keep their own semantics.

## Goals

- Let the owner approve a named local outcome once instead of approving every
  reversible edit and verification step.
- Move owner attention to product trade-offs, risk acceptance, runtime outcome
  judgment, and shipping decisions.
- Make failures stop with useful evidence rather than silently degrading checks.
- Reduce startup-context load through progressive disclosure and compact maps.
- Automate only repetition observed during real project work.

## Non-Goals

- No autonomous push, pull request, issue or tracker mutation, merge, deploy,
  release, production or provider call, paid call, destructive data operation,
  authentication or secret change, provisioning, or real-device/store action.
- No auto-merge and no `SHIPPED` autonomous state.
- No custom autopilot skill or coordinator during the pilot.
- No raw GSD autonomous execution, shipping, or worktree cleanup in the pilot.
- No multi-vendor review quorum.
- No scheduled mutating automation or portfolio-wide CI retrofit.
- No arbitrary line limit for `.Codex-context.md`; keep invariant knowledge
  compact and navigate historical material through indexes or archives.

## Authority and Tool Boundaries

Authority remains, in descending order:

1. current code, tests, configuration, specifications, and accepted ADRs;
2. a compact repository start map and the active approved plan;
3. project context and milestone notes;
4. Engram observations and focused ctx evidence;
5. generated summaries and model recollection.

One layer owns each responsibility:

| Responsibility | Initial owner | Constraint |
| --- | --- | --- |
| Product goal and risk acceptance | Human | Never inferred from automation output |
| Milestone or phase selection | GSD or human | GSD is optional and planning-only during the pilot |
| Task plan | One approved plan | No duplicate plan state across tools |
| Implementation and review dispatch | One named executor | SDD requires approved local commits; otherwise use the inline policy executor |
| Verification and evidence | Project repository | Exact commands and proof categories are declared locally |
| Historical retrieval | ctx | Focused lookup; never current authority |
| Curated durable memory | Engram | Save decisions and non-obvious learnings, not duplicate task state |

Installer-managed skill files are not modified. Policy overrides live in the
tracked global policy and repository-local instructions so plugin updates do not
erase them.

## Concurrent Session Coordination

Multiple Codex sessions are useful when their writable and external boundaries
are explicit. A worktree isolates source and index state, but it does not isolate
project-scoped memory recency, hosted artifacts, simulators, devices, provider
budgets, staging environments, or eventual integration. The global policy
therefore defines coordination invariants without assuming that every repository
uses Git worktrees, Linear, pnpm, or pull requests.

The unit of exclusivity is an **active writer session**, not every process it
dispatches. Its named executor may use repository-approved workers with explicit,
non-overlapping ownership and remains the integration owner. A separate session
may inspect read-only, but a review verdict must target a named commit or
explicitly quiescent checkpoint rather than a changing checkout. Independent
writer sessions use isolated checkouts or worktrees, each with its own task
branch. Each mutable hosted artifact or environment has one writer until an
explicit handoff, and shared runtime resources remain exclusive unless isolation
is proven.

Overlapping central files do not force blanket serialization. Parallel changes
may proceed when a named integration owner owns the reconciliation order and
re-runs the combined verification boundary. Before readiness, each writer
refreshes the target base and proves current mergeability; the repository chooses
whether that means merge, rebase, merge queue, or another supported strategy.

After compaction or resume, generated summaries and recent project memory are
routing hints rather than ownership evidence. The session reconciles repository
root, branch, HEAD, dirty state, task identity, and any review artifact against
live sources before acting. A contradiction is corrected explicitly instead of
being used for further work. Mandatory preservation calls may capture a supplied
summary first; they do not make that summary authoritative.

Rejected alternatives:

- **Serialize every session:** safe but discards useful read-only review and
  independent implementation throughput.
- **Serialize every shared or high-conflict file:** unnecessary when a named
  integrator and combined verification can reconcile independent branches.
- **Treat worktrees as total isolation:** false for hosted state, memory,
  runtimes, caches, quotas, and final integration.
- **Add a mutable session lease registry:** creates synchronization, expiry, and
  cleanup state that can itself become stale. Repository ownership primitives
  and explicit handoffs remain the source of truth.

## Approval Envelope

Bounded autonomy is opt-in per goal. Before execution, the plan must state:

- goal and definition of done;
- repository, base revision, owned worktree path, and task branch;
- permitted file or subsystem scope;
- exact local commands and any allowed network reads;
- exactly one execution authority;
- whether local checkpoint commits are allowed (default: no);
- Goal mode (`off` or continuity-only with a non-empty plan reference) and an
  explicit retry policy, including replay safety for any bounded retry;
- risk class, at least one required deterministic proof, and explicit
  required/not-applicable classifications for runtime-local and external
  evidence;
- a run-wide maximum repair budget (at most two rounds during the pilot);
- prohibited actions and expiration at a terminal state.

Approval covers only the listed envelope. Ambiguous scope, a material design
change, an unlisted side effect, or a new consequential action ends the run as
`BLOCKED` and requires owner input.

## Execution State Machine

```text
PREFLIGHT -> EXECUTE -> VERIFY -> REVIEW -> EVIDENCE -> LOCAL_READY
                              ^       |
                              +-- FIX +

Any state -----------------------------------------------> BLOCKED
```

### `PREFLIGHT`

- Reconcile the current base revision, working trees, active plan, and declared
  project commands.
- Create exactly one harness-owned isolated worktree. Failure to create or
  validate it stops the run; never fall back to the user's current checkout.
- Do not create nested executor worktrees and never enumerate, reset, remove, or
  delete unrelated worktrees or branches.

### `EXECUTE`

- Work only inside the approved scope and worktree.
- Follow TDD for behavior changes when practical.
- Never bypass repository hooks, secret scanning, or security checks.
- A local checkpoint commit is permitted only when its envelope says so, and
  only on the owned task branch. Otherwise leave a reviewable uncommitted diff.
- Superpowers SDD is compatible only with an envelope that permits local task
  commits. The inline policy executor owns commit-forbidden runs. Neither may
  create another worktree, fall back to the current checkout, or invoke branch
  finishing or cleanup.
- GSD may help select or plan the task, but it is not a second executor,
  reviewer-fixer, shipper, or worktree manager inside the run.

### `VERIFY`

- Run the repository's one canonical deterministic verification contract plus
  the smallest relevant focused checks.
- Existing commands should be composed or documented before adding new wrapper
  scripts.
- A timeout, missing command, malformed result, skipped required check, or
  failing check blocks; it is not advisory.

### `REVIEW` and `FIX`

- Use at least one fresh review pass appropriate to the risk.
- Critical and Important findings block `LOCAL_READY` until fixed or explicitly
  waived by the owner. Only Minor debt may be parked automatically, with a
  recorded rationale.
- Reviewer failure or an unreadable/missing review artifact blocks.
- Re-run affected checks after every fix. Stop after the approved repair limit,
  which is at most two rounds during the pilot.
- A fix round begins with implementation changes responding to one or more
  findings and ends after affected verification and scoped re-review. Every
  task-level or final-review fix consumes the same run-wide budget.

### Goal Continuity And Retry Safety

- Goal mode may preserve only the approved plan reference. It does not own plan
  state or acceptance criteria. When `LOCAL_READY` conditions hold, complete
  the native Goal immediately before the report. A `BLOCKED` run never completes
  it; if the native blocked transition is not yet permitted, report it as active
  with execution halted. Any automatic continuation may only restate the recorded
  blocker and attempt the permitted native status transition; it may not inspect
  the repository, call other tools or networks, or resume expired work.
- The default retry policy is fail-fast. Bounded retries must declare the exact
  operation and transient failure class in advance, use at most two attempts for
  unchanged work during the pilot, and report attempts separately from repairs.
  Replay must be read-only or idempotent, or follow a named reconciliation that
  proves a partial or unknown outcome safe to retry.
- An undeclared, non-transient, or exhausted failure returns `BLOCKED`; token or
  continuation budget never weakens verification or evidence. Ambiguous
  completion without safe replay also returns `BLOCKED`.

### `EVIDENCE`

Classify the required proof before work begins:

- `deterministic`: unit, integration, type, lint, build, or policy checks;
- `runtime-local`: browser or simulator behavior and local persistence flows;
- `external`: provider, production, real-device, store, or other consequential
  proof that requires a separate approval.

A build, screenshot, code review, backend check, or code-only UI audit is not a
substitute for required end-to-end evidence. If external evidence is required
but not separately authorized, stop as `BLOCKED (EVIDENCE_NEEDED)` with the
local work preserved.

### Terminal States

`LOCAL_READY` means the owned branch or uncommitted worktree is locally
verified, reviewed, evidence-classified, and ready for the next explicit owner
decision. `BLOCKED` includes a precise reason, last successful state, residual
findings, and the smallest decision or authorization needed to continue.

Both states preserve the task worktree. Neither cleans unrelated state, pushes,
opens a PR, or ships.

## Evidence Manifest

Every run reports:

- goal, scope, base revision, worktree, and task branch;
- changed files and any local commits;
- exact verification commands and outcomes;
- review passes, findings, fixes, and remaining Minor debt;
- runtime evidence obtained, not applicable, or still needed;
- terminal state and separately gated next actions;
- intervention count, elapsed time, and avoidable friction for pilot evaluation.

This may be a structured final report before a dedicated artifact format is
proven necessary.

## Risk-Tiered Review

| Risk | Minimum loop |
| --- | --- |
| Low, reversible docs/config | Focused verification and one fresh diff review |
| Normal product code | Approved plan, TDD where practical, canonical verification, one fresh code review |
| High-risk security/data/UI/runtime boundary | Specification review plus quality/security/runtime review and explicit human judgment gate |

The tier changes review depth, not the consequential-action gates.

## Rollout

1. **Policy:** Track this design, the progressive-disclosure bounded-autonomy
   policy, and a concise global activation rule.
2. **Pilot preparation:** In SoundCoaster, create a compact authority/start map,
   point startup instructions at it instead of requiring full historical files,
   and declare existing deterministic and runtime-proof commands.
3. **Baseline and measured attempts:** Declare a comparable baseline and fixed
   observation window, then use the contract on two or three real, medium tasks.
   Record every attempt, including `BLOCKED`; policy setup is not a run.
4. **Evaluate:** Compare owner interventions, elapsed time, review signal,
   escaped defects, runtime-proof quality, cost, and cleanup effort across the
   complete attempt denominator.
5. **Transfer test:** Run the refined manual contract once in a less mature
   repository and confirm that the candidate friction generalizes.
6. **Prototype:** Under a separate approved plan, implement at most one smallest
   repeated mechanism as a thin report-only skill, schedule, or native review
   configuration.
7. **Canary and promote:** Run the prototype in one bounded, qualifying canary
   that reaches `LOCAL_READY`, using the same baseline and observation window.
   Promote it for reuse only if it removes the repeated process intervention
   without worsening defects, evidence, cost, or cleanup.

A run qualifies only when it preserves scope/isolation, completes canonical
verification and required evidence, receives a fresh review, has no unwaived
Critical or Important finding at `LOCAL_READY`, and records every owner
intervention as product/risk judgment or avoidable process friction. All
attempts remain in the denominator. A mechanism is a candidate only when the
same avoidable friction appears in at least two recorded attempts with the same
deterministic trigger and bounded inputs, and the sample contains at least two
qualifying runs. A scope/worktree escape vetoes promotion until its cause is
fixed and a later qualifying run proves the correction.

## Success and Reconsideration Criteria

Proceed from prototype to reusable automation only if the bounded canary has zero
acceptance-criteria restatements, zero prompts merely to request required review
or verification, no unwaived Critical or Important terminal finding, no scope or
worktree escape, and correctly classified runtime evidence. Against the declared
baseline and observation window, it must remove the repeated intervention
without increasing escaped defects, ambiguous evidence, cost, or cleanup.
Blocked attempts remain evidence rather than disappearing from the sample.
Revisit the design if reviews are noisy, fix loops repeat, task worktrees become
hard to reconcile, or the owner still has to restate acceptance criteria.

The intended endpoint is not a developer absent from outcomes. It is a developer
who is consulted for product and risk judgment rather than process babysitting.
