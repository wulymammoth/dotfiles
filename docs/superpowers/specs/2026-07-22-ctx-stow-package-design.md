# ctx Stow package design

Date: 2026-07-22
Status: Approved, pending implementation

## Problem

ctx stores both durable preferences and sensitive mutable state in `~/.ctx`.
The current data root contains a small `config.toml` alongside a roughly 1.2 GB
SQLite index, lock files, object storage, and spool storage. Treating the whole
directory as a conventional folded Stow tree would cause ctx runtime writes to
land inside the dotfiles worktree.

## Decision

Manage only `~/.ctx/config.toml` as dotfiles. Keep every database, lock, cache,
runtime, log, object, and spool artifact in the real local `~/.ctx` directory.

The repository package will be:

```text
ctx/
  .ctx/
    config.toml
```

The resulting home layout will be:

```text
~/.ctx/                         # real local directory
  config.toml -> ~/dotfiles/ctx/.ctx/config.toml
  work.sqlite                  # private local state
  objects/                     # private local state
  spool/                       # private local state
  ...                          # future ctx-managed state
```

## Stow behavior

GNU Stow normally folds a package subtree into one directory symlink when the
target directory is absent. The ctx package must therefore be invoked in a
separate command with `--no-folding`. The Makefile will keep ordinary packages
on their existing command and maintain a separate stateful package list for
ctx. Preview, apply, and list targets will cover both groups.

The initial migration will first verify that the repository and home copies of
`config.toml` are identical, then use Stow's adoption flow with
`--no-folding`. No database or other mutable state will move.

## Alternatives rejected

- Moving all of `~/.ctx` into the package and ignoring runtime files would
  physically place private history and high-churn state inside the worktree.
- Copying configuration during bootstrap would avoid runtime-state leakage but
  would not provide a Stow-managed source of truth.
- Changing `CTX_DATA_ROOT` cannot separate config from state because ctx stores
  both beneath the same configured root.
- Applying `--no-folding` to every package would change the repository's
  established linking behavior beyond this task's scope.

## Configuration ownership

ctx commands that intentionally change durable preferences may rewrite the
symlinked `config.toml` and create a dotfiles diff. That is expected: preference
changes should be reviewable. Commands that index, search, upgrade, or maintain
runtime state must continue writing outside the repository.

The installation also added both supported process-level upgrade opt-out
variables to `zsh/.zshenv` and `zsh/.exports`. Preserve that defense-in-depth
policy without duplication: keep the canonical `CTX_UPGRADE_OFF=1` export in
`.zshenv`, which is loaded by interactive and non-interactive Zsh processes,
and remove the interactive-only duplicate block from `.exports`. The tracked
`upgrade.auto = "off"` setting remains the cross-shell durable policy.

The installer-managed binary and sidecar remain local at `~/.local/bin/ctx`
and `~/.local/bin/ctx.install.json`; they are not Stow package contents.

ctx also installs a version-coupled agent-history skill for supported agents.
The OpenCode skills directory is already linked into this repository, so that
generated copy physically lands under the `opencode` package while identical
Codex, Claude, and universal copies remain outside Git. Keep all copies under
ctx installer ownership and ignore only
`opencode/.config/opencode/skills/ctx-agent-history-search/`; do not commit the
generated skill or its install metadata.

The existing `~/.zshenv` link predates ctx but is absolute, unlike the other
repo-managed Zsh links. Normalize it to the equivalent relative target so GNU
Stow recognizes it as owned and the repository-wide preview returns to a clean
baseline. This changes link representation only, not the source file or its
resolved destination.

## Testing and verification

A dependency-free Zsh regression test will create a temporary home-like target
with a sentinel SQLite file, invoke the real ctx Stow package with
`--no-folding`, and assert that:

1. `.ctx` remains a real directory.
2. `.ctx/config.toml` is a symlink to the repository package.
3. The sentinel database remains unchanged and is not linked into the repo.
4. No known ctx mutable-state paths exist inside the package.
5. The process-level upgrade guard is defined exactly once, in `.zshenv`.
6. The live OpenCode ctx skill remains current while its generated files are
   ignored by Git.

Implementation will follow red-green-refactor: the test must fail before the
package and Makefile changes exist, then pass afterward. Final verification
will also run Stow preview, `git diff --check`, and `ctx status --json` against
the real home data root.

## Documentation and change boundaries

Update the README package map and usage notes to explain the config/state
boundary and file-level Stow behavior. Include the ctx-related changes in
`zsh/.exports` and `zsh/.zshenv`, while preserving the unrelated modification
to the binstall design document. Record the completed migration in the branch's
dated local progress note before proposing an atomic commit.
