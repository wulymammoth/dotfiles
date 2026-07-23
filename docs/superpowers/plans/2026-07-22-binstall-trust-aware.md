# Trust-aware `binstall` Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `binstall` automatically grant and persist formula-scoped trust for explicitly requested third-party Homebrew formulae without trusting their entire taps.

**Architecture:** Keep `binstall` as the public shell interface and add one private helper that idempotently annotates the exact global Brewfile declaration with `trusted: true`. Classify only `owner/tap/formula` arguments as third-party, grant formula-scoped trust before the existing targeted Bundle install, and cover the behavior with a dependency-free Zsh test that stubs Homebrew and never installs software.

**Tech Stack:** Zsh, Homebrew 6 trust and Bundle commands, Perl for an in-place one-line Brewfile DSL edit, Git.

## Global Constraints

- Preserve the existing one-command install-and-record workflow.
- Trust only third-party formulae explicitly passed to `binstall`.
- Never trust an entire third-party tap implicitly.
- Record formula-scoped trust as `trusted: true` in the global Brewfile.
- Preserve existing behavior for official or short-name formulae.
- Do not change `bcask` in this slice.
- Do not run a real package install from the automated tests.
- Use test-driven development: observe the regression test fail before modifying `zsh/.functions`.
- Preserve unrelated user changes in `zsh/.exports` and `zsh/.zshenv`.
- Obtain explicit user approval before each commit.

---

## File structure

- Create `tests/binstall.zsh`: self-contained Zsh regression harness with a stub `brew` command and temporary Brewfile.
- Modify `zsh/.functions`: add `_binstall_mark_formula_trusted` and make `binstall` classify, trust, install, and persist third-party formula trust.
- Update `~/Desktop/notes/main--2026-07-22.md`: record the completed behavior, verification commands, and continuation state; do not commit this machine-local note.
- Read only `homebrew/Brewfile`: verify the existing Engram declaration remains trusted; do not rewrite it during tests.

### Task 1: Add the trust-aware behavior with a red-green-refactor cycle

**Files:**
- Create: `tests/binstall.zsh`
- Modify: `zsh/.functions:18-27`
- Read: `homebrew/Brewfile:66-67`

**Interfaces:**
- Consumes: `HOMEBREW_BUNDLE_FILE_GLOBAL`, positional formula names, and the `brew` executable on `PATH`.
- Produces: `binstall formula... -> status`, `_binstall_mark_formula_trusted formula brewfile -> status`, formula-scoped Homebrew trust, and an idempotent `trusted: true` Brewfile option.

- [ ] **Step 1: Write the first failing regression test**

Create `tests/binstall.zsh` with a stub Homebrew executable and one third-party formula assertion:

```zsh
#!/usr/bin/env zsh

emulate -LR zsh
setopt errexit nounset pipefail

repo_root="${0:A:h:h}"
test_root="$(mktemp -d /tmp/binstall-test.XXXXXX)"
trap 'rm -rf "$test_root"' EXIT

export HOMEBREW_BUNDLE_FILE_GLOBAL="$test_root/Brewfile"
export BINSTALL_TEST_LOG="$test_root/brew.log"
mkdir -p "$test_root/bin"

cat >"$test_root/bin/brew" <<'STUB'
#!/usr/bin/env zsh
emulate -L zsh

print -r -- "$*" >>"$BINSTALL_TEST_LOG"

if [[ "$1 $2" == "bundle add" ]]; then
  shift 2
  local collecting=0
  local formula
  for formula in "$@"; do
    if [[ "$formula" == "--formula" ]]; then
      collecting=1
      continue
    fi
    (( collecting )) || continue
    if ! grep -Fq "\"$formula\"" "$HOMEBREW_BUNDLE_FILE_GLOBAL" 2>/dev/null \
      && ! grep -Fq "'$formula'" "$HOMEBREW_BUNDLE_FILE_GLOBAL" 2>/dev/null; then
      print -r -- "brew \"$formula\"" >>"$HOMEBREW_BUNDLE_FILE_GLOBAL"
    fi
  done
fi
STUB
chmod +x "$test_root/bin/brew"
export PATH="$test_root/bin:$PATH"

source "$repo_root/zsh/.functions"

fail() {
  print -u2 -- "FAIL: $*"
  exit 1
}

: >"$HOMEBREW_BUNDLE_FILE_GLOBAL"
: >"$BINSTALL_TEST_LOG"

binstall gentleman-programming/tap/engram

expected_log=$'trust --formula gentleman-programming/tap/engram\nbundle add --global --install --formula gentleman-programming/tap/engram'
actual_log="$(<"$BINSTALL_TEST_LOG")"
[[ "$actual_log" == "$expected_log" ]] \
  || fail "expected formula-scoped trust before bundle install; got: $actual_log"

grep -Fq 'brew "gentleman-programming/tap/engram", trusted: true' \
  "$HOMEBREW_BUNDLE_FILE_GLOBAL" \
  || fail "expected trusted formula declaration"

print -- "PASS: third-party formula trust"
```

- [ ] **Step 2: Run the regression test and verify RED**

Run:

```sh
zsh tests/binstall.zsh
```

Expected: exit `1` with `FAIL: expected formula-scoped trust before bundle install`; the current function logs only the `bundle add` command.

- [ ] **Step 3: Implement the smallest trust-aware production change**

Replace the current `binstall` definition in `zsh/.functions` and add the private helper immediately above it:

```zsh
_binstall_mark_formula_trusted() {
  emulate -L zsh

  local formula="$1"
  local brewfile="$2"
  local status

  BINSTALL_TRUST_FORMULA="$formula" perl -i -pe '
    BEGIN { $found = 0 }
    my $formula = $ENV{"BINSTALL_TRUST_FORMULA"};
    if (/^(\s*brew\s+)(["\x27])\Q$formula\E\2(.*?)(\s+#.*)?(\r?\n)?$/) {
      $found = 1;
      unless ($3 =~ /\btrusted\s*:/) {
        my ($prefix, $quote, $options, $comment, $newline) =
          ($1, $2, $3, $4 // "", $5 // "");
        $options =~ s/\s+$//;
        $_ = "$prefix$quote$formula$quote$options, trusted: true$comment$newline";
      }
    }
    END { exit 3 unless $found }
  ' "$brewfile"
  status=$?

  if (( status == 3 )); then
    print -u2 -- "binstall: formula declaration not found in $brewfile: $formula"
    return 1
  fi
  if (( status != 0 )); then
    print -u2 -- "binstall: failed to update trust metadata in $brewfile"
    return "$status"
  fi
}

# Install Homebrew packages and record them in the dotfiles Brewfile.
binstall() {
  emulate -L zsh

  if (( $# == 0 )); then
    print -u2 -- "usage: binstall formula [...]"
    return 2
  fi

  local formula
  local brewfile="${HOMEBREW_BUNDLE_FILE_GLOBAL:-}"
  local -a third_party_formulae

  for formula in "$@"; do
    [[ "$formula" == */*/* ]] && third_party_formulae+=("$formula")
  done

  if (( ${#third_party_formulae[@]} > 0 )); then
    if [[ -z "$brewfile" ]]; then
      print -u2 -- "binstall: HOMEBREW_BUNDLE_FILE_GLOBAL must be set for third-party formulae"
      return 1
    fi
    if [[ ! -f "$brewfile" || ! -w "$brewfile" ]]; then
      print -u2 -- "binstall: global Brewfile is missing or not writable: $brewfile"
      return 1
    fi
    brew trust --formula "${third_party_formulae[@]}" || return
  fi

  brew bundle add --global --install --formula "$@" || return

  for formula in "${third_party_formulae[@]}"; do
    _binstall_mark_formula_trusted "$formula" "$brewfile" || return
  done
}
```

- [ ] **Step 4: Run the focused test and verify GREEN**

Run:

```sh
zsh tests/binstall.zsh
```

Expected: exit `0` with `PASS: third-party formula trust`.

- [ ] **Step 5: Expand the test suite for core, mixed, idempotent, option-preserving, and failure behavior**

Extend the stub before its `bundle add` branch:

```zsh
if [[ "$1 $2" == "trust --formula" && "${BINSTALL_TEST_TRUST_FAIL:-0}" == "1" ]]; then
  exit 41
fi

if [[ "$1 $2" == "bundle add" && "${BINSTALL_TEST_INSTALL_FAIL:-0}" == "1" ]]; then
  exit 42
fi
```

Add these helpers after `fail`:

```zsh
reset_fixture() {
  : >"$HOMEBREW_BUNDLE_FILE_GLOBAL"
  : >"$BINSTALL_TEST_LOG"
  unset BINSTALL_TEST_TRUST_FAIL BINSTALL_TEST_INSTALL_FAIL
}

assert_equal() {
  local expected="$1"
  local actual="$2"
  local message="$3"
  [[ "$actual" == "$expected" ]] || fail "$message; expected '$expected', got '$actual'"
}

assert_file_contains() {
  local expected="$1"
  grep -Fq -- "$expected" "$HOMEBREW_BUNDLE_FILE_GLOBAL" \
    || fail "expected Brewfile to contain: $expected"
}
```

Replace the single inline case with named test functions and invocations:

```zsh
test_third_party_formula_trust() {
  reset_fixture
  binstall gentleman-programming/tap/engram

  assert_equal \
    $'trust --formula gentleman-programming/tap/engram\nbundle add --global --install --formula gentleman-programming/tap/engram' \
    "$(<"$BINSTALL_TEST_LOG")" \
    "third-party command order"
  assert_file_contains 'brew "gentleman-programming/tap/engram", trusted: true'
}

test_core_formula_skips_trust() {
  reset_fixture
  binstall ripgrep

  assert_equal \
    'bundle add --global --install --formula ripgrep' \
    "$(<"$BINSTALL_TEST_LOG")" \
    "core formula command"
  assert_file_contains 'brew "ripgrep"'
  ! grep -Fq 'trusted: true' "$HOMEBREW_BUNDLE_FILE_GLOBAL" \
    || fail "core formula should not receive trust metadata"
}

test_mixed_formula_order() {
  reset_fixture
  binstall ripgrep gentleman-programming/tap/engram

  assert_equal \
    $'trust --formula gentleman-programming/tap/engram\nbundle add --global --install --formula ripgrep gentleman-programming/tap/engram' \
    "$(<"$BINSTALL_TEST_LOG")" \
    "mixed formula command order"
}

test_existing_options_and_idempotence() {
  reset_fixture
  print -r -- "brew 'gentleman-programming/tap/engram', link: false # keep" \
    >"$HOMEBREW_BUNDLE_FILE_GLOBAL"

  binstall gentleman-programming/tap/engram
  binstall gentleman-programming/tap/engram

  assert_file_contains \
    "brew 'gentleman-programming/tap/engram', link: false, trusted: true # keep"
  assert_equal \
    '1' \
    "$(grep -o 'trusted: true' "$HOMEBREW_BUNDLE_FILE_GLOBAL" | wc -l | tr -d ' ')" \
    "trusted option count"
}

test_failures_propagate() {
  reset_fixture
  export BINSTALL_TEST_TRUST_FAIL=1
  binstall gentleman-programming/tap/engram && fail "trust failure should propagate"
  assert_equal 'trust --formula gentleman-programming/tap/engram' \
    "$(<"$BINSTALL_TEST_LOG")" "trust failure command boundary"

  reset_fixture
  export BINSTALL_TEST_INSTALL_FAIL=1
  binstall gentleman-programming/tap/engram && fail "install failure should propagate"
  assert_equal \
    $'trust --formula gentleman-programming/tap/engram\nbundle add --global --install --formula gentleman-programming/tap/engram' \
    "$(<"$BINSTALL_TEST_LOG")" \
    "install failure command boundary"
}

test_usage_and_brewfile_errors() {
  reset_fixture
  local status
  local configured_brewfile="$HOMEBREW_BUNDLE_FILE_GLOBAL"

  if binstall; then
    fail "empty invocation should fail"
  else
    status=$?
  fi
  assert_equal '2' "$status" "empty invocation status"

  unset HOMEBREW_BUNDLE_FILE_GLOBAL
  if binstall gentleman-programming/tap/engram; then
    fail "missing global Brewfile setting should fail"
  else
    status=$?
  fi
  export HOMEBREW_BUNDLE_FILE_GLOBAL="$configured_brewfile"
  assert_equal '1' "$status" "missing Brewfile setting status"

  export HOMEBREW_BUNDLE_FILE_GLOBAL="$test_root/missing-Brewfile"
  if binstall gentleman-programming/tap/engram; then
    fail "missing global Brewfile should fail"
  else
    status=$?
  fi
  export HOMEBREW_BUNDLE_FILE_GLOBAL="$configured_brewfile"
  assert_equal '1' "$status" "missing Brewfile status"

  reset_fixture
  if _binstall_mark_formula_trusted \
    gentleman-programming/tap/engram "$HOMEBREW_BUNDLE_FILE_GLOBAL"; then
    fail "missing formula declaration should fail"
  else
    status=$?
  fi
  assert_equal '1' "$status" "missing declaration status"
}

test_third_party_formula_trust
test_core_formula_skips_trust
test_mixed_formula_order
test_existing_options_and_idempotence
test_failures_propagate
test_usage_and_brewfile_errors

print -- "PASS: binstall trust-aware behavior"
```

- [ ] **Step 6: Run the expanded suite and refactor only if it remains green**

Run:

```sh
zsh tests/binstall.zsh
```

Expected: exit `0` with `PASS: binstall trust-aware behavior` and no warnings.

- [ ] **Step 7: Run shell verification**

Run:

```sh
command -v perl
zsh -n zsh/.functions tests/binstall.zsh
git diff --check
```

Expected: all commands exit `0`; `command -v perl` resolves an executable. ShellCheck is not run because it does not support Zsh syntax; `zsh -n` and the behavioral regression suite are authoritative.

- [ ] **Step 8: Verify the real Brewfile and working-tree boundary**

Run:

```sh
rg -n -F "brew 'gentleman-programming/tap/engram', trusted: true" homebrew/Brewfile
git status --short
git diff -- zsh/.functions tests/binstall.zsh
```

Expected: the Engram declaration remains trusted; the implementation diff contains only `zsh/.functions` and `tests/binstall.zsh`; the pre-existing `zsh/.exports` and `zsh/.zshenv` changes remain untouched.

### Task 2: Record completion and commit the verified implementation

**Files:**
- Update: `~/Desktop/notes/main--2026-07-22.md` (machine-local, not committed)
- Commit: `zsh/.functions`, `tests/binstall.zsh`

**Interfaces:**
- Consumes: verified Task 1 implementation and test output.
- Produces: continuation note and one atomic implementation commit.

- [ ] **Step 1: Update the branch progress note**

Append a concise entry to `~/Desktop/notes/main--2026-07-22.md` containing:

```markdown
## Trust-aware binstall

- `binstall` grants only formula-scoped trust for `owner/tap/formula` arguments.
- The global Brewfile persists those decisions with `trusted: true`.
- Core formula behavior is unchanged; whole taps are never trusted implicitly.
- Verification: `zsh tests/binstall.zsh`, `zsh -n zsh/.functions tests/binstall.zsh`, and `git diff --check` pass.
```

- [ ] **Step 2: Present the implementation commit for approval**

Proposed commit message:

```text
feat(zsh): make binstall formula-trust aware
```

Show `git diff --stat`, the verification results, and the exact files to be committed. Wait for explicit user confirmation before staging or committing.

- [ ] **Step 3: Commit only the implementation files after approval**

Run:

```sh
git add zsh/.functions tests/binstall.zsh
git diff --cached --check
git commit -m "feat(zsh): make binstall formula-trust aware"
```

Expected: one commit containing only the function and its regression test. Confirm `zsh/.exports` and `zsh/.zshenv` remain outside the commit.

- [ ] **Step 4: Verify the committed end state**

Run:

```sh
git show --stat --oneline HEAD
git status --short
zsh tests/binstall.zsh
```

Expected: the implementation commit lists only `zsh/.functions` and `tests/binstall.zsh`; the regression suite still passes; unrelated user changes remain present and uncommitted.
