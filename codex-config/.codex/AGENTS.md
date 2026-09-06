## Startup and authority

For repository work, determine the current repository and branch. Inspect these
files when present, reading only relevant sections of large files:

- `README.md`
- `<current branch name>.md`
- `Codex.local.md`
- `.Codex-context.md`

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
  `Work on <TASK-ID or issue URL>` means resolve the task and propose its plan;
  it does not select orchestration or authorize cross-root implementation.
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

- Recommend a concrete delivery plan using known repository and session context.
  One explicit approval can cover implementation, multiple verified checkpoint
  commits, pushing the named task branch, and creating or updating its pull
  request. State sensible defaults for the remote, PR base, and draft/ready intent.
  A direct user request can supply this approval without another planning gate.
- Keep that approval across steps, turns, and resume within the approved scope.
  Choose appropriate checkpoint boundaries and commit messages, run relevant
  checks, and report progress without asking again for each commit, push, or PR.
  This overrides workflow-skill defaults that split already-authorized actions
  into separate confirmation prompts.
- Ask again only when authorization is missing or a material change affects
  scope, destination, risk, or the agreed outcome. For actions still awaiting
  approval, prepare a concrete, verified result first, then ask one consolidated
  question for the remaining delivery steps. Coding or review alone does not
  authorize publication.
- Merge, deployment, release, destructive operations, and paid/provider/device
  actions require explicit authorization beyond the commit/push/PR bundle.
  A bounded autonomous run keeps its local-only envelope; separately authorized
  delivery can follow `LOCAL_READY` without repeating an existing approval.

## Tools and context

- Prefer `fd` over `find` and `rg` over `grep`; use fallbacks when unavailable.
- Use Context7 when current external library or framework documentation matters.
- For Maestro-based native UI tests or explicit Expo/React Native harness
  adoption, use `maestro-mobile-testing`. Retain the repository's chosen test
  stack; global tool availability does not authorize runtime or cloud actions.
- Use the available planning/task tool for substantial multi-step work and keep
  its status current.
- Write shell snippets for their declared interpreter. In zsh, the special
  parameters `status` (read-only) and `path` (tied to `PATH`) can terminate a
  wrapper or replace its executable search path. Use descriptive names such as
  `git_status_text` and `changed_paths_text`. Run
  Bash-specific multiline wrappers explicitly with `bash` rather than relying
  on the default shell.
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
- For committed image media embedded in GitHub issue or pull-request Markdown,
  do not use `raw.githubusercontent.com` or tokenized download URLs in private
  repositories. Use a commit-pinned repository-relative source:
  `../blob/<full-commit-sha>/<repository-relative-path>?raw=true`.
- Before publishing or updating GitHub Markdown with committed media, verify
  each target exists at the pinned commit. After the mutation, re-read the
  artifact and confirm the expected embed count, zero forbidden raw-host URLs,
  and rendered visibility when an authenticated browser is available.
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

1. Understand the problem, then inspect existing code, tests, and established
   patterns before proposing changes.
2. Ask targeted questions only when ambiguity materially affects behavior,
   scope, safety, or acceptance criteria; otherwise state reasonable assumptions.
3. For substantial or ambiguous changes, present a concise implementation plan
   and obtain confirmation before coding. Trivial, mechanical, or already
   explicitly authorized changes do not require another planning gate.
4. Use TDD for behavior-changing code when practical: write or update a failing
   test, implement the smallest passing change, then refactor. Explain when TDD
   is not applicable.
5. Follow project conventions, SOLID design, and maintainable boundaries. Analyze
   performance and scalability when they are material to the task.
6. After implementation, update affected tests and run the smallest sufficient
   verification suite before claiming success.
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
plans or notes as working context. Historical lookup is optional and never
establishes current ownership, task scope, completion, or repository truth.

- Use ctx for original discussion, rejected approaches, regressions, exact prior
  commands, or source-session provenance when material. Follow its installed
  skill: concrete identifiers, small limits (normally 5), focused event windows,
  then broaden as needed. Use `--primary-only` for user-intent and decision
  provenance; retain primary-plus-subagent scope for implementation/test evidence.
- Use Engram as supplementary ADR/decision memory and verified durable lessons.
  Scope recall to the reconciled canonical project and current work; verify
  claims against source. Preserve history without broad recovery dumps, per-task
  Engram projects, or blind store merges.
- An enabled Engram MCP can advertise proactive saves, summaries, and project
  context even with shell-plugin hooks disabled. Do not describe it as manual-only
  or instruction-free, or invent a new memory mode, proxy, or wrapper.
- At the first memory write, call `mem_session_start` with the actual runtime
  thread ID and physical startup directory, retain its returned canonical
  project, and pass that explicit project and `session_id` to every `mem_save`
  and `mem_session_summary`. Attribution is not an ownership, isolation, security,
  readiness, or coding-startup boundary. Never manufacture an ID or treat a
  parent's ID as a distinct subagent identity.
- Prefer direct `mem_save(capture_prompt:false)` for established architecture,
  policy, decision, root-cause, or verified-lesson records. Include the source path
  and decision status; distinguish verified outcomes from pending work. Topic-key
  upserts are project-shared, regardless of session identity.
- An unknown or mismatched session/project stops that memory write. Do not retry
  by dropping identifiers or selecting the latest session. Subagents without
  verified identity return candidate durable learnings to their owner. Disclose
  pending capture; memory unavailability does not block unrelated coding unless
  a higher-priority requirement says to stop.

For a durable architecture or product decision, update the appropriate ADR or
design document in Git. When Engram capture is appropriate, use a stable topic
key and record the authoritative path under `Where`; require existing explicit
decision authority before recording a superseding or conflicting relationship
between architecture, policy, or decision memories.

## Elixir/Phoenix

- Prefer modern Elixir patterns such as `with/else`, explicit data contracts,
  composable functions, and `Ecto.Multi` for transactional workflows.
- Combine `@spec` and Dialyzer with runtime guards where layered correctness is
  useful.
- Use property-based tests for complex invariants and example-based tests for
  specific behavior.
