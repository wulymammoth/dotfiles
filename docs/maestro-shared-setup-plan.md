# Shared Maestro Setup Implementation Plan

**Goal:** Make a pinned, privacy-configured Maestro CLI and focused agent guidance
available across projects without installing a project test harness.

**Architecture:** A no-folding Stow package installs two small commands and a
release manifest. A Python 3.9+ standard-library helper downloads and verifies the
official ZIP, extracts it into a version-specific local data directory, and
executes its unmodified launcher. Project flows, app IDs, fixtures, and runtime
ownership remain repository-owned.

**Tech stack:** Python standard library, POSIX sh, GNU Stow, existing Make/zsh
checks, Maestro 2.10.0, Java 17+.

## Approval and constraints

- User approved shared setup and local activation, with a one-time task-branch
  exception in `/Users/wulymammoth/dotfiles`; branch `chore/maestro-shared-setup`.
- Base: `7904ec58b3584396b0d5af3952d66952b84dcf2f`. Parent session is the sole writer.
- No SoundCoaster changes, simulator launch/test, or hosted changes. The user
  separately approved the local milestone commit after verification.
- Preserve real mutable `~/.local`, `~/.codex`, and skill directories. Never adopt
  or overwrite conflicting local files. No global Java replacement.
- Pin ZIP SHA256 `29b675e10cc12080e445e9bfb2e2b4e4dfb9c0f2e30d5884120d258b5e1cd991`.
- Set analytics and notifications off. Upstream automatic error/update requests
  bypass some opt-outs; route the Maestro API to `http://127.0.0.1:9` for this
  local-only setup. This is not a network sandbox.
- Keep official release binaries and Maestro state outside Git. Retain previous
  versions; upgrades are explicit manifest edits followed by verification.
- Use inline implementation with independent read-only guidance/code review.

## Tasks and verification

### 1. Verified installer and launcher

Files: `maestro/.local/bin/{maestro,maestro-toolchain}`,
`maestro/.local/share/maestro-toolchain/pin.json`,
`tests/test_maestro_toolchain.py`.

Interface: `maestro-toolchain install [--archive FILE]`,
`maestro-toolchain run ARGS...`, and `maestro ARGS...`.
`install(pin, home, archive=None)` returns the installed launcher path; an
existing matching receipt is a no-op, while conflicting/incomplete installations
fail without replacement. `runtime_env(environ)` returns a copy with privacy
defaults and optional `MAESTRO_JAVA_HOME` mapped to the child-only `JAVA_HOME`.

- [x] Write tests for missing implementation, verified install and executable
  modes, checksum mismatch, path traversal/symlinks, idempotence, conflicts,
  missing installation, exact argv and exit-code forwarding, and child-only env.
- [x] Run `python3 -B -m unittest discover -s tests -p 'test_maestro_toolchain.py' -v`
  and record the expected missing-feature failure.
- [x] Implement the smallest helper: validate manifest, bounded HTTPS download,
  checksum-before-extraction, safe extraction into a temporary sibling, verify
  expected launcher/JAR layout, write receipt, atomic directory rename.
- [x] Repeat the tests; run `shellcheck maestro/.local/bin/maestro`.

### 2. Doctor and noninteractive discovery

Files: helper/tests above, `Makefile`, `zsh/.zshenv`,
`tests/maestro-integration.zsh`.

Interface: `maestro-toolchain doctor [--ios]`; default checks Java and exact
Maestro version, while `--ios` also reads Xcode/simulator inventory without
booting or selecting a device. Nonzero exit means prerequisites are incomplete;
success explicitly does not mean an app/driver test passed.

- [x] Add RED tests for unsupported/missing Java, wrong Maestro version,
  successful doctor, and read-only iOS inventory with missing runtime failure.
- [x] Add RED integration checks for no-folding package activation, preserving
  local sentinels, conflicts, PATH discovery in fresh noninteractive zsh, and
  Make targets that never implicitly install/start devices during doctor.
- [x] Implement doctor and `make maestro-install`, `maestro-doctor`,
  `maestro-activate`, `test-maestro`. Keep this package selectively activated.
- [x] Run both new suites plus the existing Codex Stow, ctx, and profile tests.

### 3. Focused shared guidance

Files: `codex-config/.codex/skills/maestro-mobile-testing/SKILL.md`,
`codex-config/.codex/AGENTS.md`, `docs/maestro.md`, `README.md`,
`.Codex-context.md`.

- [x] Read-only baseline: agent could not discover shared Maestro commands;
  existing skills already reject borrowed simulators and preserve XCUITest.
- [x] Add a concise discovery/command reference. Route only native UI work in
  Maestro-adopted or explicitly adopting Expo/RN projects, not all UI work.
- [x] Document stable IDs versus accessibility labels, native hierarchy proof,
  project-owned fixtures, semantic waits/outcome assertions, functional versus
  visual proof, runtime identity, and remaining physical/provider boundaries.
- [x] Ask a fresh read-only reviewer to apply the guide to the same scenarios.
  Require exact command retrieval and appropriate scope, not token matching.

### 4. Local activation and acceptance

- [x] Review the quiescent diff independently; repair important findings.
- [x] Verify the downloaded official ZIP against the checked-in digest; run the
  installer with `--archive` to avoid downloading the same asset again.
- [x] Preview and apply only `maestro` and `codex-config` with `--no-folding`.
- [x] Check `maestro --version`, `maestro --help`, `maestro-toolchain doctor --ios`,
  fresh noninteractive shell discovery, and idempotent reinstallation.
- [x] Preserve the exact commands/results in task notes, recording that no
  simulator driver or app flow has been tested.
- [x] Refresh `origin/main`, compare the base, rerun focused checks and
  `git diff --check`, and propose a commit for explicit approval.

## Sources

- [Official release](https://github.com/mobile-dev-inc/Maestro/releases/tag/cli-2.10.0)
- [Pinned CLI startup](https://github.com/mobile-dev-inc/Maestro/blob/14a408335e17a090df1e26bdbeaf80d8122a8fd8/maestro-cli/src/main/java/maestro/cli/App.kt)
- [Expo integration](https://docs.expo.dev/eas/workflows/examples/e2e-tests/)

## Progress

Baseline Stow/ctx/profile tests pass. The existing profile suite separately
reports `PENDING_CANARY`; this setup does not claim to resolve that provider check.

Implementation and local activation verified on 2026-09-05. Independent review
passed after RED/GREEN fixes for symlinked installation ancestors and hidden
startup warnings. All 21 unit tests, Stow/PATH integration, ShellCheck, Ruff, and
the affected existing suites pass. Checkmake's three `minphony` defaults also
fail at the unchanged base; no new Checkmake finding remains. The user approved
`feat(tooling): add pinned shared Maestro workflow` as a local milestone commit;
push and merge remain separate. Detailed handoff:
`notes/chore-maestro-shared-setup--2026-09-05.md`.
