# Shared Maestro setup — verified local checkpoint

## Scope and state

- Startup root: `/Users/wulymammoth/dotfiles`.
- Branch: `chore/maestro-shared-setup`; base
  `7904ec58b3584396b0d5af3952d66952b84dcf2f`.
- User approved shared setup/activation and a one-time in-place task-branch
  exception, then separately approved the local milestone commit
  `feat(tooling): add pinned shared Maestro workflow`. Resolve its applied SHA
  from live Git history rather than treating this checkpoint note as Git state.
- No SoundCoaster edits, issue changes, cloud/CI activation, device/app tests,
  releases, push, merge, or cleanup are included in the approval.

## What works

- Official Maestro 2.10.0 ZIP verified against published SHA256
  `29b675e10cc12080e445e9bfb2e2b4e4dfb9c0f2e30d5884120d258b5e1cd991`.
- Release installed in `~/.local/share/maestro-cli/2.10.0/`; shared commands and
  `maestro-mobile-testing` skill activated as no-folding Stow leaf links.
- `~/.local`, its bin/share directories, and `~/.codex/skills` remain real dirs.
- Normal and clean noninteractive zsh discover `~/.local/bin/maestro` and
  `maestro-toolchain`. No Codex flags or extra MCP server are needed.
- Child-only analytics/notification/update settings plus loopback Maestro API
  destination; see `docs/maestro.md` for the limited privacy boundary.
- Existing Maestro analytics/notification/session/promotion state hashes were
  unchanged by verification. Upstream may maintain its own dependency caches.

## Verification

| Command/check | Result |
| --- | --- |
| `make test-maestro` | PASS: 21 offline Python tests, no-folding/conflict/PATH integration, ShellCheck |
| `zsh tests/codex-config-stow.zsh` | PASS |
| `zsh tests/ctx-integration.zsh` | PASS |
| `zsh tests/parallel-work-profile.zsh` | PASS; its existing provider `PENDING_CANARY` remains |
| `ruff check --no-cache maestro/.local/bin/maestro-toolchain tests/test_maestro_toolchain.py` | PASS |
| `maestro --version` / `maestro --help` | PASS, version 2.10.0; upstream JVM warning retained |
| `maestro-toolchain doctor --ios` | PASS: Temurin 26.0.2.1, Xcode 26.6, available iOS 26.4/26.5 inventory |
| `env -i HOME="$HOME" PATH=/usr/bin:/bin /bin/zsh -c 'command -v maestro; command -v maestro-toolchain; maestro --version'` | PASS |
| `make maestro-install` after first install | PASS, idempotent, no download/replacement |
| `git fetch --no-tags origin main` | Refreshed; HEAD/main/origin/main remain the base SHA above |
| `git diff --check` | PASS |

`checkmake Makefile` reports the existing missing `all`, `clean`, and `test`
phony-target defaults. The same three findings reproduce from `git show
HEAD:Makefile`; the new help-length finding was fixed without expanding scope.

Raw local proof is under `/tmp/maestro-shared-setup/` (ephemeral, not committed):
unit/integration RED/GREEN logs, review-fix RED/GREEN, activated version/help and
doctor logs, fresh-shell/idempotence logs, checksum and legacy-state records.

## Independent review

- Baseline guide scenario: shared command discovery missing; existing skills
  correctly rejected borrowed simulators and retained Swift/XCUITest.
- New guide: all three scenarios GREEN with exact shared command retrieval.
- Important finding: symlinked `.local` or `.local/share` could receive binaries
  through an older folded Stow parent. Both cases failed before the fix and now
  fail closed with the linked destination untouched.
- Minor finding: successful CLI diagnostics were hidden. Doctor now prints WARN
  without changing the JDK or successful version-check result.
- Reviewer PASS targets the fixed quiescent implementation checkpoint: tracked
  diff SHA256 `3e53e53720a6cc4f53c38504c87b77438daa87f100c1f6c40ba3cf24260731a7`.
  Only plan-status and this handoff note were added after that reviewed checkpoint.

## Remaining boundaries and continuation

Java 26 emits upstream Picocli final-field-reflection warnings. CLI startup
works; native-driver/app compatibility is **not tested**. No simulator was
selected, booted, shut down, or used for a flow. Its pre-existing booted device
was left alone. A prerequisite pass is not SoundCoaster regression coverage.

1. Reconcile live HEAD and dirty state against the approved milestone message:
   `feat(tooling): add pinned shared Maestro workflow`.
2. Keep integration/push/merge separate. Live Stow links follow the current
   checkout, so changing/removing these sources changes active local tooling.
3. For SoundCoaster, start an owner session in its canonical task worktree and
   reconcile LEA-196 for project-owned functional flows/fixtures/stable IDs.
4. Treat LEA-211 visual comparisons and hosted native CI as distinct scopes.
