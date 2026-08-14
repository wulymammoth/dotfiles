## Startup and authority

At the start of a session, determine the current repository and branch. Inspect
these files when present:

- `README.md`
- `<current branch name>.md`
- `Codex.local.md`
- `.Codex-context.md`

If a file is large, inspect its headings and only the sections relevant to the
current task. Current repository code, tests, specifications, design documents,
and accepted ADRs are authoritative over notes, ctx transcripts, and memories.

## Concurrent sessions

- A writable checkout and branch have one active writer session at a time. Its
  named executor may dispatch project-approved workers with explicit,
  non-overlapping ownership and remains responsible for integration. Other
  sessions may inspect read-only, but a review verdict must target a named
  commit or explicitly quiescent checkpoint. Independent writer sessions must
  use isolated checkouts or worktrees, each on its own task branch.
- During a concurrent-worktree workflow, the startup checkout is the only checkout it may mutate. Record its physical root before work. It must not implement
  in another checkout through `workdir`, `git -C`, or absolute paths.
  A primary-checkout coordinator may create the approved plan and descriptor in
  a new, unclaimed linked worktree as the narrow plan and descriptor bootstrap;
  source, test, configuration, and implementation edits wait for the fresh
  writer launched at that exact worktree root.
- `Work on <TASK-ID or issue URL>` is sufficient to start this workflow from a
  primary checkout: automatically act as coordinator, invoke
  `orchestrating-parallel-worktrees`, and resolve the tracker record read-only
  to derive the goal. Use repository-local worktree lifecycle commands when
  present and fail closed; only otherwise fall back to `using-git-worktrees`.
  Present the derived goal and plan for approval, prepare a unique task-scoped
  descriptor, and return the helper launch command; implementation waits for
  the fresh helper-launched writer in that worktree.
- A mutable hosted artifact or environment also has one active writer. This
  includes a pull request, tracker issue, deployment, staging environment, and
  provider configuration; hand off ownership before another session mutates it.
- Treat a simulator, physical device, shared database, provider budget, or
  other shared runtime as exclusive unless the project proves isolation.
- Parallel changes to overlapping or high-conflict files are allowed only with
  a named integration owner and reconciliation order. Do not serialize all work
  merely because eventual integration may produce conflicts.
- After compaction or resume, and at session start, reconcile the repository
  root, branch, HEAD, dirty state, current task, and any active review artifact
  against live state before acting on summaries. Engram and ctx support
  recovery; they do not establish current ownership. Project-level recovery
  memory can contain concurrent-session activity and must not override the
  active conversation or verified checkout state.
- When the current checkout is linked, or when a primary checkout starts
  coordinating linked-worktree implementation, invoke
  `orchestrating-parallel-worktrees` and run `worktree-session guard` before any
  write. This trigger applies whether or not
  `.superpowers/parallel/session.conf` exists: a missing descriptor is a
  fail-closed result, not permission to continue. `COORDINATOR_ONLY` permits
  coordination plus the narrow bootstrap above, never implementation in a
  linked checkout.
- A prepared linked-worktree writer must claim the descriptor, call
  `mem_current_project`, and pass its literal result to mechanical verification
  before writing. Repeat guard, claim, and verification after compaction or
  resume. Git plus the descriptor and owner claim are current authority;
  Engram and ctx are not.
- Before declaring work ready, refresh the target base and prove the result is
  current and mergeable. Use the repository's chosen merge or rebase policy
  rather than imposing one globally. Repository-local instructions define the
  concrete ownership tuple, isolation commands, and runtime boundaries.

## Tools and context

- Prefer `fd` over `find` and `rg` over `grep`; use fallbacks when unavailable.
- Use Context7 when current external library or framework documentation matters.
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
- Do not check or require `gh` authentication when `git` and GitHub MCP cover
  the requested operation.
- Use `gh` only as a fallback after GitHub MCP lacks the capability or returns
  a concrete failure.
- This policy supersedes workflow-skill defaults that require `gh` when local
  `git` and GitHub MCP can complete the operation.
- Tool selection does not grant mutation authority. Preserve explicit approval
  gates for pushes, pull-request or issue changes, reviews, merges, and releases.

## Linear operations

- Prefer direct Linear MCP (`mcp__linear__*`); use the bundled connector only
  after a concrete capability gap or failure. This supersedes skill defaults.
- Preserve explicit approval gates for Linear mutations.

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
8. For completed repository work, propose a commit message and ask for explicit
   approval before committing. Commit only complete, verified milestones; no
   commit is required when no tracked repository files changed.

## Bounded autonomous work

When the user explicitly approves a named plan or goal for bounded autonomous
execution, first read `~/.codex/policies/bounded-autonomy.md`. That approval may
cover only the envelope recorded in the plan: one harness-owned isolated
worktree, named local commands, and local checkpoint commits only when expressly
allowed. Isolation, verification, review, and required evidence fail closed.
The run ends at `LOCAL_READY` or `BLOCKED`; all hosted, production, provider,
paid, destructive, authentication, provisioning, device/store, and shipping
actions retain their separate approval gates. Otherwise, the normal per-action
and per-commit rules above remain in force.

## Decision and historical memory

Before planning substantial work on an existing subsystem:

1. Call Engram `mem_context`; use `mem_search` only when relevant decisions,
   conventions, or constraints are not already available.
2. Use ctx when original discussion, rejected approaches, regressions, exact
   prior commands, or source-session provenance may matter. Follow the installed
   `ctx-agent-history-search` skill: start with concrete identifiers and a small
   result limit (normally 5), inspect a focused event window, and broaden only
   when necessary. Use `--refresh off` only when the current index is sufficiently
   fresh and stable read-only lookup is desired.
3. Verify retrieved memory against the current repository.

For a durable architecture or product decision, update the appropriate ADR or
design document in Git and save a project-scoped Engram memory with a stable
topic key and the authoritative path under `Where`. Reuse the topic key as the
decision evolves. Ask before recording a superseding or conflicting relationship
between architecture, policy, or decision memories.

## Elixir/Phoenix

- Prefer modern Elixir patterns such as `with/else`, explicit data contracts,
  composable functions, and `Ecto.Multi` for transactional workflows.
- Combine `@spec` and Dialyzer with runtime guards where layered correctness is
  useful.
- Use property-based tests for complex invariants and example-based tests for
  specific behavior.
