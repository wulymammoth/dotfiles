# Parallel Codex Worktree Orchestration Design

Date: 2026-08-08

Status: Task-memory remediation integrated and live through the existing Stow
link; a fresh qualifying adversarial canary remains pending

Decision owner: Repository owner

## Summary

Adopt the recommendation's central isolation invariant, but do not fork Engram
or add parallel execution machinery to the Superpowers 6.2 fork.

For every concurrent implementation outcome, use:

```text
one task
  = one branch
  = one linked worktree
  = one active owning top-level Codex thread at a time
  = one default Engram task project
```

Implement the orchestration boundary in dotfiles as a small Codex profile, a
local orchestration skill, and a dependency-free worktree-session helper. Keep
Git and an approved plan authoritative, use ctx only for task-qualified
provenance, and use Engram only for curated memory. Parallel workers must not
receive Engram's broad project-wide hook injection or automatic prompt and
subagent capture.

The no-fork design is intentionally staged. Deterministic local tests and
review precede integration into any live-linked source. A separately authorized
adversarial multi-worker canary remains required before portfolio-wide
promotion. A fork is a contingency only if the canary exposes a specific
isolation gap that cannot be closed with upstream configuration or an upstream
change.

The first provider-backed profile canary proved that optional Engram hooks were
suppressed, but also proved that setting `ENGRAM_PROJECT` only on the outer
Codex process did not configure the Codex-managed Engram MCP child. The local
remediation therefore keeps the worker environment check and adds an exact
per-launch `mcp_servers.engram.env.ENGRAM_PROJECT` override. This is a Codex
configuration correction, not a reason to fork Engram or Superpowers.

### 2026-08-13 enforcement amendment

The task-project mechanism remains accepted as temporary containment. The
observed LEA-146, LEA-253, and LEA-265 contamination did not traverse a
prepared worker boundary: those sessions started plainly from the primary
checkout without descriptors. Engram's default Git-origin project detection
therefore routed each session into the same `soundcoaster` project and its
project-level recent context interleaved their activity.

The remediation tightens adoption rather than rolling back isolation:

1. Linked-checkout status triggers the orchestration boundary even when no
   descriptor exists; an unprepared linked checkout fails closed.
2. A session may implement only in its startup checkout. A primary
   `COORDINATOR_ONLY` session has a narrow exception to create an approved plan
   and descriptor in a new unclaimed linked worktree, then launches a fresh
   writer instead of implementing across roots.
3. A read-only `worktree-session guard` distinguishes `COORDINATOR_ONLY`,
   `PREPARED_UNCLAIMED`, and `WRITER_BOUNDARY` states before any write.
4. `memory.taskProject` must be unique across linked-worktree descriptors;
   prepare and runtime preflight both reject duplicates.
5. Project-level recovery memory may contain concurrent-session activity. It
   supports recovery but never overrides the active conversation, current Git,
   the descriptor, or the owner claim.

[Engram issue #587](https://github.com/Gentleman-Programming/engram/issues/587)
is the preferred future convergence architecture: one logical project, one
data directory per worktree, a recorded fork point, and lossless three-way
merge. As of this amendment it is an open design issue rather than a shipped
and qualified boundary. This implementation therefore does not delete shared
history, automatically call `mem_merge_projects`, use last-writer-wins, or
locally imitate the proposed merge protocol. Reviewed durable discoveries are
promoted deliberately until the upstream design can replace containment.

## Problem

Linked worktrees isolate files, Git indexes, and branches. They do not isolate:

- top-level Codex thread ownership;
- project-wide Engram recency and prompt capture;
- ctx searches that omit task, workspace, session, or file filters;
- shared simulators, devices, databases, provider budgets, deployments, or
  hosted artifacts;
- the eventual integration order.

The current Engram Codex plugin makes the memory risk concrete. Its hooks
derive a project from the Git remote or repository root, so all worktrees of a
repository share one project. At session start the plugin injects recent
project context; on prompt submission it persists user prompts; on subagent
completion it passively captures output. Its hook helper does not consult
`ENGRAM_PROJECT`. Concurrent sessions can therefore see or record another
issue's transient state even though their source trees are isolated.

The required outcome is not merely faster parallelism. It is parallelism whose
ownership, task identity, evidence, and recovery behavior remain correct when:

- several issues run at once;
- task descriptions contradict one another;
- a model retrieves misleading historical memory;
- a session compacts or resumes;
- Superpowers dispatches subagents;
- one worker is committed and another is not;
- an orchestrator reviews or later integrates the results.

## Current-system findings

This design was checked against the installed tools on 2026-08-08:

- Codex CLI 0.147.0 supports named overlay files with
  `codex --profile <name>` and roots an agent with `-C <directory>`. Official
  documentation states that a profile overlays the base user config and that
  `-C` sets the agent working directory.
- Codex loads hooks bundled by enabled plugins alongside other hook sources;
  higher-precedence hook files do not erase lower-precedence hooks. Disabling
  the Engram plugin, rather than trying to shadow its individual hooks, is the
  narrow configuration boundary to test.
- Engram 1.20.0 core supports `engram mcp --project <name>` and
  `ENGRAM_PROJECT=<name>` as process-level defaults for all read and write
  tools. Read tools also accept an explicit existing project. A live Codex
  canary established an additional boundary: an environment variable on the
  outer Codex process is not sufficient to configure a Codex-managed MCP
  child. Codex 0.147.0 accepts per-launch
  `mcp_servers.engram.env.ENGRAM_PROJECT` and `ENGRAM_DATA_DIR` overrides, and
  provider-free `mcp list --json` probes expose their exact effective values.
- The optional Engram Codex plugin is separable from the independently
  configured Engram MCP server and model instruction files. Disabling the
  plugin can therefore remove its automatic hooks without removing explicit
  `mem_*` tools or the memory protocol.
- ctx 0.25.0 is a read-only provenance index for this workflow, not a writable
  task-memory namespace. It supports workspace, file, provider, session, time,
  and term filters and excludes the active Codex thread tree when
  `CODEX_THREAD_ID` is available.
- Superpowers 6.2 already detects an existing linked worktree and avoids
  nesting another. Its subagent-driven development scratch is plan-scoped and
  its implementation agents run sequentially under one top-level controller.
- Superpowers SDD assumes task checkpoint commits. It is available only when
  the owner has explicitly authorized those local commits; commit-forbidden
  workers use the existing inline/executing-plans path.

Relevant upstream references:

- [Codex advanced configuration](https://learn.chatgpt.com/docs/config-file/config-advanced)
- [Codex developer commands](https://learn.chatgpt.com/docs/developer-commands?surface=cli)
- [Codex hooks](https://learn.chatgpt.com/docs/hooks)
- [Engram documentation](https://github.com/Gentleman-Programming/engram/blob/main/DOCS.md)
- [Engram plugin documentation](https://github.com/Gentleman-Programming/engram/blob/main/docs/PLUGINS.md)

## Critical evaluation of the supplied recommendation

### Adopt

1. **One branch, worktree, task, and owning top-level session.** This is the
   correct concurrency unit for write-heavy work.
2. **Separate project coordination from worker implementation.** The
   orchestrator prepares and observes; the claimed worker owns mutations in its
   worktree.
3. **Mechanical root and branch checks.** Natural-language reminders are not
   sufficient, especially after compaction or when `apply_patch` is available.
4. **A structured handoff and completion contract.** A worker must report a
   verifiable branch, HEAD, dirty state, tests, evidence, and blocker rather
   than merely saying "done."
5. **Explicit promotion of durable discoveries.** Branch hypotheses must not
   silently become shared architectural truth.
6. **Minimal changes to existing Superpowers skills.** Parallel preparation is
   a layer above one-worktree SDD, not a reason to rewrite SDD.

### Revise

1. **Do not treat ctx as writable task memory.** ctx indexes agent history. Its
   isolation mechanism is task-qualified retrieval and source provenance, not
   a `ctx_write_task()` namespace.
2. **Do not use broad project Engram context in workers.** Merely prefixing
   memory text with a task ID leaves default context injection and prompt
   capture contaminated. Give each worker MCP process a distinct default
   Engram project and disable the optional plugin hooks for that profile.
3. **Use Git-config syntax, not YAML.** `git config --file` is already present,
   handles quoting, and avoids adding `yq`, a Python YAML dependency, or an
   ad-hoc parser.
4. **Keep only a descriptor, an owner claim, and a completion snapshot.** A
   continuously updated file-based state machine becomes another stale source
   of truth. Live Git and an atomic claim remain authoritative.
5. **Permit orchestrator read-only inspection.** "Never enter a worker
   worktree" is too broad. Read-only inspection of a named commit or quiescent
   checkpoint is useful. Mutations require an explicit ownership handoff.
6. **Do not automate integration or cleanup.** Merge, rebase, cherry-pick,
   push, worktree removal, and branch deletion remain separate authorization
   gates.
7. **Do not guess abandonment from time.** There is no stale-owner timeout.
   Release or handoff is explicit; an incomplete claim fails closed.
8. **Do not inject identity by editing upstream SDD prompts initially.** The
   owning top-level session starts at the exact worktree root and verifies the
   claim before it dispatches existing Superpowers subagents.

### Reject for the first release

- an Engram fork;
- a deeper Superpowers fork;
- an Engram/ctx JSON-RPC proxy;
- a central lease service or portfolio-wide mutable registry;
- automatic dependency scheduling, conflict prediction, integration, or
  cleanup;
- automatic promotion from task memory to shared project memory;
- automatic stale-owner takeover.

These mechanisms add maintenance and new failure modes before the smallest
no-fork boundary has been tested.

## Authority model

The workflow has three deliberately separate planes.

### Control plane: live worktree state

Authoritative for current execution:

- physical repository and worktree root;
- branch and HEAD;
- approved base SHA and target branch;
- task ID and approved plan digest;
- atomic owner claim keyed by `CODEX_THREAD_ID`;
- current Git dirty state;
- explicit handoff or release.

Engram, ctx, chat summaries, tmux labels, and branch names alone do not prove
ownership.

### Provenance plane: ctx

ctx answers historical questions such as who discussed a decision, what command
failed, which rejected approach was tried, or which source session produced a
claim. Searches start with concrete task, worktree, session, file, or error
identifiers and a small limit. Results are inspected at the event or session
level before use and checked against the repository.

ctx never establishes the active owner or current implementation state.

### Memory plane: Engram

Engram stores curated, compressed knowledge. Each worker receives a unique
default task project such as:

```text
soundcoaster-task-lea-234
```

The canonical shared project remains:

```text
soundcoaster
```

Worker defaults and rules:

- the helper sets `ENGRAM_PROJECT` for worker-side claim verification and also
  sets `mcp_servers.engram.env.ENGRAM_PROJECT` in Codex's per-launch config;
- `mem_current_project` must confirm that task project during bootstrap.
- task-scoped `mem_context`, session summaries, decisions, bug fixes, and
  candidate discoveries remain in the task project;
- worker `mem_save` calls use `capture_prompt=false`;
- broad shared-project `mem_context` is prohibited;
- shared memory is read only through focused `mem_search` queries using
  concrete identifiers;
- workers do not pass the shared project to a write tool;
- a completion report labels possible durable discoveries as candidates;
- the orchestrator verifies a candidate against integrated source and then
  decides whether to save it to the canonical project.

Engram 1.20.0 does not provide a per-process ACL that makes an explicit
cross-project write impossible. The distinct default project, disabled
automatic hooks, worker instructions, and adversarial eval provide strong safe
defaults, not a security boundary against a deliberately noncompliant client.
If ordinary agents still write across that boundary, the design stops before
promotion and considers an upstream allowlist/write-lock feature or a thin
proxy. That evidence, not speculation, is the fork trigger.

## Components

### 1. `parallel-work` Codex profile

Tracked source:

```text
codex-config/.codex/parallel-work.config.toml
```

Stowed target:

```text
~/.codex/parallel-work.config.toml
```

Initial responsibility:

```toml
[plugins."engram@engram"]
enabled = false
```

The profile deliberately retains the base user configuration, independently
configured Engram MCP server, Engram model instructions, Superpowers plugin,
approval policy, and sandbox policy. It does not duplicate secrets or the base
config.

The profile is not selected globally. Worker launch must name it explicitly.
The workflow remains unqualified for portfolio-wide use until a behavioral
probe proves that:

1. the Engram plugin's SessionStart, UserPromptSubmit, SubagentStop, and Stop
   hooks do not run;
2. the independent Engram MCP server still exposes the required tools;
3. `mem_current_project` reports the descriptor's task project;
4. the normal global and repository `AGENTS.md` policies still load;
5. the Superpowers 6.2 skills remain available.

If per-profile plugin disablement is not honored, the first fallback is to ask
the owner whether to disable the optional Engram plugin globally while keeping
the bare MCP and instruction files. A fork is not the fallback.

### 2. Local orchestration skill

Tracked source:

```text
codex-config/.codex/skills/orchestrating-parallel-worktrees/SKILL.md
```

The skill applies when a coordinator prepares two or more independent writer
sessions, or when a worker starts or resumes from a prepared descriptor. It
does not replace existing Superpowers execution skills.

Coordinator responsibilities:

- decompose only genuinely independent outcomes;
- name dependencies and one integration owner;
- obtain approval for plans and worktree creation;
- run `guard` from the startup checkout and remain `COORDINATOR_ONLY` when it
  is the primary checkout;
- use the existing `superpowers:using-git-worktrees` boundary;
- prepare metadata in an existing linked worktree;
- provide the exact helper launch command;
- use only the narrow approved-plan and descriptor bootstrap exception across
  roots; never implement through `workdir`, `git -C`, or absolute paths;
- stop writing after a worker claims the worktree;
- inspect only read-only while the claim remains active;
- preserve all integration and cleanup gates.

Worker responsibilities:

- run `guard`, claim, confirm the task memory project, and verify before any
  repository write;
- read the approved plan and authoritative repository context;
- confirm the Engram task project;
- use focused shared memory and ctx retrieval only when needed;
- re-run verification after compaction or resume;
- use SDD only when local task commits are authorized;
- emit a completion or blocked report;
- never mutate another worktree, shared hosted artifact, or runtime.

Because skill authoring is process behavior, implementation follows the
Superpowers writing-skills RED-GREEN-REFACTOR discipline. Provider-backed
pressure scenarios are a separate approval from deterministic helper tests.

### 3. `worktree-session` helper

Tracked source:

```text
codex-config/.codex/skills/orchestrating-parallel-worktrees/scripts/worktree-session
```

The helper is Zsh plus Git and standard macOS utilities. It does not require
`jq`, `yq`, Python, Node, or a daemon. It never uses `eval`.

Supported lifecycle:

```text
guard -> prepare -> launch -> guard -> claim -> verify -> report -> handoff | release
```

It intentionally has no create-worktree, merge, rebase, cherry-pick, push,
remove-worktree, or delete-branch command.

#### Startup guard and task-project uniqueness

`guard` is read-only. In the repository's primary checkout it prints
`COORDINATOR_ONLY`. In a linked checkout it requires a safe descriptor and its
exact root, Git, plan, task-project, and—when claimed—owner identity. A valid
unclaimed checkout reports `PREPARED_UNCLAIMED`; a matching claimed checkout
reports `WRITER_BOUNDARY`. Missing preparation or any mismatch stops the
session without creating metadata or an owner claim.

`prepare` and every descriptor preflight inspect regular, non-symlink sibling
descriptors from `git worktree list --porcelain -z`. Reusing a
`memory.taskProject` fails with both physical roots. Running the same check at
runtime prevents descriptor drift from silently converging two writers after
preparation.

#### Metadata layout

```text
.superpowers/parallel/
├── .gitignore
├── session.conf
├── owner/
│   └── claim.conf
└── completion.conf
```

`.superpowers/parallel/.gitignore` contains only `*`. A disposable Git probe
proved that this narrow file ignores itself and all sibling metadata while
leaving unrelated `.superpowers/` content visible. The helper refuses to
overwrite a pre-existing file with different content and refuses metadata
paths that are symlinks.

`session.conf` uses Git-config syntax:

```ini
[session]
    schemaVersion = 1
    role = implementation-controller
    preparedAt = 2026-08-08T22:30:00Z
    preparedByThread = <orchestrator CODEX_THREAD_ID>

[task]
    id = LEA-234
    slug = social-integrity
    planPath = docs/superpowers/plans/2026-08-08-social-integrity.md
    planSha256 = <sha256>

[git]
    commonDir = /Users/me/src/soundcoaster/.git
    worktreeRoot = /Users/me/src/soundcoaster/.worktrees/social-integrity
    branch = feat/lea-234-social-integrity
    baseRef = main
    baseSha = <full SHA>

[memory]
    sharedProject = soundcoaster
    taskProject = soundcoaster-task-lea-234

[integration]
    targetBranch = main
    owner = <named integration owner>
```

The descriptor is immutable during a claim. Changing the base or approved plan
requires an explicit re-prepare while unclaimed. Absolute paths are expected:
moving a worktree invalidates its descriptor rather than silently retargeting
it.

#### Atomic owner claim

`claim` requires a non-empty `CODEX_THREAD_ID`. It creates the `owner/`
directory with atomic `mkdir`, then atomically writes:

```ini
[owner]
    threadId = <CODEX_THREAD_ID>
    claimedAt = <UTC timestamp>
```

Semantics:

- before creating `owner/`, `claim` performs the same non-owner root, common
  Git directory, branch, base, plan, metadata-symlink, and Engram-environment
  preflight as `verify`;
- no owner directory: one claimant can create it;
- same thread ID: idempotent success;
- different thread ID: hard failure before writes;
- directory without a valid claim file: hard failure requiring explicit owner
  action;
- no age-based expiration or PID-based takeover;
- `handoff --to <thread-id>` requires the current owner and changes the claim
  atomically;
- `release` requires the current owner and explicitly removes only the claim;
- neither command removes worktree data or Git branches.

An incomplete claim cannot be released by guessing its owner. Recovery is a
manual, separately authorized removal of only that claim after the integrator
proves no writer is active; it is not automated in the first release.

#### Verification

`verify` fails unless all of these hold:

- metadata schema is supported and every required field is present;
- the physical current root equals `git.worktreeRoot`;
- the physical `git rev-parse --git-common-dir` equals `git.commonDir`;
- the checked-out branch equals `git.branch`;
- the task branch differs from the integration target;
- `git.baseSha` remains an ancestor of HEAD;
- the plan exists under the worktree, remains inside it, and matches
  `task.planSha256`;
- the current `CODEX_THREAD_ID` owns the claim;
- metadata files and directories are not symlinks;
- `ENGRAM_PROJECT` equals `memory.taskProject`;
- the launched Codex configuration gives the Engram MCP child the same task
  project;
- `mem_current_project`, when run during bootstrap, returns the same task
  project.

The helper reports each expected and actual value on failure without including
secrets.

#### Launch and resume

The helper owns path quoting and launches a fresh worker as:

```sh
ENGRAM_PROJECT="<task-project>" \
  codex -p parallel-work \
    -c 'mcp_servers.engram.env.ENGRAM_PROJECT="<task-project>"' \
    -C "<absolute-worktree>" "<bootstrap prompt>"
```

For a disposable canary, the coordinator may pre-create a data directory under
the task worktree and set `ENGRAM_DATA_DIR` when invoking the helper. The helper
normalizes it, rejects relative, root-level, outside, and symlink-escape paths,
and supplies the same path through
`mcp_servers.engram.env.ENGRAM_DATA_DIR`. Normal task launches omit this
override and isolate memory by task project in the configured Engram store.

The bootstrap prompt includes the task ID and plan path and instructs the
worker to invoke the orchestration skill, run `guard`, claim, call
`mem_current_project`, and verify before any other repository action. Starting
Codex from a shell whose current directory merely points at the worktree is
insufficient; `-C` is mandatory.

Resume targets the recorded owner thread. A new top-level thread cannot resume
an occupied worktree by claiming around the existing owner. If the original
thread cannot be resumed, the owner or integrator explicitly releases or
hands off the claim first.

### 4. Completion snapshot

`report` writes `completion.conf` as evidence, not current authority. It always
records the descriptor identity, owner thread, generation time, branch, full
HEAD, base SHA, dirty state, changed paths, local commits after the base,
verification commands supplied by the worker, evidence classification,
candidate durable discoveries, risks, and separately gated next actions.
It also records a digest of HEAD plus the exact porcelain status snapshot. Any
later edit invalidates the report until the owning worker generates a new one.

Terminal states are:

- `LOCAL_READY_COMMITTED`: clean worktree with one or more local task commits;
- `LOCAL_READY_UNCOMMITTED`: verified, reviewable dirty worktree when commits
  were not authorized;
- `BLOCKED`: precise blocker, last successful state, residual findings, and
  the smallest decision or approval needed.

The helper rejects a terminal state inconsistent with live Git state. An
integrator must still re-run `verify`, inspect live Git state, and validate the
named evidence before acting. A readiness report names whether target-branch
freshness was checked against the current local ref or a separately authorized
fresh fetch; it never claims remote currency without that fetch.

## End-to-end data flow

### Preparation

1. The orchestrator runs `guard`; a primary checkout must report
   `COORDINATOR_ONLY` and remains coordination-only.
2. The orchestrator obtains approved independent plans and an integration
   order.
3. It creates one linked worktree and branch per outcome using the existing
   worktree workflow.
4. It runs `prepare`, which validates the linked worktree, rejects a reused
   task project, stores the exact base and plan digest, and creates the narrow
   self-ignore boundary.
5. It reports the exact launch command and stops implementing in that worktree.

### Worker startup

1. The helper starts Codex with `-p parallel-work`, `-C`, the task-specific
   worker environment, and the matching Codex MCP-server environment override.
2. The worker invokes the local orchestration skill.
3. It runs read-only `guard`; an absent descriptor or identity mismatch stops
   the run before mutation.
4. It atomically claims the worktree.
5. It confirms the Engram task project with `mem_current_project` and runs
   `verify`.
6. It reads current repository authority and the approved plan.
7. Only then may it write or dispatch implementation subagents.

### Historical retrieval

1. Task Engram context is read from the task project.
2. Shared Engram queries use specific architecture, issue, API, or file terms;
   broad project recency is not injected.
3. ctx searches include the task ID plus a worktree, session, file, or error
   filter and begin with a small result limit.
4. Retrieved claims are verified against current files, tests, and Git state.

### Compaction and resume

1. The normal Engram compaction instruction saves the compacted summary to the
   task project and reloads task-project context.
2. Before any further repository mutation, the worker re-runs `guard`, `claim`
   idempotently, `mem_current_project`, and `verify`.
3. A root, branch, owner, base, plan, or Engram-project mismatch stops the run
   as `BLOCKED`.

### Existing unsafe-session recovery

1. Stop repository mutations in any session that started from the primary
   checkout, an unprepared linked checkout, or without the parallel profile.
2. Capture a handoff naming the physical worktree root, branch, HEAD, porcelain
   status, current goal, verification evidence, and remaining work. Leave
   uncommitted files in that worktree.
3. Exit the old Codex thread and do not resume its session ID into the repaired
   workflow. Startup instructions, profile, root, and MCP environment are fixed
   at process creation.
4. Prepare a descriptor for the existing linked worktree with a unique task
   project, then use the helper to launch a fresh worker.
5. Reconcile the handoff against live Git and require `guard`, `claim`,
   `mem_current_project`, and `verify` before the next write.
6. Retain already-interleaved canonical Engram entries as historical recovery
   data. Do not delete them or blindly merge task projects.

### Completion and integration

1. The worker runs the approved verification and review boundary.
2. It writes a consistent completion snapshot.
3. It reports candidate durable discoveries but does not promote them.
4. The worker holds a quiescent checkpoint while the integrator performs
   read-only inspection; a changed Git-state digest invalidates the review.
5. The integrator performs read-only inspection while the worker owns the
   claim.
6. Fixes return to that worker unless ownership is explicitly handed off.
7. Merge, rebase, cherry-pick, push, tracker mutation, deployment, and cleanup
   each retain their existing approval gates.
8. After integration is proven, the orchestrator may promote verified durable
   knowledge to canonical Engram and committed project context.

## Failure handling

The workflow fails closed for:

- a linked checkout without a safe prepared descriptor;
- missing, malformed, unsupported, or symlinked metadata;
- wrong root, branch, owner, base ancestry, plan path, or plan digest;
- missing `CODEX_THREAD_ID` or `ENGRAM_PROJECT`;
- a task project duplicated in another linked-worktree descriptor, including
  duplicates introduced after preparation;
- a requested disposable Engram data directory that is relative, missing, the
  worktree root, or resolves outside the worktree;
- a second claimant;
- an incomplete owner claim;
- an Engram default project mismatch;
- evidence that the Engram plugin hooks still execute under the profile;
- unavailable ctx when a required provenance claim depends on ctx;
- required verification or review that is missing, skipped, malformed, or
  failing;
- a requested terminal state inconsistent with Git;
- any unapproved hosted, provider, integration, destructive, or shipping
  action.

Failure preserves the worktree and reports the smallest recovery step. It does
not fall back to the primary checkout, guess a new owner, weaken verification,
or clean unrelated state.

## Verification strategy

### Deterministic local tests

Dependency-free Zsh tests create disposable Git repositories and linked
worktrees under `/tmp`. They must cover:

1. narrow metadata self-ignore without hiding unrelated Superpowers files;
2. supported schema and required-field validation;
3. physical root, repository, branch, base ancestry, plan path, and plan digest
   checks;
4. rejection of symlinked metadata and plan escape;
5. atomic simultaneous claims;
6. same-thread idempotence and different-thread rejection;
7. incomplete-claim fail-closed behavior;
8. explicit handoff and release;
9. launch and resume command quoting, including worktree paths with spaces;
10. mandatory `codex -p parallel-work -C <absolute-root>`;
11. committed, uncommitted, and blocked completion consistency;
12. completion invalidation after any HEAD or porcelain-status change;
13. local-versus-fetched target freshness reporting;
14. compaction/resume re-verification;
15. offline Engram MCP probes proving two process-level task projects remain
    distinct;
16. profile syntax and Stow behavior while preserving unrelated `~/.codex`
    runtime state;
17. a behavioral profile probe proving plugin hooks are absent while Engram
    MCP, global instructions, and Superpowers remain present;
18. exact launch/resume arguments plus a provider-free `mcp list --json` probe
    proving per-launch task-project and optional isolated-data-directory values
    reach the Engram MCP server configuration;
19. primary-checkout, unprepared-linked-checkout, prepared-unclaimed, and
    owned-writer `guard` classifications;
20. prepare-time rejection of duplicate task projects across linked worktrees;
    and
21. runtime rejection after descriptor drift creates a duplicate task project.

Item 17 may use Codex's offline prompt/config debug surface if it exposes
hook resolution. If no offline surface can prove it, static checks are not
misreported as behavioral proof; that gate moves to the authorized canary.

### Skill pressure tests

Following `superpowers:writing-skills`, first record baseline failures without
the skill, then verify the skill closes the observed rationalizations. Scenarios
include skipping a claim because the branch name looks right, trusting a
compacted summary over Git, using broad Engram context, claiming an occupied
worktree, editing from the orchestrator after handoff, and auto-cleaning after
completion.

### Adversarial multi-worker canary

This is provider-backed and requires separate authorization. Run at least two
workers and one integrator with:

- contradictory task descriptors and overlapping terminology;
- deliberately misleading shared Engram memories;
- distinct task Engram projects;
- a duplicate-owner race;
- compaction and resume;
- one SDD worker with authorized local commits and one uncommitted worker;
- task-qualified ctx reconstruction;
- read-only integration review followed by combined verification.

Promotion requires zero wrong-root edits, zero dual ownership, zero
cross-task default memory reads or writes, correct post-compaction identity,
correct provenance attribution, accurate completion states, and no unauthorized
integration or cleanup.

Canary prompts and schemas must preserve measurement honesty. Expected project,
owner, and reviewer counts are separate from unconstrained observed values;
spawn attempts and successfully created reviewers are distinct fields. A
default full-history reviewer fork omits an explicit `agent_type`; if a typed
reviewer is required, the canary must use a non-inherited fork contract. Router
rejection or missing review remains blocking and is never coerced into the
expected schema value.

## Rollout and fork trigger

1. Write and review this design and its test-first implementation plan.
2. Implement only in the isolated dotfiles task worktree.
3. Run deterministic tests without altering live `~/.codex` configuration.
4. Before promising a separate activation gate, inventory the installed target
   with `readlink` or `realpath` and compare source and live hashes. Creating a
   Stow link is a separate activation action. Once an installed target already
   links to tracked source, however, integrating or editing that source is
   effective activation; its approval envelope must combine integration and
   activation or use a staging copy that is not live-linked.
5. Repair ctx separately if provenance evaluation still requires it.
6. Request separate approval for the adversarial provider-backed canary.
7. Canary on bounded, low-risk tasks before using the workflow portfolio-wide.
8. Preserve all worktrees and evidence through integration and until the owner
   separately approves cleanup.

For this remediation, the installed `worktree-session` helper already linked
to the tracked dotfiles source. Integrating the reviewed implementation as
`d423441` therefore changed the live helper without another Stow command. The
owner accepted that effective activation on 2026-08-09. It does not constitute
the fresh provider-backed canary, remote publication, or cleanup approval.

Do not fork Engram merely because its optional Codex hooks are unsuitable for
parallel workers. Reconsider a fork only when all of the following are true:

1. the no-fork profile, task-project override, helper, and instructions pass
   their deterministic gates but a reproducible canary still crosses memory
   or ownership boundaries;
2. the failure is in Engram behavior rather than worker instructions, Codex
   profile resolution, or ctx retrieval;
3. disabling the optional plugin globally is unacceptable to the owner;
4. an upstream configuration or narrowly scoped upstream fix is unavailable
   or rejected;
5. the fork has a bounded patch, regression tests, an update strategy, and a
   named maintainer cost the owner explicitly accepts.

The same evidence threshold applies before changing the Superpowers fork. The
initial implementation adds no upstream divergence to either project.

## Security and privacy boundaries

- Never copy the live base `~/.codex/config.toml`, auth state, tokens, prompts,
  or private indexes into dotfiles or completion reports.
- The tracked profile contains only non-secret overrides.
- Task metadata may contain local absolute paths and remains ignored.
- Task IDs, project names, owner IDs, and config values reject newlines and
  other control characters.
- All paths are quoted; the helper never evaluates descriptor content as shell
  code.
- Symlink checks prevent metadata writes from escaping the worktree.
- The claim is a cooperative agent guard, not an operating-system ACL. It must
  be combined with one writable worktree per top-level session and the Codex
  `-C` launch boundary.
- Workers call `mem_save` with `capture_prompt=false`; automatic prompt and
  subagent capture is disabled with the plugin.
- Shared hosted artifacts and runtimes remain exclusive unless independent
  isolation is separately proven.

## Documentation ownership

After successful implementation and owner acceptance:

- `codex-config/.codex/AGENTS.md` keeps the concise cross-project concurrency
  policy;
- `.Codex-context.md` records the durable launch-root, control/provenance/memory
  hierarchy, and Engram-hook gotcha;
- this specification remains the detailed architecture record;
- the implementation plan records exact files, TDD steps, and verification;
- a branch progress note records the tested state and continuation point;
- Engram stores a project-scoped pointer to this authoritative specification,
  not a competing copy of current task state.

## Acceptance criteria

The design is implemented only when:

1. no Engram or Superpowers fork changed;
2. every worker has one mechanically verified worktree, branch, owner thread,
   approved plan digest, and default Engram task project;
3. a session implements only in its startup checkout, and a primary
   `COORDINATOR_ONLY` session uses only the narrow approved-plan and descriptor
   bootstrap exception across roots;
4. an unprepared linked checkout and a duplicate task project both fail before
   repository mutation;
5. a second top-level writer fails before repository mutation;
6. plugin-driven broad context, prompt capture, and subagent capture are absent
   in the parallel profile while explicit Engram tools remain usable;
7. ctx provenance is task-qualified and never treated as current authority;
8. compaction and resume re-establish live identity before writes;
9. committed, uncommitted, and blocked outcomes are reported accurately;
10. the helper performs no integration, hosted mutation, shipping, or cleanup;
11. deterministic tests pass and the authorized adversarial canary meets every
   promotion criterion;
12. live activation, local commits, provider calls, integration, publication,
    and cleanup occur only under explicit owner approval; an existing Stow link
    requires integration and effective activation to share an approval envelope
    unless changes are staged outside the live-linked source.
