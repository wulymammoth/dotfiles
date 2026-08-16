#!/usr/bin/env zsh

emulate -LR zsh
setopt errexit nounset pipefail
unsetopt bg_nice

repo_root="${0:A:h:h}"
session_bin="$repo_root/codex-config/.codex/skills/orchestrating-parallel-worktrees/scripts/worktree-session"
test_root="$(mktemp -d "${TMPDIR:-/tmp}/parallel-session-test.XXXXXX")"
trap 'rm -rf "$test_root"' EXIT

fail() {
  print -u2 -- "FAIL: $*"
  exit 1
}

assert_contains() {
  local haystack="$1" needle="$2"
  [[ "$haystack" == *"$needle"* ]] \
    || fail "missing '$needle' in: $haystack"
}

assert_equals() {
  local actual="$1" expected="$2" label="$3"
  [[ "$actual" == "$expected" ]] \
    || fail "$label: expected '$expected', got '$actual'"
}

assert_config_missing() {
  local file="$1" key="$2" label="$3"
  if git config --file "$file" --get "$key" >/dev/null 2>&1; then
    fail "$label must be omitted"
  fi
}

assert_fails() {
  local expected="$1"
  shift
  local output exit_status
  set +e
  output="$("$@" 2>&1)"
  exit_status=$?
  set -e
  (( exit_status != 0 )) \
    || fail "command unexpectedly succeeded while expecting '$expected': $*"
  assert_contains "$output" "$expected"
}

make_fixture() {
  local name="$1"
  fixture_root="$test_root/$name"
  repo="$fixture_root/repo"
  worktree="$fixture_root/worktree with spaces"
  plan_rel="docs/superpowers/plans/approved-plan.md"

  mkdir -p "$repo"
  git -C "$repo" init -q -b main
  git -C "$repo" config user.name "Parallel Test"
  git -C "$repo" config user.email "parallel@example.invalid"
  print -r -- "base" >"$repo/README.md"
  mkdir -p "$repo/${plan_rel:h}"
  print -r -- "# Approved plan for $name" >"$repo/$plan_rel"
  git -C "$repo" add README.md "$plan_rel"
  git -C "$repo" commit -qm "base"
  base_sha="$(git -C "$repo" rev-parse HEAD)"
  git -C "$repo" worktree add -q -b "feat/$name" "$worktree" main
}

prepare_fixture() {
  CODEX_THREAD_ID="coordinator-thread" "$session_bin" prepare \
    --worktree "$worktree" \
    --task-id "TASK-1" \
    --task-slug "task-one" \
    --plan "$plan_rel" \
    --base-ref main \
    --base-sha "$base_sha" \
    --target-branch main \
    --integration-owner "sample integrator"
}

prepare_legacy_fixture() {
  prepare_fixture >/dev/null
  local conf="$worktree/.superpowers/parallel/session.conf"
  git config --file "$conf" session.schemaVersion 1
  git config --file "$conf" memory.sharedProject sample
  git config --file "$conf" memory.taskProject sample-task-task-1
}

prepare_with() {
  CODEX_THREAD_ID="coordinator-thread" "$session_bin" prepare "$@"
}

run_worker() {
  local thread_id="$1"
  shift
  (cd "$worktree" && \
    env -u ENGRAM_PROJECT -u ENGRAM_DATA_DIR \
      CODEX_THREAD_ID="$thread_id" "$@")
}

make_codex_stub() {
  stub_bin="$fixture_root/bin"
  mkdir -p "$stub_bin"
  cat >"$stub_bin/codex" <<'STUB'
#!/usr/bin/env zsh
print -r -- "${ENGRAM_PROJECT-unset}" >"$CODEX_STUB_ENV"
print -r -- "${ENGRAM_DATA_DIR-unset}" >"$CODEX_STUB_DATA_DIR"
printf '%s\n' "$@" >"$CODEX_STUB_ARGS"
STUB
  chmod +x "$stub_bin/codex"
  stub_env="$fixture_root/codex.env"
  stub_data_dir="$fixture_root/codex.data-dir"
  stub_args="$fixture_root/codex.args"
}

run_codex_boundary() {
  env -u ENGRAM_PROJECT -u ENGRAM_DATA_DIR PATH="$stub_bin:$PATH" \
    CODEX_STUB_ENV="$stub_env" CODEX_STUB_DATA_DIR="$stub_data_dir" \
    CODEX_STUB_ARGS="$stub_args" \
    "$session_bin" "$@"
}

claim_fixture() {
  prepare_fixture >/dev/null
  run_worker worker-a "$session_bin" claim >/dev/null
}

make_task_commit() {
  local message="${1:-task change}"
  print -r -- "$message" >"$worktree/task-change.txt"
  git -C "$worktree" add task-change.txt
  git -C "$worktree" commit -qm "$message"
}

run_ready_report() {
  local state="$1"
  shift
  run_worker worker-a "$session_bin" report \
    --state "$state" --freshness-source local \
    --verification "zsh tests/parallel-worktree-session.zsh" \
    --evidence "deterministic-local" \
    --next-action "request integrator review" "$@"
}

run_report_check() {
  (cd "$worktree" && env -u CODEX_THREAD_ID -u ENGRAM_PROJECT \
    -u ENGRAM_DATA_DIR \
    "$session_bin" report --check)
}

test_prepare_writes_exact_descriptor() {
  make_fixture descriptor
  local output
  output="$(prepare_fixture)"
  assert_equals "$output" \
    "PREPARED task=TASK-1 root=${worktree:A} branch=feat/descriptor" \
    "prepare stdout"

  local metadata="$worktree/.superpowers/parallel"
  local conf="$metadata/session.conf"
  assert_equals "$(<"$metadata/.gitignore")" "*" \
    "parallel metadata ignore content"
  assert_equals "$(wc -c <"$metadata/.gitignore" | tr -d ' ')" "2" \
    "parallel metadata ignore byte count"
  assert_equals "$(git config --file "$conf" --get session.schemaversion)" "2" \
    "schema version"
  assert_equals "$(git config --file "$conf" --get session.role)" \
    "implementation-controller" "session role"
  assert_equals "$(git config --file "$conf" --get session.preparedbythread)" \
    "coordinator-thread" "preparing thread"
  local prepared_at="$(git config --file "$conf" --get session.preparedat)"
  [[ "$prepared_at" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]] \
    || fail "preparedAt must be UTC RFC3339"
  assert_equals "$(git config --file "$conf" --get task.id)" "TASK-1" "task id"
  assert_equals "$(git config --file "$conf" --get task.slug)" "task-one" "task slug"
  assert_equals "$(git config --file "$conf" --get task.planpath)" "$plan_rel" \
    "plan path"
  assert_equals "$(git config --file "$conf" --get task.plansha256)" \
    "$(shasum -a 256 -- "$worktree/$plan_rel" | awk '{print $1}')" \
    "plan digest"
  assert_equals "$(git config --file "$conf" --get git.worktreeroot)" \
    "${worktree:A}" "physical worktree root"
  assert_equals "$(git config --file "$conf" --get git.commondir)" \
    "$(git -C "$worktree" rev-parse --path-format=absolute --git-common-dir)" \
    "common Git directory"
  assert_equals "$(git config --file "$conf" --get git.branch)" \
    "feat/descriptor" "task branch"
  assert_equals "$(git config --file "$conf" --get git.baseref)" "main" "base ref"
  assert_equals "$(git config --file "$conf" --get git.basesha)" "$base_sha" "base SHA"
  assert_config_missing "$conf" memory.sharedproject "shared project"
  assert_config_missing "$conf" memory.taskproject "task project"
  assert_equals "$(git config --file "$conf" --get integration.targetbranch)" \
    "main" "target branch"
  assert_equals "$(git config --file "$conf" --get integration.owner)" \
    "sample integrator" "integration owner"
}

test_ignore_is_narrow() {
  make_fixture ignore
  prepare_fixture >/dev/null
  print -r -- "must stay visible" >"$worktree/.superpowers/other.txt"
  local git_status="$(git -C "$worktree" status --porcelain=v1 --untracked-files=all)"
  assert_contains "$git_status" ".superpowers/other.txt"
  [[ "$git_status" != *".superpowers/parallel/"* ]] \
    || fail "parallel metadata leaked into Git status"
}

test_prepare_rejects_main_checkout_and_plan_escape() {
  make_fixture unsafe
  assert_fails "linked worktree" prepare_with \
    --worktree "$repo" --task-id TASK-1 --task-slug task-one \
    --plan README.md --base-ref main --base-sha "$base_sha" \
    --target-branch integration --integration-owner integrator

  print -r -- "outside" >"$fixture_root/outside-plan.md"
  assert_fails "plan must remain inside" prepare_with \
    --worktree "$worktree" --task-id TASK-1 --task-slug task-one \
    --plan ../outside-plan.md --base-ref main --base-sha "$base_sha" \
    --target-branch main --integration-owner integrator

  ln -s "$fixture_root/outside-plan.md" "$worktree/escaped-plan.md"
  assert_fails "plan must remain inside" prepare_with \
    --worktree "$worktree" --task-id TASK-1 --task-slug task-one \
    --plan escaped-plan.md --base-ref main --base-sha "$base_sha" \
    --target-branch main --integration-owner integrator
}

test_prepare_rejects_unsafe_metadata() {
  make_fixture different-ignore
  mkdir -p "$worktree/.superpowers/parallel"
  print -r -- "different" >"$worktree/.superpowers/parallel/.gitignore"
  assert_fails "refusing to overwrite" prepare_fixture

  make_fixture extra-newline
  mkdir -p "$worktree/.superpowers/parallel"
  printf '*\n\n' >"$worktree/.superpowers/parallel/.gitignore"
  assert_fails "refusing to overwrite" prepare_fixture

  make_fixture symlink
  mkdir -p "$fixture_root/escaped" "$worktree/.superpowers"
  ln -s "$fixture_root/escaped" "$worktree/.superpowers/parallel"
  assert_fails "symlink" prepare_fixture
}

test_prepare_rejects_identity_mismatches() {
  make_fixture same-target
  assert_fails "task branch must differ" prepare_with \
    --worktree "$worktree" --task-id TASK-1 --task-slug task-one \
    --plan "$plan_rel" --base-ref main --base-sha "$base_sha" \
    --target-branch "feat/same-target" --integration-owner integrator

  make_fixture wrong-base
  local wrong_sha="$(printf '0%.0s' {1..40})"
  assert_fails "base SHA" prepare_with \
    --worktree "$worktree" --task-id TASK-1 --task-slug task-one \
    --plan "$plan_rel" --base-ref main --base-sha "$wrong_sha" \
    --target-branch main --integration-owner integrator

  make_fixture control
  assert_fails "control character" prepare_with \
    --worktree "$worktree" --task-id $'bad\nvalue' --task-slug task-one \
    --plan "$plan_rel" --base-ref main --base-sha "$base_sha" \
    --target-branch main --integration-owner integrator
}

test_prepare_requires_coordinator_and_explicit_replace() {
  make_fixture replace
  assert_fails "CODEX_THREAD_ID" env -u CODEX_THREAD_ID "$session_bin" prepare \
    --worktree "$worktree" --task-id TASK-1 --task-slug task-one \
    --plan "$plan_rel" --base-ref main --base-sha "$base_sha" \
    --target-branch main --integration-owner integrator

  prepare_fixture >/dev/null
  assert_fails "descriptor already exists" prepare_fixture
  CODEX_THREAD_ID=coordinator-thread "$session_bin" prepare --replace \
    --worktree "$worktree" --task-id TASK-1 --task-slug task-one \
    --plan "$plan_rel" --base-ref main --base-sha "$base_sha" \
    --target-branch main --integration-owner integrator >/dev/null
}

test_prepare_rejects_removed_memory_options() {
  make_fixture removed-memory-options
  assert_fails "removed prepare option: --shared-project" prepare_with \
    --worktree "$worktree" --task-id TASK-1 --task-slug task-one \
    --plan "$plan_rel" --base-ref main --base-sha "$base_sha" \
    --shared-project sample --target-branch main \
    --integration-owner integrator
  assert_fails "removed prepare option: --task-project" prepare_with \
    --worktree "$worktree" --task-id TASK-1 --task-slug task-one \
    --plan "$plan_rel" --base-ref main --base-sha "$base_sha" \
    --task-project sample-task-task-1 --target-branch main \
    --integration-owner integrator
}

test_prepare_allows_multiple_descriptors_without_project_uniqueness() {
  make_fixture multiple-descriptors
  prepare_fixture >/dev/null

  local other_worktree="$fixture_root/other worktree"
  git -C "$repo" worktree add -q -b feat/other-task "$other_worktree" main
  CODEX_THREAD_ID=coordinator-thread "$session_bin" prepare \
    --worktree "$other_worktree" --task-id TASK-2 --task-slug task-two \
    --plan "$plan_rel" --base-ref main --base-sha "$base_sha" \
    --target-branch main --integration-owner integrator >/dev/null

  local other_conf="$other_worktree/.superpowers/parallel/session.conf"
  assert_equals "$(git config --file "$other_conf" --get session.schemaversion)" \
    "2" "second descriptor schema"
  assert_config_missing "$other_conf" memory.taskproject \
    "second descriptor task project"
}

test_preflight_requires_exact_metadata_shape() {
  make_fixture missing-ignore
  prepare_fixture >/dev/null
  rm "$worktree/.superpowers/parallel/.gitignore"
  assert_fails "parallel metadata ignore" run_worker worker-a \
    "$session_bin" claim
  [[ ! -e "$worktree/.superpowers/parallel/owner" ]] \
    || fail "missing ignore must fail before ownership"

  make_fixture changed-ignore
  prepare_fixture >/dev/null
  printf '*\n\n' >"$worktree/.superpowers/parallel/.gitignore"
  assert_fails "parallel metadata ignore" run_worker worker-a \
    "$session_bin" claim
  [[ ! -e "$worktree/.superpowers/parallel/owner" ]] \
    || fail "changed ignore must fail before ownership"

  make_fixture descriptor-directory
  mkdir -p "$worktree/.superpowers/parallel/session.conf"
  assert_fails "session.conf must be a regular file" \
    env CODEX_THREAD_ID=coordinator-thread "$session_bin" prepare --replace \
      --worktree "$worktree" --task-id TASK-1 --task-slug task-one \
      --plan "$plan_rel" --base-ref main --base-sha "$base_sha" \
      --target-branch main --integration-owner integrator
  [[ -z "$(ls -A "$worktree/.superpowers/parallel/session.conf")" ]] \
    || fail "failed descriptor replacement wrote inside a directory"

  make_fixture owner-file
  prepare_fixture >/dev/null
  print -r -- "not a directory" >"$worktree/.superpowers/parallel/owner"
  assert_fails "owner must be a directory" run_worker worker-a \
    "$session_bin" claim
}

test_guard_classifies_session_boundary() {
  make_fixture guard

  local primary_output
  primary_output="$(cd "$repo" && "$session_bin" guard)"
  assert_contains "$primary_output" "COORDINATOR_ONLY"
  assert_contains "$primary_output" "root=${repo:A}"
  assert_contains "$primary_output" "branch=main"

  assert_fails "linked worktree is unprepared" run_worker worker-a \
    "$session_bin" guard

  prepare_fixture >/dev/null
  local prepared_output
  prepared_output="$(run_worker worker-a "$session_bin" guard)"
  assert_contains "$prepared_output" \
    "PREPARED_UNCLAIMED task=TASK-1 root=${worktree:A}"
  [[ "$prepared_output" != *"memory="* ]] \
    || fail "schema-v2 guard output must not expose a memory project"

  run_worker worker-a "$session_bin" claim >/dev/null
  local writer_output
  writer_output="$(run_worker worker-a "$session_bin" guard)"
  assert_contains "$writer_output" \
    "WRITER_BOUNDARY task=TASK-1 owner=worker-a root=${worktree:A}"
  [[ "$writer_output" != *"memory="* ]] \
    || fail "schema-v2 writer boundary must not expose a memory project"
  assert_fails "current owner mismatch" run_worker worker-b \
    "$session_bin" guard
}

test_claim_requires_identity_and_is_idempotent() {
  make_fixture claim
  prepare_fixture >/dev/null

  assert_fails "CODEX_THREAD_ID" env -u CODEX_THREAD_ID \
    -u ENGRAM_PROJECT -u ENGRAM_DATA_DIR "$session_bin" claim
  assert_fails "claim does not accept options" run_worker worker-a \
    "$session_bin" claim --worktree /definitely/wrong
  [[ ! -e "$worktree/.superpowers/parallel/owner" ]] \
    || fail "malformed claim invocation created an owner boundary"

  run_worker worker-a "$session_bin" claim >/dev/null
  run_worker worker-a "$session_bin" claim >/dev/null
  assert_fails "owned by another thread" run_worker worker-b \
    "$session_bin" claim

  local claim_file="$worktree/.superpowers/parallel/owner/claim.conf"
  assert_equals "$(git config --file "$claim_file" --get owner.threadid)" \
    "worker-a" "claim owner"
  [[ "$(git config --file "$claim_file" --get owner.claimedat)" =~ \
     ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]] \
    || fail "claimedAt must be UTC RFC3339"
}

test_claim_race_has_one_winner() {
  make_fixture race
  prepare_fixture >/dev/null
  local out_a="$fixture_root/a.out" out_b="$fixture_root/b.out"
  local exit_a exit_b

  run_worker worker-a "$session_bin" claim >"$out_a" 2>&1 &
  local pid_a=$!
  run_worker worker-b "$session_bin" claim >"$out_b" 2>&1 &
  local pid_b=$!
  set +e
  wait "$pid_a"; exit_a=$?
  wait "$pid_b"; exit_b=$?
  set -e
  (( (exit_a == 0) != (exit_b == 0) )) \
    || fail "exactly one concurrent claimant must win"

  local winner="$(git config --file \
    "$worktree/.superpowers/parallel/owner/claim.conf" --get owner.threadid)"
  [[ "$winner" == worker-a || "$winner" == worker-b ]] \
    || fail "race recorded unknown owner: $winner"
}

test_incomplete_claim_fails_closed() {
  make_fixture incomplete
  prepare_fixture >/dev/null
  mkdir "$worktree/.superpowers/parallel/owner"
  assert_fails "incomplete owner claim" run_worker worker-a \
    "$session_bin" claim
  assert_fails "incomplete owner claim" run_worker worker-a \
    "$session_bin" release
  [[ -d "$worktree/.superpowers/parallel/owner" ]] \
    || fail "incomplete claim must be preserved"
}

test_verify_is_legacy_only_and_handoff_release_still_work() {
  make_fixture verify-v2
  prepare_fixture >/dev/null
  run_worker worker-a "$session_bin" claim >/dev/null
  assert_fails "schema v2 does not use memory-project verification" \
    run_worker worker-a "$session_bin" verify \
      --memory-project sample-task-task-1
  run_worker worker-a "$session_bin" release >/dev/null

  make_fixture ownership
  prepare_legacy_fixture
  run_worker worker-a "$session_bin" claim >/dev/null

  local verify_output
  verify_output="$(run_worker worker-a "$session_bin" verify \
    --memory-project sample-task-task-1)"
  assert_contains "$verify_output" "VERIFIED task=TASK-1 owner=worker-a"
  assert_fails "memory project confirmation" run_worker worker-a \
    "$session_bin" verify --memory-project wrong
  assert_fails "duplicate option: --memory-project" run_worker worker-a \
    "$session_bin" verify --memory-project "" \
      --memory-project sample-task-task-1
  assert_fails "current owner" run_worker worker-b \
    "$session_bin" handoff --to worker-c
  assert_fails "duplicate option: --to" run_worker worker-a \
    "$session_bin" handoff --to "" --to worker-c

  run_worker worker-a "$session_bin" handoff --to worker-b >/dev/null
  assert_fails "current owner" run_worker worker-a \
    "$session_bin" verify --memory-project sample-task-task-1
  run_worker worker-b "$session_bin" verify \
    --memory-project sample-task-task-1 >/dev/null
  run_worker worker-b "$session_bin" release >/dev/null
  [[ ! -e "$worktree/.superpowers/parallel/owner" ]] \
    || fail "release must remove only the empty ownership boundary"
}

test_reverification_detects_drift_but_owner_can_release() {
  make_fixture drift
  prepare_fixture >/dev/null
  run_worker worker-a "$session_bin" claim >/dev/null
  print -r -- "changed" >>"$worktree/$plan_rel"

  assert_fails "plan digest" run_worker worker-a "$session_bin" claim
  assert_fails "plan digest" run_worker worker-a "$session_bin" guard
  assert_fails "active owner" env CODEX_THREAD_ID=coordinator-thread \
    "$session_bin" prepare --replace --worktree "$worktree" \
    --task-id TASK-1 --task-slug task-one --plan "$plan_rel" \
    --base-ref main --base-sha "$base_sha" --target-branch main \
    --integration-owner integrator

  run_worker worker-a "$session_bin" release >/dev/null
  [[ ! -e "$worktree/.superpowers/parallel/owner" ]] \
    || fail "the explicit owner must be able to release after descriptor drift"
}

assert_claim_fails_without_owner() {
  local expected="$1"
  assert_fails "$expected" run_worker worker-a "$session_bin" claim
  [[ ! -e "$worktree/.superpowers/parallel/owner" ]] \
    || fail "failed preflight created an owner boundary"
}

test_descriptor_mutations_fail_closed() {
  local conf outside

  make_fixture schema
  prepare_fixture >/dev/null
  conf="$worktree/.superpowers/parallel/session.conf"
  git config --file "$conf" session.schemaVersion 3
  assert_claim_fails_without_owner "unsupported schema"

  make_fixture legacy-missing-memory
  prepare_legacy_fixture
  conf="$worktree/.superpowers/parallel/session.conf"
  git config --file "$conf" --unset memory.taskProject
  assert_claim_fails_without_owner \
    "missing descriptor field: memory.taskProject"

  make_fixture missing-field
  prepare_fixture >/dev/null
  conf="$worktree/.superpowers/parallel/session.conf"
  git config --file "$conf" --unset task.id
  assert_claim_fails_without_owner "missing descriptor field: task.id"

  make_fixture wrong-root
  prepare_fixture >/dev/null
  conf="$worktree/.superpowers/parallel/session.conf"
  git config --file "$conf" git.worktreeRoot "$fixture_root"
  assert_claim_fails_without_owner "worktree root mismatch"

  make_fixture wrong-common
  prepare_fixture >/dev/null
  conf="$worktree/.superpowers/parallel/session.conf"
  git config --file "$conf" git.commonDir "$fixture_root"
  assert_claim_fails_without_owner "common Git directory mismatch"

  make_fixture wrong-branch
  prepare_fixture >/dev/null
  git -C "$worktree" switch -qc feat/other
  assert_claim_fails_without_owner "branch mismatch"

  make_fixture wrong-ancestry
  prepare_fixture >/dev/null
  conf="$worktree/.superpowers/parallel/session.conf"
  git -C "$worktree" switch --orphan unrelated >/dev/null 2>&1
  git -C "$worktree" rm -qf --ignore-unmatch README.md
  print -r -- "unrelated" >"$worktree/unrelated.txt"
  git -C "$worktree" add unrelated.txt
  git -C "$worktree" commit -qm "unrelated"
  git config --file "$conf" git.branch unrelated
  assert_claim_fails_without_owner "base ancestry"

  make_fixture wrong-plan
  prepare_fixture >/dev/null
  print -r -- "changed" >>"$worktree/$plan_rel"
  assert_claim_fails_without_owner "plan digest"

  make_fixture escaped-plan
  prepare_fixture >/dev/null
  conf="$worktree/.superpowers/parallel/session.conf"
  outside="$fixture_root/outside.md"
  print -r -- "outside" >"$outside"
  ln -s "$outside" "$worktree/external-plan.md"
  git config --file "$conf" task.planPath external-plan.md
  git config --file "$conf" task.planSha256 \
    "$(shasum -a 256 -- "$outside" | awk '{print $1}')"
  assert_claim_fails_without_owner "plan must remain inside"

  make_fixture session-symlink
  prepare_fixture >/dev/null
  conf="$worktree/.superpowers/parallel/session.conf"
  outside="$fixture_root/session.conf"
  mv "$conf" "$outside"
  ln -s "$outside" "$conf"
  assert_claim_fails_without_owner "symlink"

  make_fixture completion-symlink
  prepare_fixture >/dev/null
  outside="$fixture_root/completion.conf"
  print -r -- "outside" >"$outside"
  ln -s "$outside" "$worktree/.superpowers/parallel/completion.conf"
  assert_claim_fails_without_owner "symlink"

  make_fixture owner-symlink
  prepare_fixture >/dev/null
  mkdir "$fixture_root/owner"
  ln -s "$fixture_root/owner" "$worktree/.superpowers/parallel/owner"
  assert_fails "symlink" run_worker worker-a "$session_bin" claim
  [[ ! -e "$fixture_root/owner/claim.conf" ]] \
    || fail "symlinked owner escaped metadata boundary"
}

test_launch_and_resume_use_exact_boundaries() {
  make_fixture launch
  prepare_fixture >/dev/null
  make_codex_stub

  run_codex_boundary launch --worktree "$worktree"
  assert_equals "$(<"$stub_env")" "unset" "launch Engram project"
  assert_equals "$(<"$stub_data_dir")" "unset" \
    "launch Engram data directory"

  local -a launch_args
  launch_args=("${(@f)$(<"$stub_args")}")
  assert_equals "${#launch_args[@]}" "5" "launch argument count"
  assert_equals "${launch_args[1]}" "-p" "launch profile flag"
  assert_equals "${launch_args[2]}" "parallel-work" "launch profile"
  assert_equals "${launch_args[3]}" "-C" "launch root flag"
  assert_equals "${launch_args[4]}" "${worktree:A}" "launch physical root"

  local launch_prompt="${launch_args[5]}"
  assert_contains "$launch_prompt" "TASK-1"
  assert_contains "$launch_prompt" "$plan_rel"
  assert_contains "$launch_prompt" "superpowers:orchestrating-parallel-worktrees"
  assert_contains "$launch_prompt" "${session_bin:A}"
  assert_contains "$launch_prompt" "guard"
  assert_contains "$launch_prompt" "claim"
  assert_contains "$launch_prompt" "BLOCKED"
  assert_contains "$launch_prompt" "compaction"
  [[ "$launch_prompt" != *"mem_current_project"* ]] \
    || fail "schema-v2 launch prompt must not require mem_current_project"
  [[ "$launch_prompt" != *"verify --memory-project"* ]] \
    || fail "schema-v2 launch prompt must not require memory verification"

  run_worker worker-a "$session_bin" claim >/dev/null
  assert_fails "active owner" run_codex_boundary launch --worktree "$worktree"

  run_codex_boundary resume --worktree "$worktree"
  assert_equals "$(<"$stub_env")" "unset" "resume Engram project"
  assert_equals "$(<"$stub_data_dir")" "unset" \
    "resume Engram data directory"
  local -a resume_args
  resume_args=("${(@f)$(<"$stub_args")}")
  assert_equals "${#resume_args[@]}" "7" "resume argument count"
  assert_equals "${resume_args[1]}" "-p" "resume profile flag"
  assert_equals "${resume_args[2]}" "parallel-work" "resume profile"
  assert_equals "${resume_args[3]}" "-C" "resume root flag"
  assert_equals "${resume_args[4]}" "${worktree:A}" "resume physical root"
  assert_equals "${resume_args[5]}" "resume" "resume subcommand"
  assert_equals "${resume_args[6]}" "worker-a" "recorded resume owner"
  local resume_prompt="${resume_args[7]}"
  assert_contains "$resume_prompt" "TASK-1"
  assert_contains "$resume_prompt" "$plan_rel"
  assert_contains "$resume_prompt" "superpowers:orchestrating-parallel-worktrees"
  assert_contains "$resume_prompt" "${session_bin:A}"
  assert_contains "$resume_prompt" "guard"
  assert_contains "$resume_prompt" "claim"
  assert_contains "$resume_prompt" "BLOCKED"
  assert_contains "$resume_prompt" "compaction"
  [[ "$resume_prompt" != *"mem_current_project"* ]] \
    || fail "schema-v2 resume prompt must not require mem_current_project"
  [[ "$resume_prompt" != *"verify --memory-project"* ]] \
    || fail "schema-v2 resume prompt must not require memory verification"

  make_fixture legacy-launch
  prepare_legacy_fixture
  make_codex_stub
  run_codex_boundary launch --worktree "$worktree"
  assert_equals "$(<"$stub_env")" "unset" \
    "legacy launch must not inject Engram project"
  launch_args=("${(@f)$(<"$stub_args")}")
  assert_equals "${#launch_args[@]}" "5" "legacy launch argument count"
  [[ "${launch_args[5]}" != *"mem_current_project"* ]] \
    || fail "legacy launch prompt must not require mem_current_project"
  run_worker worker-a "$session_bin" claim >/dev/null
  run_codex_boundary resume --worktree "$worktree"
  assert_equals "$(<"$stub_env")" "unset" \
    "legacy resume must not inject Engram project"
  resume_args=("${(@f)$(<"$stub_args")}")
  assert_equals "${#resume_args[@]}" "7" "legacy resume argument count"
  [[ "${resume_args[7]}" != *"verify --memory-project"* ]] \
    || fail "legacy resume prompt must not require memory verification"

  if rg -n '(^|[^[:alnum:]_])eval([^[:alnum:]_]|$)' "$session_bin" >/dev/null; then
    fail "launch helper must not invoke eval"
  fi
  if rg -n '^[[:space:]]*((local|typeset)[[:space:]]+)?[A-Za-z_][A-Za-z0-9_]*(command|cmd|line)[A-Za-z0-9_]*=.*codex' \
    "$session_bin" >/dev/null; then
    fail "launch helper must not reconstruct codex as a scalar command string"
  fi
}

test_resume_requires_complete_owner() {
  make_fixture resume-no-owner
  prepare_fixture >/dev/null
  make_codex_stub
  assert_fails "owner claim" run_codex_boundary resume --worktree "$worktree"

  mkdir "$worktree/.superpowers/parallel/owner"
  assert_fails "incomplete owner claim" \
    run_codex_boundary resume --worktree "$worktree"
}

test_report_state_consistency() {
  make_fixture committed-empty
  claim_fixture
  assert_fails "at least one local commit" \
    run_ready_report LOCAL_READY_COMMITTED

  make_fixture committed
  claim_fixture
  make_task_commit "committed work"
  run_ready_report LOCAL_READY_COMMITTED >/dev/null
  run_report_check >/dev/null

  make_fixture uncommitted
  claim_fixture
  print -r -- "dirty" >>"$worktree/README.md"
  run_ready_report LOCAL_READY_UNCOMMITTED >/dev/null

  make_fixture uncommitted-clean
  claim_fixture
  assert_fails "dirty worktree" \
    run_ready_report LOCAL_READY_UNCOMMITTED

  make_fixture uncommitted-with-commit
  claim_fixture
  make_task_commit "local commit"
  print -r -- "still dirty" >>"$worktree/README.md"
  assert_fails "zero local commits" \
    run_ready_report LOCAL_READY_UNCOMMITTED
}

test_legacy_descriptor_report_compatibility() {
  make_fixture legacy-report
  prepare_legacy_fixture
  run_worker worker-a "$session_bin" claim >/dev/null
  make_task_commit "legacy report"
  run_ready_report LOCAL_READY_COMMITTED >/dev/null
  run_report_check >/dev/null

  local completion="$worktree/.superpowers/parallel/completion.conf"
  assert_equals \
    "$(git config --file "$completion" --get completion.schemaversion)" \
    "1" "legacy descriptor completion schema"
  assert_equals "$(git config --file "$completion" --get completion.taskid)" \
    "TASK-1" "legacy descriptor completion task"
}

test_report_requires_evidence_and_blocker_fields() {
  make_fixture report-required
  claim_fixture
  make_task_commit "ready"

  assert_fails "verification" run_worker worker-a "$session_bin" report \
    --state LOCAL_READY_COMMITTED --freshness-source local \
    --evidence deterministic --next-action review
  assert_fails "evidence" run_worker worker-a "$session_bin" report \
    --state LOCAL_READY_COMMITTED --freshness-source local \
    --verification tests --next-action review
  assert_fails "next action" run_worker worker-a "$session_bin" report \
    --state LOCAL_READY_COMMITTED --freshness-source local \
    --verification tests --evidence deterministic
  assert_fails "control character" run_worker worker-a "$session_bin" report \
    --state LOCAL_READY_COMMITTED --freshness-source local \
    --verification $'bad\ncommand' --evidence deterministic \
    --next-action review

  assert_fails "blocker" run_worker worker-a "$session_bin" report \
    --state BLOCKED --freshness-source unavailable \
    --last-successful-state "descriptor prepared" --next-action "ask owner"
  assert_fails "last successful state" run_worker worker-a "$session_bin" report \
    --state BLOCKED --freshness-source unavailable \
    --blocker "needs approval" --next-action "ask owner"
  assert_fails "next action" run_worker worker-a "$session_bin" report \
    --state BLOCKED --freshness-source unavailable \
    --blocker "needs approval" --last-successful-state "tests passed"
  assert_fails "verification" run_worker worker-a "$session_bin" report \
    --state BLOCKED --freshness-source unavailable \
    --verification "tests passed" --blocker "needs approval" \
    --last-successful-state "tests passed" --next-action "ask owner"
}

test_report_records_exact_evidence_and_freshness() {
  make_fixture report-fields
  claim_fixture
  make_task_commit "ready evidence one"
  local first_commit="$(git -C "$worktree" rev-parse HEAD)"
  make_task_commit "ready evidence two"
  local second_commit="$(git -C "$worktree" rev-parse HEAD)"

  run_worker worker-a "$session_bin" report \
    --state LOCAL_READY_COMMITTED --freshness-source local \
    --verification "test one" --verification "test two" \
    --evidence "unit" --evidence "integration" \
    --candidate-discovery "candidate one" \
    --candidate-discovery "candidate two" \
    --risk "risk one" --risk "risk two" \
    --next-action "review one" --next-action "review two" >/dev/null

  local completion="$worktree/.superpowers/parallel/completion.conf"
  local descriptor="$worktree/.superpowers/parallel/session.conf"
  assert_equals "$(git config --file "$completion" --get completion.schemaversion)" \
    "1" "completion schema"
  assert_equals "$(git config --file "$completion" --get completion.state)" \
    "LOCAL_READY_COMMITTED" "completion state"
  assert_equals "$(git config --file "$completion" --get completion.taskid)" \
    "TASK-1" "completion task"
  assert_equals "$(git config --file "$completion" --get completion.ownerthreadid)" \
    "worker-a" "completion owner"
  assert_equals "$(git config --file "$completion" --get completion.descriptorsha256)" \
    "$(shasum -a 256 -- "$descriptor" | awk '{print $1}')" \
    "descriptor digest"
  assert_equals "$(git config --file "$completion" --get git.dirty)" \
    "false" "committed dirty flag"
  assert_equals "$(git config --file "$completion" --get-all git.localcommit)" \
    "$first_commit"$'\n'"$second_commit" "ordered local commits"
  assert_equals "$(git config --file "$completion" --get-all verification.command)" \
    $'test one\ntest two' "verification list"
  assert_equals "$(git config --file "$completion" --get-all evidence.classification)" \
    $'unit\nintegration' "evidence list"
  assert_equals "$(git config --file "$completion" --get-all discovery.candidate)" \
    $'candidate one\ncandidate two' "candidate list"
  assert_equals "$(git config --file "$completion" --get-all risk.item)" \
    $'risk one\nrisk two' "risk list"
  assert_equals "$(git config --file "$completion" --get-all gate.nextaction)" \
    $'review one\nreview two' "next-action list"
  assert_equals "$(git config --file "$completion" --get freshness.source)" \
    "local-ref-only" "local freshness wording"
  assert_equals "$(git config --file "$completion" --get freshness.ref)" \
    "main" "local freshness ref"
  assert_equals "$(git config --file "$completion" --get freshness.sha)" \
    "$(git -C "$worktree" rev-parse main)" "local freshness SHA"
  if rg -n 'remote-current' "$completion" >/dev/null; then
    fail "local freshness must never claim remote currency"
  fi

  local before_check="$(shasum -a 256 -- "$completion" | awk '{print $1}')"
  local check_output="$(run_report_check)"
  assert_contains "$check_output" "CHECKED_READ_ONLY"
  assert_equals "$(shasum -a 256 -- "$completion" | awk '{print $1}')" \
    "$before_check" "read-only report check"

  local index_path="$(git -C "$worktree" rev-parse \
    --path-format=absolute --git-path index)"
  local index_before="$(shasum -a 256 -- "$index_path" | awk '{print $1}')"
  touch -t 202001010000 "$worktree/README.md"
  run_report_check >/dev/null
  assert_equals "$(shasum -a 256 -- "$index_path" | awk '{print $1}')" \
    "$index_before" "read-only report check index digest"

  git config --file "$completion" --replace-all verification.command ""
  assert_fails "verification must not be empty" run_report_check
  git config --file "$completion" --replace-all verification.command "test one"
  git config --file "$completion" --replace-all evidence.classification \
    $'bad\nclassification'
  assert_fails "evidence contains a control character" run_report_check
  git config --file "$completion" --replace-all evidence.classification "unit"
  git config --file "$completion" --replace-all gate.nextaction ""
  assert_fails "next action must not be empty" run_report_check

  assert_fails "current owner" run_worker worker-b "$session_bin" report \
    --state LOCAL_READY_COMMITTED --freshness-source local \
    --verification test --evidence deterministic --next-action review

  make_fixture report-path-with-spaces
  claim_fixture
  print -r -- "dirty" >"$worktree/path with spaces.txt"
  local expected_changed_path="$(git -C "$worktree" -c core.quotePath=true \
    status --porcelain=v1 --untracked-files=all)"
  run_ready_report LOCAL_READY_UNCOMMITTED >/dev/null
  completion="$worktree/.superpowers/parallel/completion.conf"
  assert_contains "$expected_changed_path" "path with spaces.txt"
  assert_equals "$(git config --file "$completion" --get-all git.changedpath)" \
    "$expected_changed_path" "changed path with spaces"
}

test_report_fetched_and_unavailable_freshness() {
  make_fixture fetched
  claim_fixture
  make_task_commit "fetched ready"
  git -C "$worktree" update-ref refs/remotes/origin/main "$base_sha"
  local fetched_ref="refs/remotes/origin/main"
  local fetched_sha_before="$(git -C "$worktree" rev-parse "$fetched_ref")"

  assert_fails "fetched-at" run_worker worker-a "$session_bin" report \
    --state LOCAL_READY_COMMITTED --freshness-source fetched \
    --freshness-ref "$fetched_ref" --verification test \
    --evidence deterministic --next-action review
  assert_fails "RFC3339" run_worker worker-a "$session_bin" report \
    --state LOCAL_READY_COMMITTED --freshness-source fetched \
    --freshness-ref "$fetched_ref" --fetched-at yesterday \
    --verification test --evidence deterministic --next-action review
  run_worker worker-a "$session_bin" report \
    --state LOCAL_READY_COMMITTED --freshness-source fetched \
    --freshness-ref "$fetched_ref" --fetched-at 2026-08-09T00:00:00Z \
    --verification test --evidence deterministic --next-action review >/dev/null
  local completion="$worktree/.superpowers/parallel/completion.conf"
  assert_equals "$(git config --file "$completion" --get freshness.source)" \
    "fresh-fetch-asserted" "fetched freshness wording"
  assert_equals "$(git config --file "$completion" --get freshness.ref)" \
    "$fetched_ref" "fetched ref"
  assert_equals "$(git config --file "$completion" --get freshness.sha)" \
    "$fetched_sha_before" "fetched SHA"
  assert_equals "$(git config --file "$completion" --get freshness.checkedat)" \
    "2026-08-09T00:00:00Z" "fetched timestamp"
  assert_equals "$(git -C "$worktree" rev-parse "$fetched_ref")" \
    "$fetched_sha_before" "report performs no fetch"

  make_fixture unavailable
  claim_fixture
  print -r -- "dirty" >>"$worktree/README.md"
  assert_fails "only for BLOCKED" run_worker worker-a "$session_bin" report \
    --state LOCAL_READY_UNCOMMITTED --freshness-source unavailable \
    --verification test --evidence deterministic --next-action review
  run_worker worker-a "$session_bin" report \
    --state BLOCKED --freshness-source unavailable \
    --blocker "provider gate missing" \
    --last-successful-state "deterministic tests passed" \
    --next-action "request provider approval" >/dev/null
  completion="$worktree/.superpowers/parallel/completion.conf"
  assert_equals "$(git config --file "$completion" --get freshness.source)" \
    "unavailable" "unavailable freshness"
  if git config --file "$completion" --get freshness.ref >/dev/null 2>&1; then
    fail "unavailable freshness must omit freshness.ref"
  fi
  if git config --file "$completion" --get freshness.sha >/dev/null 2>&1; then
    fail "unavailable freshness must omit freshness.sha"
  fi
  run_report_check >/dev/null
}

test_blocked_report_survives_descriptor_drift() {
  make_fixture blocked-plan-drift
  claim_fixture
  print -r -- "changed" >>"$worktree/$plan_rel"
  assert_fails "plan digest" run_ready_report LOCAL_READY_UNCOMMITTED
  run_worker worker-a "$session_bin" report \
    --state BLOCKED --freshness-source unavailable \
    --blocker "plan changed" --last-successful-state "owner claimed" \
    --next-action "reconcile plan" >/dev/null
  run_report_check >/dev/null

  make_fixture blocked-branch-drift
  claim_fixture
  git -C "$worktree" switch -qc drifted
  assert_fails "branch mismatch" run_worker worker-a "$session_bin" report \
    --state LOCAL_READY_COMMITTED --freshness-source local \
    --verification test --evidence deterministic --next-action review
  run_worker worker-a "$session_bin" report \
    --state BLOCKED --freshness-source unavailable \
    --blocker "branch changed" --last-successful-state "owner claimed" \
    --next-action "reconcile branch" >/dev/null
  run_report_check >/dev/null
}

make_checked_committed_fixture() {
  local name="$1"
  make_fixture "$name"
  claim_fixture
  make_task_commit "$name ready"
  run_ready_report LOCAL_READY_COMMITTED >/dev/null
  run_report_check >/dev/null
}

test_report_check_detects_git_and_descriptor_changes() {
  make_checked_committed_fixture stale-edit
  print -r -- "edit" >>"$worktree/README.md"
  assert_fails "porcelain" run_report_check

  make_checked_committed_fixture stale-staged
  print -r -- "staged" >>"$worktree/README.md"
  git -C "$worktree" add README.md
  assert_fails "porcelain" run_report_check

  make_checked_committed_fixture stale-untracked
  print -r -- "untracked" >"$worktree/untracked.txt"
  assert_fails "porcelain" run_report_check

  make_checked_committed_fixture stale-commit
  print -r -- "later" >>"$worktree/task-change.txt"
  git -C "$worktree" add task-change.txt
  git -C "$worktree" commit -qm "later commit"
  assert_fails "HEAD" run_report_check

  make_checked_committed_fixture stale-branch
  git -C "$worktree" switch -qc another-branch
  assert_fails "branch mismatch" run_report_check

  make_checked_committed_fixture stale-descriptor
  git config --file "$worktree/.superpowers/parallel/session.conf" \
    integration.owner "changed integrator"
  assert_fails "descriptor digest" run_report_check

  make_checked_committed_fixture stale-owner
  run_worker worker-a "$session_bin" handoff --to worker-b >/dev/null
  assert_fails "recorded owner" run_report_check
}

test_report_check_detects_freshness_ref_movement() {
  make_checked_committed_fixture stale-local-ref
  print -r -- "new main" >"$repo/main-change.txt"
  git -C "$repo" add main-change.txt
  git -C "$repo" commit -qm "move main"
  assert_fails "freshness SHA" run_report_check

  make_fixture stale-fetched-ref
  claim_fixture
  make_task_commit "fetched report"
  git -C "$worktree" update-ref refs/remotes/origin/main "$base_sha"
  run_worker worker-a "$session_bin" report \
    --state LOCAL_READY_COMMITTED --freshness-source fetched \
    --freshness-ref refs/remotes/origin/main \
    --fetched-at 2026-08-09T00:00:00Z --verification test \
    --evidence deterministic --next-action review >/dev/null
  git -C "$worktree" update-ref refs/remotes/origin/main HEAD
  assert_fails "freshness SHA" run_report_check
}

test_prepare_writes_exact_descriptor
test_ignore_is_narrow
test_prepare_rejects_main_checkout_and_plan_escape
test_prepare_rejects_unsafe_metadata
test_prepare_rejects_identity_mismatches
test_prepare_requires_coordinator_and_explicit_replace
test_prepare_rejects_removed_memory_options
test_prepare_allows_multiple_descriptors_without_project_uniqueness
test_preflight_requires_exact_metadata_shape
test_guard_classifies_session_boundary
test_claim_requires_identity_and_is_idempotent
test_claim_race_has_one_winner
test_incomplete_claim_fails_closed
test_verify_is_legacy_only_and_handoff_release_still_work
test_reverification_detects_drift_but_owner_can_release
test_descriptor_mutations_fail_closed
test_launch_and_resume_use_exact_boundaries
test_resume_requires_complete_owner
test_report_state_consistency
test_legacy_descriptor_report_compatibility
test_report_requires_evidence_and_blocker_fields
test_report_records_exact_evidence_and_freshness
test_report_fetched_and_unavailable_freshness
test_blocked_report_survives_descriptor_drift
test_report_check_detects_git_and_descriptor_changes
test_report_check_detects_freshness_ref_movement

print -- "PASS: parallel worktree session boundaries"
