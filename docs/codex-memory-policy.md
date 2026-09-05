# Codex Memory-Injection Reconciliation

## Purpose and boundary

Codex currently has four independent configuration surfaces that can inject or
activate Engram behavior:

1. `model_instructions_file` replaces the built-in model instructions.
2. `experimental_compact_prompt_file` replaces the built-in compaction prompt.
3. `plugins."engram@engram".enabled` activates the Engram plugin and its hooks.
4. `mcp_servers.engram.enabled` makes the Engram MCP server available.

Disabling only the named `parallel-work` profile's plugin and MCP entries does
not neutralize instruction-file overrides inherited from base user config. The
tracked helper, [`scripts/codex-memory-policy.py`](../scripts/codex-memory-policy.py),
inspects all four surfaces through Codex's native app-server configuration API.
It prepares a later activation decision. This repository patch does not activate
or change the installed machine configuration, and report mode is read-only.

The intended default and task contexts have no Engram instruction overrides and
have both the plugin and MCP entry disabled. Existing Engram data is preserved.
If canonical capture is deliberately requested later, use separately approved
MCP-only access from a reconciled canonical checkout. Do not restore the
always-save plugin, either instruction override, or invent a new capture profile.

## Safe interface

Run the helper with the same `HOME`, `CODEX_HOME`, and XDG roots whose Codex user
configuration is being inspected:

```sh
# Report/check only. Exit 1 means reconciliation is needed; exit 0 means clean.
python3 -B scripts/codex-memory-policy.py

# Explicit read-only preview. It prints only the inspected config file/version
# and the four scoped operations.
python3 -B scripts/codex-memory-policy.py --dry-run

# Fixture or otherwise non-production apply, only after separate approval.
python3 -B scripts/codex-memory-policy.py \
  --apply \
  --expected-version 'sha256:<version-from-the-inspection>'
```

`--apply` is intentionally refused for the account's production
`~/.codex/config.toml`. Activation of the real machine configuration is a
separate owner-approved action and must use an appropriate non-production
preparation/handoff rather than weakening this guard.

The helper starts unprofiled `codex app-server --listen stdio://`, initializes
the JSON-RPC connection, and calls `config/read` with `includeLayers: true`. It
drains newline-delimited protocol bytes with strict UTF-8 decoding so coalesced
notifications cannot hide a ready response and malformed bytes fail cleanly. It
accepts exactly one unprofiled user layer whose canonical file is
`$CODEX_HOME/config.toml`. It rejects profile, system, managed, ambiguous, unsafe,
or symlinked config paths and refuses instruction targets other than the known
`$CODEX_HOME/engram-instructions.md` and
`$CODEX_HOME/engram-compact-prompt.md` files.

Codex may report an MCP server's effective `enabled = true` default even when
the user layer defines the server but omits that flag; in that case there is no
`mcp_servers.<name>.enabled` origin. The helper accepts this narrow implicit
default only when the raw `mcp_servers.engram` table is present in the exact
unprofiled user layer, every raw server field has matching origin evidence, and
every reported origin for that server has the same user file and version.
Missing, profile, system, managed, or mixed server provenance still fails closed.

An approved non-production apply sends a native `config/batchWrite` with the
inspected file and its exact expected version. JSON `null` deletes the two
instruction keys, while native upserts set the plugin and MCP flags to `false`.
The expected version protects against concurrent changes; the helper then
independently rereads and validates the result before exiting. It does not write
TOML itself, replace the whole config, emit raw protocol messages, print
unrelated settings, or start a model thread/provider request. Native key removal
can remove comments attached to the deleted keys, so comment preservation is not
promised; unrelated settings and Engram data remain intact.

## Credential-free verification fixture

The regression suite uses only temporary `HOME`, `CODEX_HOME`, workspace, and
XDG roots. Its contaminated config includes both known instruction-file keys,
enabled Engram plugin/MCP entries, and unrelated sentinel settings. It verifies:

- native `config/read` values, user origins, file identity, and version;
- byte-identical report and dry-run behavior;
- missing-path controls proving that both inherited instruction-file keys affect
  `codex -p parallel-work debug prompt-input`;
- native deletion, disabled default/profile MCP state, unrelated-setting
  preservation, AGENTS discovery, concurrency rejection, and idempotence;
- the MCP server's implicit enabled default when its exact user-layer command
  and arguments are present, plus rejection of missing or mixed provenance;
- fail-closed handling for custom targets, unsafe paths, malformed input or
  protocol, ambiguous origins, and production-home detection.

Run it with:

```sh
python3 -B -m unittest discover -s tests \
  -p 'test_codex_memory_policy.py' -v
zsh tests/parallel-work-profile.zsh
zsh tests/codex-config-stow.zsh
```

The fixture has no production credentials, never loads Engram hooks, never
creates a model thread, and never invokes a provider. `debug prompt-input` does
not expose reliable model/compaction markers even when those files loaded, so
marker absence is not deletion proof. Native `config/read` plus the independent
missing-path controls supply that proof.

## Activation remains separate

Repository changes alone do not fix active machine configuration. A separately
approved activation must reconcile the live config again, preserve concurrency
protection, and then verify the effective default and task-profile configuration
from a fresh session. Running sessions do not retroactively lose instructions or
hooks that were injected when they started.
