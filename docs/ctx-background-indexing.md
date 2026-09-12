# Background ctx indexing on macOS

This machine uses the official signed ctx 1.4.1 binary with one user-owned
LaunchAgent, `local.ctx-history`. Launchd runs the full maintenance daemon
independently of Codex and gives it a 4,096-file soft limit. There is no
watchdog, scheduled importer, custom binary, or global resource-limit change.

Ctx's own `[indexing] mode = "manual"` prevents its managed service installer
from replacing the service. The explicit `ctx daemon run --force` command
continues the normal watcher and maintenance loop in that mode. Both initial
startup and configuration reload honor `--force` in the 1.4.1 daemon source.
Thus `enabled: false` / `mode: manual` in ctx status describes its managed
autostart policy; inspect the live process and publication evidence below.

## Why this is needed

The stock macOS service inherits a 256-file limit. Cold recovery opens the
large index before ctx's writer raises that limit, causing `Too many open
files`. Editing the stock plist is ineffective: ctx verifies its exact
maintained definition and replaces customizations. A one-time launch override
also failed to survive a fresh MCP connection. Separating supervision from
ctx's installer permits a stable per-service limit using standard launchd.

The upstream FSEvents shutdown race in issue #957 / PR #964 is a separate
known limitation awaiting a release after 1.4.1. This configuration does not
patch that binary defect. Routine service restarts use launchd, and the
acceptance record must show new publications, not merely a live PID.

## Installed configuration

The plist is a private regular file at
`~/Library/LaunchAgents/local.ctx-history.plist`. It is not Stow-managed.
Its defining settings are:

- Program: `~/.local/bin/ctx --data-root ~/.ctx daemon run --force --format=json`,
  with absolute paths in the actual `ProgramArguments` array.
- `RunAtLoad = true`, `KeepAlive = true`, `ThrottleInterval = 30`,
  `ExitTimeOut = 15`, `ProcessType = Background`.
- `SoftResourceLimits.NumberOfFiles = 4096`; no hard-limit override.
- Explicit `HOME`, `XDG_CONFIG_HOME`, `LANG`, `LC_ALL`, and a minimal `PATH`.
  `CTX_SEARCH_SEMANTIC=false` and `CTX_UPGRADE_AUTO=off` remain explicit.
- Standard output goes to `/dev/null`; standard error goes to the private
  `~/.local/state/ctx-daemon/stderr.log` for startup failures.

The initial configuration and recovery receipts are retained privately under
`~/.local/state/ctx-recovery/20260912-003102/`. Raw provider histories and the
managed binary/installation receipts remain in place.

## Status, restart, and stop

```sh
launchctl print "gui/$(id -u)/local.ctx-history"
ctx status
```

The launchd PID must match `~/.ctx/daemon/status.json` and the active daemon
owner. Check an advancing heartbeat or active refresh progress, watcher
status in `daemon/wakeup.json`, and recent published content. The stock
`rs.ctx.daemon` service must remain absent.
The default safety reconciliation interval is 15–20 minutes; an idle heartbeat
does not update every few seconds. New source activity should wake the watcher.

For a normal restart:

```sh
launchctl kickstart -k "gui/$(id -u)/local.ctx-history"
```

To stop it persistently in the current login domain, unload the agent:

```sh
launchctl bootout "gui/$(id -u)/local.ctx-history"
```

Sending a signal or running `ctx index mode manual` alone does not persistently
stop the externally supervised `--force` process: `KeepAlive` restarts it.
To start it again after unloading:

```sh
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/local.ctx-history.plist"
```

## Signed updates

1. Unload `local.ctx-history` and verify its process has exited. Allow launchd
   to complete its bounded shutdown before proceeding.
2. Use the normal signed workflow: `ctx upgrade check`,
   `ctx upgrade --dry-run`, review the target, then `ctx upgrade`.
3. Preserve manual mode and bootstrap the user-owned agent again.
4. Verify PID ownership and automatic publication of new content.

Do not enable ctx-managed automatic mode while the custom agent is loaded.
When a released ctx version fixes cold-start file limits and maintained-service
behavior, unload and archive the custom plist before switching back to
`ctx index mode auto`. Re-run all acceptance checks before retiring this setup.

## Acceptance checks

Configuration lint alone is insufficient. The September 12 recovery uses
native Codex app-server sessions and the actual shared history index:

1. Open and close a fresh Codex MCP connection. Confirm the same launchd-owned
   daemon remains alive and continues work after that client exits.
2. Create a clearly labeled diagnostic session through Codex's native API,
   with no model call, and close its client. Search its unique marker with
   `--refresh off`; require the result's provider session ID to match that new
   session. A copy of the marker in this investigation's transcript is not proof.
3. Gracefully terminate the daemon and let launchd restart it without a ctx
   client. Require a new launchd-owned PID. Create another session after that
   restart and repeat the refresh-off search and native MCP retrieval.

Evidence and exact session/event identities are recorded in
`notes/main--2026-09-12.md` and the private recovery checkpoint. The two
diagnostic sessions are intentionally labeled fixtures and retained as test
evidence. No canonical transcript files are hand-edited.
