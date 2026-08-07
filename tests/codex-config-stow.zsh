#!/usr/bin/env zsh

emulate -LR zsh
setopt errexit nounset pipefail

repo_root="${0:A:h:h}"
test_root="$(mktemp -d /tmp/codex-config-stow-test.XXXXXX)"
trap 'rm -rf "$test_root"' EXIT

fail() {
  print -u2 -- "FAIL: $*"
  exit 1
}

mkdir -p "$test_root/.codex"
print -r -- "sentinel runtime state" >"$test_root/.codex/state.json"

[[ -f "$repo_root/codex-config/.codex/AGENTS.md" ]] \
  || fail "global AGENTS policy is missing"
[[ -f "$repo_root/codex-config/.codex/policies/bounded-autonomy.md" ]] \
  || fail "bounded-autonomy policy is missing"

global_agents="$repo_root/codex-config/.codex/AGENTS.md"
for required_policy in \
  "## Concurrent sessions" \
  "one active writer" \
  "read-only" \
  "shared runtime" \
  "After compaction"
do
  rg --fixed-strings --quiet "$required_policy" "$global_agents" \
    || fail "global AGENTS policy is missing: $required_policy"
done

stow --no-folding \
  --dir "$repo_root" \
  --target "$test_root" \
  codex-config

[[ -d "$test_root/.codex" && ! -L "$test_root/.codex" ]] \
  || fail ".codex must remain a real directory"
[[ -L "$test_root/.codex/AGENTS.md" ]] \
  || fail "AGENTS.md must be a symlink"
[[ -d "$test_root/.codex/policies" && ! -L "$test_root/.codex/policies" ]] \
  || fail ".codex/policies must remain a real directory"
[[ -L "$test_root/.codex/policies/bounded-autonomy.md" ]] \
  || fail "bounded-autonomy.md must be a symlink"

agents_link="$test_root/.codex/AGENTS.md"
policy_link="$test_root/.codex/policies/bounded-autonomy.md"
[[ "${agents_link:A}" == "$repo_root/codex-config/.codex/AGENTS.md" ]] \
  || fail "AGENTS.md must resolve to the codex-config package"
[[ "${policy_link:A}" == "$repo_root/codex-config/.codex/policies/bounded-autonomy.md" ]] \
  || fail "bounded-autonomy.md must resolve to the codex-config package"
[[ "$(<"$test_root/.codex/state.json")" == "sentinel runtime state" ]] \
  || fail "existing Codex runtime state changed"

apply_recipe="$(make -s -n -C "$repo_root" stow-apply)"
[[ "$apply_recipe" == *'stow --no-folding -v ctx codex-config'* ]] \
  || fail "codex-config must use the state-adjacent no-folding Stow command"
[[ "$(make -s -C "$repo_root" stow-list)" == *$'\ncodex-config'* ]] \
  || fail "codex-config must appear in the default Stow package list"

print -- "PASS: Codex global and progressive policy Stow package"
