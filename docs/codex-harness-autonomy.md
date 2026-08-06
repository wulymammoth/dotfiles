# Codex Harness and Bounded Autonomy Design

**Status:** Accepted on 2026-08-05

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
- Superpowers subagent-driven development supplies the stricter execution and
  review loop;
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
| Implementation and review loop | Superpowers SDD | Must obey this policy's fail-closed overrides |
| Verification and evidence | Project repository | Exact commands and proof categories are declared locally |
| Historical retrieval | ctx | Focused lookup; never current authority |
| Curated durable memory | Engram | Save decisions and non-obvious learnings, not duplicate task state |

Installer-managed skill files are not modified. Policy overrides live in the
tracked global policy and repository-local instructions so plugin updates do not
erase them.

## Approval Envelope

Bounded autonomy is opt-in per goal. Before execution, the plan must state:

- goal and definition of done;
- repository, base revision, owned worktree path, and task branch;
- permitted file or subsystem scope;
- exact local commands and any allowed network reads;
- whether local checkpoint commits are allowed (default: no);
- risk class and required verification, review, and runtime evidence;
- maximum repair rounds (at most two during the pilot);
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
3. **Measured manual runs:** Use the contract on two or three real, medium tasks.
   Do not count policy setup as a successful run.
4. **Evaluate:** Compare owner interventions, elapsed time, review signal,
   escaped defects, runtime-proof quality, and cleanup effort with the baseline.
5. **Transfer test:** Run the refined contract once in a less mature repository.
6. **Extract automation:** Only then implement the smallest repeated mechanism as
   a thin skill, report-only schedule, or native review configuration.

## Success and Reconsideration Criteria

Proceed to thin automation only if the measured runs reduce avoidable owner
interventions without increasing escaped defects, ambiguous evidence, cost, or
cleanup. Revisit the design if reviews are noisy, fix loops repeat, task
worktrees become hard to reconcile, or the owner still has to restate acceptance
criteria.

The intended endpoint is not a developer absent from outcomes. It is a developer
who is consulted for product and risk judgment rather than process babysitting.
