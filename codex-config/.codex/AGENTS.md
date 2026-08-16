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
  in another checkout through `workdir`, `git -C`, or absolute paths. A session
  started in a primary checkout may coordinate creation of another worktree,
  but it must not implement there. When explicit multi-writer orchestration is
  selected, its only cross-root mutation is the narrow approved-plan and
  descriptor bootstrap; source, test, configuration, and implementation edits
  wait for the prepared writer. The ordinary no-handoff path is to create the
  worktree in the shell first, `cd` into it, and start Codex there.
- Ordinary single-task work has one owner in its startup checkout and does not require a descriptor or claim.
  `Work on <TASK-ID or issue URL>` means resolve
  the task and propose the plan in the current owner session; it does not
  silently create coordinator authority or permit cross-root writes. Use
  repository-local worktree lifecycle commands when present and fall back to
  `using-git-worktrees` only when needed.
- A mutable hosted artifact or environment also has one active writer. This
  includes a pull request, tracker issue, deployment, staging environment, and
  provider configuration; hand off ownership before another session mutates it.
- Treat a simulator, physical device, shared database, provider budget, or
  other shared runtime as exclusive unless the project proves isolation.
- Parallel changes to overlapping or high-conflict files are allowed only with
  an explicit integration owner and reconciliation order. Do not serialize all
  work merely because eventual integration may produce conflicts.
- After compaction or resume, and at session start, reconcile the repository
  root, branch, HEAD, dirty state, current task, and any active review artifact
  against live state before acting on summaries. The active conversation,
  transcript/resume state, and task-local notes support recovery but do not
  override verified repository state.
- Invoke `orchestrating-parallel-worktrees` only for two or more writer sessions
  or an existing `.superpowers/parallel/session.conf`. In that explicit
  multi-writer workflow, the coordinator may perform the narrow approved-plan
  and descriptor bootstrap in a new unclaimed worktree, then each prepared
  writer must run `worktree-session guard` and claim its descriptor before
  writing. A missing or stale descriptor fails closed only after orchestration
  has been selected; it is not required for an ordinary sole-owner worktree.
  `COORDINATOR_ONLY` permits coordination, never implementation in another
  checkout.
- A prepared multi-writer session repeats guard, claim, and live-state
  reconciliation after compaction or resume. Git plus the descriptor and owner
  claim are current authority; memory and transcript labels are not.
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

The active conversation, Codex transcript/resume state, live Git, and committed
task-local plans or notes are the default working context. Historical lookup is
optional and must never establish current ownership, task scope, completion, or
repository truth.

- Use ctx only when original discussion, rejected approaches, regressions, exact
  prior commands, or source-session provenance materially matters. Follow the
  installed `ctx-agent-history-search` skill: start with concrete identifiers
  and a small result limit (normally 5), inspect a focused event window, and
  broaden only when necessary.
- Treat existing Engram history as legacy reference material. Do not load broad
  shared recovery context automatically, construct per-task Engram projects, or
  merge memory stores blindly. Verify any retrieved claim against current source.
- Curated canonical Engram memory is optional and deliberate. Write it only from
  a reconciled canonical checkout after integration, not as task-worktree
  working memory.

For a durable architecture or product decision, update the appropriate ADR or
design document in Git. When canonical Engram capture is explicitly appropriate,
use a stable topic key and record the authoritative path under `Where`; ask before
recording a superseding or conflicting relationship between architecture,
policy, or decision memories.

## Elixir/Phoenix

- Prefer modern Elixir patterns such as `with/else`, explicit data contracts,
  composable functions, and `Ecto.Multi` for transactional workflows.
- Combine `@spec` and Dialyzer with runtime guards where layered correctness is
  useful.
- Use property-based tests for complex invariants and example-based tests for
  specific behavior.
