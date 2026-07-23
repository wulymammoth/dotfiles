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

if [[ "$1 $2" == "trust --formula" && "${BINSTALL_TEST_TRUST_FAIL:-0}" == "1" ]]; then
  exit 41
fi

if [[ "$1 $2" == "bundle add" && "${BINSTALL_TEST_INSTALL_FAIL:-0}" == "1" ]]; then
  exit 42
fi

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

assert_path_contains() {
  local target_file="$1"
  local expected="$2"
  grep -Fq -- "$expected" "$target_file" \
    || fail "expected $target_file to contain: $expected"
}

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
  local result_status
  export BINSTALL_TEST_TRUST_FAIL=1
  if binstall gentleman-programming/tap/engram; then
    fail "trust failure should propagate"
  else
    result_status=$?
  fi
  assert_equal '41' "$result_status" "trust failure status"
  assert_equal 'trust --formula gentleman-programming/tap/engram' \
    "$(<"$BINSTALL_TEST_LOG")" "trust failure command boundary"

  reset_fixture
  export BINSTALL_TEST_INSTALL_FAIL=1
  if binstall gentleman-programming/tap/engram; then
    fail "install failure should propagate"
  else
    result_status=$?
  fi
  assert_equal '42' "$result_status" "install failure status"
  assert_equal \
    $'trust --formula gentleman-programming/tap/engram\nbundle add --global --install --formula gentleman-programming/tap/engram' \
    "$(<"$BINSTALL_TEST_LOG")" \
    "install failure command boundary"
}

test_usage_and_brewfile_errors() {
  reset_fixture
  local result_status
  local configured_brewfile="$HOMEBREW_BUNDLE_FILE_GLOBAL"
  local error_log="$test_root/error.log"

  if binstall 2>"$error_log"; then
    fail "empty invocation should fail"
  else
    result_status=$?
  fi
  assert_equal '2' "$result_status" "empty invocation status"
  assert_path_contains "$error_log" 'usage: binstall formula [...]'

  unset HOMEBREW_BUNDLE_FILE_GLOBAL
  if binstall gentleman-programming/tap/engram 2>"$error_log"; then
    fail "missing global Brewfile setting should fail"
  else
    result_status=$?
  fi
  export HOMEBREW_BUNDLE_FILE_GLOBAL="$configured_brewfile"
  assert_equal '1' "$result_status" "missing Brewfile setting status"
  assert_path_contains "$error_log" \
    'binstall: HOMEBREW_BUNDLE_FILE_GLOBAL must be set for third-party formulae'

  export HOMEBREW_BUNDLE_FILE_GLOBAL="$test_root/missing-Brewfile"
  if binstall gentleman-programming/tap/engram 2>"$error_log"; then
    fail "missing global Brewfile should fail"
  else
    result_status=$?
  fi
  export HOMEBREW_BUNDLE_FILE_GLOBAL="$configured_brewfile"
  assert_equal '1' "$result_status" "missing Brewfile status"
  assert_path_contains "$error_log" \
    "binstall: global Brewfile is missing or not writable: $test_root/missing-Brewfile"

  reset_fixture
  if _binstall_mark_formula_trusted \
    gentleman-programming/tap/engram "$HOMEBREW_BUNDLE_FILE_GLOBAL" \
    2>"$error_log"; then
    fail "missing formula declaration should fail"
  else
    result_status=$?
  fi
  assert_equal '1' "$result_status" "missing declaration status"
  assert_path_contains "$error_log" \
    "binstall: formula declaration not found in $HOMEBREW_BUNDLE_FILE_GLOBAL: gentleman-programming/tap/engram"
}

test_third_party_formula_trust
test_core_formula_skips_trust
test_mixed_formula_order
test_existing_options_and_idempotence
test_failures_propagate
test_usage_and_brewfile_errors

print -- "PASS: binstall trust-aware behavior"
