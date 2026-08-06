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

## Tools and context

- Prefer `fd` over `find` and `rg` over `grep`; use fallbacks when unavailable.
- Use Context7 when current external library or framework documentation matters.
- Use the available planning/task tool for substantial multi-step work and keep
  its status current.
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
