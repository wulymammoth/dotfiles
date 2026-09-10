# Codex Engram Availability and Attribution

## Purpose and authority

Codex has four independent configuration surfaces related to Engram:

1. `model_instructions_file` replaces the built-in model instructions.
2. `experimental_compact_prompt_file` replaces the built-in compaction prompt.
3. `plugins."engram@engram".enabled` activates the shell plugin and its bulk
   prompt, recovery, and passive-capture hooks.
4. `mcp_servers.engram.enabled` makes Engram MCP tools available.

The desired tracked default and normal task-profile state removes both
instruction-file overrides, sets the plugin to `false`, and enables the MCP
server. A wholly absent plugin stanza is also hook-disabled: a clean no-op leaves
it absent, while another required scoped write establishes explicit `false`. This keeps
ADR-centric memory available without restoring the plugin's bulk hooks. MCP
startup instructions can still require proactive saves, concise session
summaries, and project-scoped context; MCP is not manual-only, instruction-free,
or process-read-only merely because the plugin is off.

Engram is supplementary ADR/decision memory, including verified durable lessons.
ctx supplies original discussions, exact commands, rejected approaches,
regressions, and source-session provenance. Current repository code, tests,
specifications, design documents, and accepted ADRs remain authoritative. Memory
does not establish current ownership, task scope, completion, or repository
truth, and project-wide recent sessions are history rather than task recovery.

This repository patch does not activate or change installed machine
configuration. It does not migrate, delete, or merge existing memory data and it
does not create a new framework, per-task project system, proxy, or MCP wrapper.

## Explicit write attribution

Scope searches and context to the reconciled canonical project and the work at
hand. Shared project recall is intentional; a session identifier is attribution,
not topic isolation or a security boundary.

At the first memory write:

1. Call `mem_session_start` with the actual runtime thread ID and physical
   startup directory.
2. Retain the canonical project returned by the server.
3. Pass that explicit project and `session_id` to every `mem_save` and
   `mem_session_summary` call.

Do not manufacture an ID, inherit a parent ID as a distinct subagent identity,
or recover by selecting the latest session. A subagent without independently
verified identity returns candidate durable learnings to its owner for capture.
An unknown or mismatched session/project stops that write; never retry by
dropping either identifier. Memory unavailability should be disclosed as pending
capture and does not block unrelated coding unless a higher-priority requirement
requires a stop.

For ADRs, decisions, root causes, and verified lessons, prefer direct
`mem_save(capture_prompt:false)` with a stable topic key. Include the
authoritative source path under `Where` and the decision status in the content.
Session summaries remain concise and distinguish verified outcomes from pending
work. Topic-key upserts are project-shared. Require existing explicit decision
authority before saving a superseding or conflicting architecture, policy, or
decision relationship.

## Native reconciliation interface

This is an on-demand maintenance operation when the four settings need repair.
It is not required before ordinary work or parallel execution. Profile and Stow
verification use the intended configuration directly; repair-specific assertions
and native transactions stay in `tests/test_codex_memory_policy.py`.

[`scripts/codex-memory-policy.py`](../scripts/codex-memory-policy.py) inspects and
reconciles the four settings through Codex's native app-server configuration API.
Run it with the same `HOME`, `CODEX_HOME`, and XDG roots whose user configuration
is being inspected:

```sh
# Report/check only. Exit 1 means reconciliation is needed; exit 0 means clean.
python3 -B scripts/codex-memory-policy.py

# Explicit read-only preview. Output is limited to config identity and four actions.
python3 -B scripts/codex-memory-policy.py --dry-run

# Approved fixture or other non-production apply.
python3 -B scripts/codex-memory-policy.py \
  --apply \
  --expected-version 'sha256:<version-from-the-inspection>'
```

`--apply` requires the exact inspected version. It refuses the account's real
`~/.codex/config.toml` by default. The same native transaction supports a later,
separately approved production activation only through this explicit form:

```sh
python3 -B scripts/codex-memory-policy.py \
  --apply \
  --allow-production-home \
  --expected-version 'sha256:<fresh-live-version>'
```

`--allow-production-home` is valid only with `--apply` and
`--expected-version`; the flag is a mechanical opt-in, not user approval. Do not
use a private helper or separate TOML writer for activation. After an approved
activation, use a fresh session to verify effective default and task-profile
behavior because running sessions retain their startup instructions and hooks.

The helper starts unprofiled `codex app-server --listen stdio://`, initializes
the JSON-RPC connection, and calls `config/read` with `includeLayers: true`. Its
byte-buffered reader strictly decodes UTF-8, drains coalesced messages, and closes
children even when initialization fails. It accepts exactly one unprofiled user
layer whose canonical file is `$CODEX_HOME/config.toml`. Profile, system,
managed, ambiguous, unsafe, symlinked, or unexpected instruction targets fail
closed.

Codex may report an effective `mcp_servers.engram.enabled = true` default even
when the raw user server table omits `enabled`. The helper accepts that narrow
implicit default only when the raw `mcp_servers.engram` table exists in the exact
user layer, every raw scalar/list/nested leaf has exact matching origin evidence,
and every reported server origin has the same file and version. Missing,
partial, or mixed
provenance still fails closed. Explicit `false` requires `set_true`; explicit or
valid implicit `true` is clean. A wholly missing Engram server is incomplete and
is never replaced with an unsafe enabled-only entry lacking command/arguments.

An approved apply sends native `config/batchWrite` with the inspected file and
exact expected version. JSON `null` removes both instruction keys; native
upserts set the plugin to `false` and MCP to `true`, retaining its command and
arguments. Before that write, the helper validates the raw user layer and
computes its full unscoped snapshot; a missing or non-object raw layer therefore
fails without calling `config/batchWrite`. A second, fresh app-server process
validates the new version, all four scoped results, and semantic equality of the
unscoped raw user layer. The helper never serializes TOML, replaces the whole
config, prints raw protocol or unrelated values, starts Engram, creates a model
thread, or invokes a provider. Native removal can drop comments attached to
removed keys; unrelated settings and Engram data remain intact.

## Credential-free verification

`tests/test_codex_memory_policy.py` uses disposable `HOME`, `CODEX_HOME`, XDG,
and workspace roots to prove:

- report and dry-run remain read-only and expose only four scoped operations;
- explicit false, explicit true, and the narrowly proven implicit MCP default;
- exhaustive list/nested raw-leaf provenance and consistent absent-plugin
  no-op/reconciliation behavior;
- rejection of a missing MCP server and a malformed raw user layer before any
  native write;
- native removal/upsert, default and profile MCP availability, preserved command
  and unrelated settings, idempotence, and fresh-process verification;
- default production-home refusal plus the explicit opt-in interface without
  touching the real home;
- expected-version concurrency, exact path/origin, missing/mixed provenance,
  strict protocol/UTF-8, and failed-enter cleanup safeguards.

`tests/test_engram_memory_contract.py` exercises the installed executable only
through `engram mcp --tools=agent`; it never calls the binary's version/help
commands. The reviewed installed executable resolves to Homebrew's Engram build
with SHA256
`cbcb115278c332313d35c1500d261eadfc9ff74d400b021f06b3362b1df2d80a`.
The read-only source reference was commit
`1dafc0f63051b2214100f7bd801357e4aab61c26`, but source and installed build
differ, so source inspection is not runtime proof.

The installed-MCP fixture precreates a valid empty SQLite database under an
absolute temporary `ENGRAM_DATA_DIR`, supplies an explicit credential-free
environment, sets `ENGRAM_CLOUD_AUTOSYNC=0` and `ENGRAM_CLOUD_SYNC=0`, and uses
the existing network restriction. Two temporary Git repositories share a fake
remote-derived project and one isolated database. The fixture verifies the
agent-tool allowlist and proactive server instructions, distinct session
registration, explicit project/session saves and summaries, retrieval and shared
ADR search, persisted attribution, and unknown-session/project-mismatch errors.
It never touches production memory or asserts private per-task retrieval.

For changes to the repair utility or its maintenance contract, run:

```sh
python3 -B -m unittest discover -s tests -p 'test_codex_memory_policy.py' -v
```

For changes to the Engram attribution contract, use its separate fixture suite:

```sh
python3 -B -m unittest discover -s tests -p 'test_engram_memory_contract.py' -v
```

Ordinary profile, Stow, and affected worktree-helper checks are independent of
the repair workflow:

```sh
zsh tests/parallel-work-profile.zsh
zsh tests/codex-config-stow.zsh
zsh tests/parallel-worktree-session.zsh
git diff --check
```

No provider-backed model/hook canary or live-home activation is part of these
checks. Those remain separate approvals and must be reported as pending evidence.
