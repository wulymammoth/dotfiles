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

## Corrective checkpoint after approved plan refresh

The preceding sections preserve the earlier reviewed milestone as historical
evidence. The refreshed corrective plan supersedes its blanket Engram restriction
without rolling back the startup-root, ownership, native-config, or security
work.

- The default and `parallel-work` contract now removes both instruction-file
  overrides, keeps the Engram plugin and bulk hooks disabled, and keeps the
  Engram MCP server enabled. Engram is ADR-centric supplementary decision memory;
  ctx remains the source for original discussion, commands, rejected approaches,
  regressions, and source-session provenance. Current repository authority still
  controls implementation truth.
- Memory writes use the actual runtime thread ID and physical startup directory
  for `mem_session_start`, then retain the returned canonical project and pass it
  with an explicit `session_id` to saves and summaries. This proves attribution,
  not ownership, topic isolation, or a security boundary. Unknown or mismatched
  attribution fails; an unverified subagent returns candidate learnings to its
  owner.
- The native helper now treats explicit or narrowly proven implicit MCP `true`
  as clean and explicit `false` as `set_true`. An apply uses the existing native
  versioned batch transaction and a second fresh app-server process to validate
  scoped state plus unchanged unscoped raw user config. Default production-home
  refusal remains; `--allow-production-home` is a tested opt-in requiring apply
  and an inspected expected version, but is not approval by itself and was not
  used on real home.
- The parked test-client framing item above is resolved in this corrective scope:
  its app-server client now uses strict byte-buffered framing and cleans up after
  failed initialization.
- A new installed-MCP fixture invokes only `engram mcp --tools=agent` with a
  credential-free environment, autosync disabled, existing network restriction,
  and a valid precreated SQLite database under an isolated temporary data root.
  It proves the required agent tools and proactive instructions, shared-project
  ADR search, explicit two-session saves/summaries, retrieval, persisted
  attribution, and negative unknown/mismatched controls without touching real
  memory. It never runs Engram version/help.
- Runtime identity is pinned to installed executable SHA256
  `cbcb115278c332313d35c1500d261eadfc9ff74d400b021f06b3362b1df2d80a`.
  Read-only source reference
  `1dafc0f63051b2214100f7bd801357e4aab61c26` differs from the installed build,
  so the installed fixture—not source inspection—provides behavior evidence.
- Initial complete-manifest and supplemental review found two Important native
  helper gaps: a missing MCP server could report clean, and raw user-layer
  validation occurred after `config/batchWrite`. Focused RED/GREEN regressions
  now reject a missing server rather than create an enabled-only entry and prove
  a missing/non-object raw layer makes zero native write calls. The full
  unscoped snapshot is computed before mutation.
- A subsequent final-manifest review found two more Important edge cases and one
  stale scenario sentence. Raw implicit-MCP provenance now requires an exact
  origin for every scalar, list element, and nested leaf. An absent plugin stanza
  is consistently treated as hook-disabled on a no-op and is established as
  explicit `false` when another scoped correction writes. RED/GREEN coverage
  includes partial list/nested origins and both absent-plugin paths; the schema-v1
  scenario now says the plugin is disabled while MCP remains available.
- Current local verification passes 23 native-helper tests, the installed MCP
  contract test, `parallel-work-profile.zsh`, `codex-config-stow.zsh`,
  `parallel-worktree-session.zsh`, and `git diff --check`. The profile test still
  reports `PENDING_CANARY`: no provider-backed model/hook canary, real-home
  activation, or fresh live Codex session is authorized in this checkpoint.
- No production config or memory, home Stow target, provider/runtime, other
  checkout, hosted artifact, stage, commit, or remote was mutated. Independent
  complete-manifest review, a fresh `origin/main` ancestry check, and a truthful
  `LOCAL_READY_UNCOMMITTED` report remain before handoff; the writer claim stays
  held.
