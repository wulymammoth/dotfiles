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
