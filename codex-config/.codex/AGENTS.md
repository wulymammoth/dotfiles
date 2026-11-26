## Startup and authority

For repository work, determine the current repository and branch. Read only the
context needed for the task: `README.md` for unfamiliar setup or commands,
`<current branch name>.md` for branch-specific work, `Codex.local.md` for local
runtime setup, and `.Codex-context.md` for architecture or recurring regressions.
A mechanical edit does not require reading the full documentation stack.

Current repository code, tests, specifications, design documents, and accepted
ADRs are authoritative over notes, ctx transcripts, and memories.

## Concurrent sessions

- Each writable checkout and branch has one active writer. Its named executor
  may dispatch project-approved workers with explicit ownership and remains
  responsible for integration. Independent writers need isolated checkouts and
  task branches. Other sessions may inspect read-only; review a named commit or
  explicitly quiescent checkpoint. Overlapping parallel changes require an
  explicit integration owner and reconciliation order.
- During worktree workflows, the startup checkout is the only checkout it may mutate.
  Record its physical root before work; never implement in another checkout
  through `workdir`, `git -C`, or absolute paths. A primary-checkout coordinator
  may create the approved plan and descriptor in a new unclaimed worktree only
  under explicit multi-writer orchestration; implementation waits for its writer.
  For ordinary isolated work, create the worktree in the shell, `cd` into it,
  then start Codex there.
- Ordinary single-task work has one owner in its startup checkout and does not require a descriptor or claim.
  `Work on <TASK-ID or issue URL>` means resolve its current scope and carry out
  the clear, authorized local work. State a proportionate plan; ask only about
  material unresolved decisions. It does not select orchestration, authorize
  cross-root implementation, or waive repository isolation requirements.
- Use repository-local worktree lifecycle commands when present. Fall back to
  `using-git-worktrees` only when the repository has no lifecycle tooling. A
  failed guard, ownership check, or required worktree creation stops dependent
  writes; never bypass it with generic tooling or work in place instead.
- Hosted artifacts and environments also have one active writer; hand off before
  another session mutates them. Treat devices, simulators, shared databases,
  provider budgets, and other shared runtime as exclusive unless isolation is proven.
- After compaction or resume, and at session start, reconcile the physical root,
  branch, HEAD, dirty state, current task, and owned review artifacts against live
  state before acting on summaries. Prepared multi-writer sessions also repeat
  guard and claim; their Git state, descriptors, and claims establish ownership.
- Invoke `orchestrating-parallel-worktrees` only for two or more writer sessions
  or an existing `.superpowers/parallel/session.conf`. In that explicit
  multi-writer workflow, each prepared writer must run `worktree-session guard`
  and claim its descriptor before writing. Missing or stale descriptors fail
  closed only after orchestration is selected. `COORDINATOR_ONLY` permits
  coordination, never cross-root implementation. If the skill is unavailable, read
  `${CODEX_HOME:-$HOME/.codex}/skills/orchestrating-parallel-worktrees/SKILL.md`
  directly before continuing.
- Before declaring implementation ready, refresh the target base and prove the
  result is current and mergeable using the repository's merge or rebase policy.
  Repository instructions define concrete isolation commands and runtime limits.

## Approvals and delivery

- A clear request to implement, fix, or refactor authorizes the necessary local
  investigation, edits, relevant verification, and correction of failures caused
  by the change, within the permitted checkout and runtime. An audit, review, or
  request for a proposal alone remains read-only. For substantial work, state a
  concise plan and proceed when behavior, scope, and acceptance are clear; size
  or a workflow transition alone is not a reason to request confirmation.
- Recommend a concrete delivery plan when delivery is requested. One explicit
  approval can cover implementation, verified checkpoint commits, pushing the
  named task branch, and creating or updating its pull request. State sensible
  defaults for the remote, PR base, and draft/ready intent. A direct request can
  supply this approval; local implementation alone does not authorize commits
  or publication.
- Keep that approval across steps, turns, and resume within the approved scope.
  Choose appropriate checkpoint boundaries and commit messages, run relevant
  checks, and report progress without asking again for each commit, push, or PR.
  Workflow skills cannot add confirmation prompts for already-authorized actions
  or require the user to select an execution method again.
- Ask again only when authorization is missing or a material change affects
  behavior, scope, destination, compatibility, cost, risk, or the agreed outcome.
  Identify the uncovered action and the rule or decision requiring approval.
  Complete independent authorized work and prepare a concrete, reviewable result
  before consolidating the remaining approval request.
- Merge, deployment, release, destructive operations, purchases, new provider
  spend/provisioning, physical-device changes, and shared-runtime mutations need
  explicit authorization beyond the commit/push/PR bundle. Task-relevant reads
  through existing connections and verification in an already-authorized isolated
  local runtime need no additional approval unless a repository or tool requires
  it. Credentials, connection availability, and deterministic ports do not grant
  shared-resource ownership. A bounded autonomous run keeps its recorded envelope;
  separately authorized delivery can follow `LOCAL_READY` without reapproval.

## Tools and context

### Tool selection

- Prefer `fd` over `find` and `rg` over `grep`; use fallbacks when unavailable.
- Use Context7 when current external library or framework documentation matters.
- For Maestro-based native UI tests or explicit Expo/React Native harness
  adoption, use `maestro-mobile-testing`. Retain the repository's chosen test
  stack; global tool availability does not authorize runtime or cloud actions.
- Use the available planning/task tool for substantial multi-step work and keep
  its status current.

### Waiting and status checks

- Authorization to run a finite local test, build, or check includes collecting
  its result. Prefer completion notifications or a blocking tool wait; use bounded,
  appropriately spaced status checks only when needed. Use a task-appropriate
  timeout and report a stalled command rather than waiting indefinitely. Do not
  restart a command merely to collect its output or override an explicit no-polling
  instruction. Changed runtime, cost, or retry limits still require authorization.
- Repeated hosted CI, deployment, release, provider-job, or ongoing-service
  monitoring requires explicit authorization. Otherwise check once when needed;
  if still running, report it and yield. Prefer a completion notification, or
  wait for the user to report completion before checking again.
- Retain existing approvals and continue authorized next steps after completion.
  Waiting does not authorize retries, changed gates, or shared-runtime takeover.

### Shell and credential access

- Write shell snippets for their declared interpreter. In zsh, the special
  parameters `status` (read-only) and `path` (tied to `PATH`) can terminate a
  wrapper or replace its executable search path. Use descriptive names such as
  `git_status_text` and `changed_paths_text`. Run
  Bash-specific multiline wrappers explicitly with `bash` rather than relying
  on the default shell.
- When a credential-backed CLI fails inside the sandbox, distinguish host
  credential access restrictions from invalid authentication before requesting
  login, resetting credentials, or creating directory-specific credentials. Use
  an approved, read-only host authentication check when available; any subsequent
  host command still requires authorization for its full effects.

### Context artifacts

- Keep durable project knowledge in committed `.Codex-context.md`: architecture,
  dependencies, recurring regressions, root causes, and prevention strategies.
- Keep machine-specific, non-secret setup in uncommitted `Codex.local.md`. Never
  store raw credentials, tokens, or private keys there; record secret names or
  retrieval instructions instead.
- For major milestones, update `notes/<branch-slug>--<YYYY-MM-DD>.md` inside the
  current repository with what works, what is next, and how to continue. Replace
  `/` in branch names with `-`. Do not log every minor action.

## GitHub operations

- Use local `git` for repository operations, including branch, commit, fetch,
  merge, and push.
- Use GitHub MCP for pull requests, issues, reviews, comments, labels, and
  GitHub-hosted metadata or mutations.
- Before publishing or updating GitHub Markdown with committed images, read
  `~/.codex/policies/github-media.md` for embed and verification requirements.
- Do not check or require `gh` authentication when `git` and GitHub MCP cover
  the requested operation.
- Use `gh` only as a fallback after GitHub MCP lacks the capability or returns
  a concrete failure.
- This policy supersedes workflow-skill defaults that require `gh` when local
  `git` and GitHub MCP can complete the operation.
- Tool selection does not grant mutation authority. Apply the delivery approval
  above; unrelated issue changes and posted reviews require explicit authorization.

## Linear operations

- Prefer direct Linear MCP (`mcp__linear__*`); use the bundled connector only
  after a concrete capability gap or failure. This supersedes skill defaults.
- Include Linear mutations explicitly in an approved plan; tool availability or
  commit/push/PR approval alone does not authorize them.

## Development workflow

For changes to module responsibilities, interfaces, or dependency direction, use
`codebase-design`. For a focused architecture assessment or refactoring-opportunity
review, use `improve-codebase-architecture`. For React or React Native component
APIs, boolean-prop proliferation, or composition/provider design, use
`vercel-composition-patterns`. Read `~/.codex/policies/architecture.md` when any of
these applies or when using dependency-cruiser. Mechanical edits do not trigger
an architecture review; load only the relevant skills and references.

Default to inline execution by the current owner when no method was selected;
retain applicable independent-review requirements. Discuss delegation only when
it materially changes cost, ownership, or delivery. This default supersedes
skill prompts that ask the user to choose an execution method for ordinary work.

For a routine visual correction within an accepted design, reuse its existing
authority and capture proportionate runtime evidence. Do not reopen settled
design choices merely because a file is visual. A governing Design Lock, explicit
visual file allowlist, repository-specific gate, or final human acceptance
requirement still applies; missing authority or a change to load-bearing design
properties is not a routine correction and cannot be waived by this default.

1. Understand the problem, then inspect existing code, tests, and established
   patterns before proposing changes.
2. Ask targeted questions only when ambiguity materially affects behavior,
   scope, safety, or acceptance criteria; otherwise state reasonable assumptions.
3. Plan substantial work proportionately under the authorization rules above.
   Resolve routine implementation choices; ask only about material open decisions.
4. Use TDD for behavior-changing code when practical: write or update a failing
   test, implement the smallest passing change, then refactor. Explain when TDD
   is not applicable.
5. For new features and substantive refactors, record the architecture assessment
   from `~/.codex/policies/architecture.md` in the existing plan or proposal and
   check it against the final diff. Keep routine changes brief. This is engineering
   review within the task, not another approval gate.
6. After implementation, update affected tests and run the smallest sufficient
   verification suite before claiming success. Reuse observed results while the
   relevant code, inputs, and environment remain unchanged; rerun affected checks
   after changes, failures, or new uncertainty.
   Within an authorized local workflow, fix failures caused by the change and
   continue through verification without another approval. Stop at the agreed
   completion boundary or a concrete blocker; report remaining proof gaps.
   For behavior changes to shared components, entry points, interfaces, or test
   harnesses, search repository-wide for affected consumers and existing tests,
   including references to replaced symbols and selectors. Before opening or
   updating a PR, including drafts, update affected tests for intentional changes
   and run the affected suites, including integration coverage where applicable.
   If the impact cannot be confidently bounded, run the relevant package's full
   local suite within the authorized environment. Preserve behavioral assertions,
   reuse still-valid results, and report the verification scope and any checks
   that could not run.
   Before opening or updating a PR, inspect the diff for changes to CI workflows,
   package scripts, build/test configuration, environment contracts, and artifact
   paths. For affected contracts, identify and run the repository's corresponding
   contract checks, applying the result-reuse rule above. Update expectations only
   when the intended contract changed; never weaken checks merely to obtain a
   pass. Report any checks that could not run.
7. Update context or design documents only when durable project knowledge or an
   accepted decision changed.
8. Under an approved delivery plan, commit complete, verified checkpoints as
   useful. No commit is needed when no tracked repository files changed.

## Bounded autonomous work

When the user explicitly approves a named plan or goal for bounded autonomous
execution, first read `~/.codex/policies/bounded-autonomy.md`. That approval may
cover only the envelope recorded in the plan: one harness-owned isolated
worktree, named local commands, and local checkpoint commits only when expressly
allowed. Isolation, verification, review, and required evidence fail closed.
The run ends at `LOCAL_READY` or `BLOCKED`; hosted, production, provider, paid,
destructive, authentication, provisioning, device/store, and shipping actions
remain outside that execution envelope. The delivery approval policy above
governs any separately authorized follow-on work.

## Decision and historical memory

Use the active conversation, transcript/resume state, live Git, and task-local
plans or notes as working context. Historical context alone never establishes
current ownership, task scope, completion, or repository truth.

Before the first substantial recommendation in a new or resumed project session,
search both ctx and Engram for the task, affected feature, and related completed
work. Use small, targeted queries and inspect relevant results.

Reconcile historical findings with current code, accepted decisions, committed
evidence, and live task state. Before recommending implementation, postponement,
replacement, or repeated validation, establish what is already implemented, what
has already passed, and what specifically remains.

Briefly state the historical sources checked and how they affect the
recommendation. No search results do not establish that work was never done.
If a source is unavailable, disclose the gap and qualify recommendations that
depend on it.

Reuse this assessment within the session unless scope changes or new evidence
warrants another lookup. Trivial, self-contained requests are exempt.

- Use ctx for original discussion, rejected approaches, regressions, exact prior
  commands, or source-session provenance when material. Follow its installed
  skill: concrete identifiers, small limits (normally 5), focused event windows,
  then broaden as needed. Use `--primary-only` for user-intent and decision
  provenance; retain primary-plus-subagent scope for implementation/test evidence.
  Prefer configured ctx MCP history tools for Codex retrieval and event
  inspection. If CLI access fails on sandboxed index locks or daemon state,
  use a narrowly approved host lookup with `--refresh off`. Verify that access
  path before diagnosing index corruption or rebuilding. When freshness matters,
  check recent indexed events and the daemon heartbeat; `running` alone does
  not establish that indexing is advancing.
- Use Engram as supplementary ADR/decision memory and verified durable lessons.
  Scope recall to the reconciled canonical project and current work; verify
  claims against source. Preserve history without broad recovery dumps, per-task
  Engram projects, or blind store merges.
  At completion of substantive work, capture newly verified durable decisions,
  root causes, or reusable lessons through the attributed MCP write protocol.
  Reserve session summaries for meaningful handoffs or completed workstreams
  that add useful context beyond saved lessons. Keep routine progress and pending
  approvals in task-local notes; a final reply alone does not trigger a summary.
  Skip duplicate summaries and speculative conclusions. Disabled shell hooks do
  not disable selective MCP capture. If instructions or missing identity prevent
  a warranted capture, report it as pending.
For a durable architecture or product decision, update the appropriate ADR or
design document in Git.

- Before an Engram write or diagnosing its startup/capture behavior, read
  `~/.codex/policies/engram-writes.md`. Missing identity stops only the memory
  write; memory availability never establishes coding readiness.

## Language-specific guidance

For Elixir/Phoenix changes, read `~/.codex/policies/elixir-phoenix.md`.
