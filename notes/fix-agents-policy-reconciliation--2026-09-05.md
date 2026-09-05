# DOTFILES-AGENTS-POLICY handoff — 2026-09-05

## What works

- The new Python 3.9 standard-library helper uses unprofiled Codex app-server
  `config/read` and version-guarded `config/batchWrite` rather than serializing
  TOML. Report/dry-run is scoped to four Engram settings; production-home apply,
  custom instruction targets, unsafe paths, ambiguous origins, stale versions,
  malformed input, and incomplete writes fail closed.
- Credential-free temporary fixtures prove both inherited instruction-file
  failures, native deletion, disabled default/profile MCP state, unrelated config
  preservation, AGENTS discovery, idempotence, and child-process cleanup.
- Bounded-autonomy policy and design now reuse a matching prepared startup
  worktree, require coordinator-to-fresh-writer handoff when preparation is
  needed, and block wrong-root/resume mismatches without weakening sole-owner or
  explicit-orchestration boundaries.
- On this exact uncommitted worktree, all approved deterministic commands passed:
  the 16-test Python suite, `parallel-work-profile.zsh`,
  `codex-config-stow.zsh`, `parallel-worktree-session.zsh`, and
  `git diff --check`.
- Initial independent review found three Important issues. Review-fix round 1
  replaced buffered protocol framing with byte-buffered line handling, sanitized
  non-UTF-8 failures, and changed both fixtures to explicit credential-free
  environment allowlists. Focused verification and scoped re-review passed with
  no Critical or Important findings.
- A later read-only activation preflight exposed Codex's implicit MCP behavior:
  `mcp_servers.engram.enabled` can be effectively `true` with no direct origin
  when the user-layer server table omits the flag. The helper now accepts only
  that narrow case after validating the raw user-layer table and every available
  server-field origin against the same file/version; missing or mixed provenance
  remains rejected. Credential-free RED/GREEN coverage includes the native
  implicit default, fixture apply, and negative provenance cases.

## Boundaries and remaining evidence

- No live config, Stow target, plugin/cache file, memory store, hosted artifact,
  credential, commit, or remote was mutated. Repository changes do not activate
  the policy; running Codex sessions retain their startup instructions.
- A parent-owned live-home dry-run remained read-only and found the implicit MCP
  origin case above; it made no live mutation. This repair itself remains proven
  through disposable native app-server fixtures rather than production apply.
- The existing profile test still reports its pre-existing `PENDING_CANARY` for
  hook suppression plus policy/Superpowers loading. No model thread or provider
  canary is authorized or required for this local milestone.
- One Minor review item is parked: the test-only native `AppServerClient` retains
  buffered text reads. Current native fixture traffic is deterministic, while
  the production reader and its coalesced-message regression use byte buffering;
  changing the independent test client is not needed for the approved behavior.

## How to continue

1. On resume, repeat `worktree-session guard`, claim as owner
   `01a071c1-2223-7033-90cd-de07f0d2f559`, and reconcile root, branch, HEAD,
   dirty allowlist, task, and immutable plan before repository work.
2. Obtain fresh read-only review of the exact quiescent diff. Return any fixes to
   this writer and rerun affected checks; at most two review-fix rounds are
   allowed.
3. Generate and validate the lifecycle completion report while holding the
   claim. Stop at `LOCAL_READY_UNCOMMITTED` or `BLOCKED`.
4. Commit/integration, effective activation, fresh-session verification, and
   cleanup each remain separate owner decisions. Suggested future commit:
   `fix(codex): reconcile memory injection and worktree preflight`.
