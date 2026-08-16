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

profile_source="$repo_root/codex-config/.codex/parallel-work.config.toml"
[[ -f "$profile_source" ]] || fail "parallel-work profile is missing"
[[ "$(<"$profile_source")" == $'service_tier = "default"\nmodel = "gpt-5.6-sol"\nmodel_reasoning_effort = "xhigh"\n[plugins."engram@engram"]\nenabled = false\n\n[mcp_servers.engram]\nenabled = false' ]] \
  || fail "parallel-work profile must preserve model defaults and disable the Engram plugin and MCP server"

skill_source="$repo_root/codex-config/.codex/skills/orchestrating-parallel-worktrees/SKILL.md"
helper_source="$repo_root/codex-config/.codex/skills/orchestrating-parallel-worktrees/scripts/worktree-session"
[[ -f "$skill_source" ]] || fail "parallel worktree orchestration skill is missing"
[[ -f "$helper_source" ]] || fail "parallel worktree session helper is missing"
[[ -x "$helper_source" ]] || fail "parallel worktree session helper must be executable"

global_agents="$repo_root/codex-config/.codex/AGENTS.md"
for required_policy in \
  "## Concurrent sessions" \
  "one active writer" \
  "read-only" \
  "shared runtime" \
  "After compaction" \
  "Ordinary single-task work" \
  "does not require a descriptor or claim" \
  "two or more writer sessions" \
  'existing `.superpowers/parallel/session.conf`' \
  ".superpowers/parallel/session.conf" \
  "orchestrating-parallel-worktrees" \
  "startup checkout is the only checkout it may mutate" \
  '`workdir`, `git -C`, or absolute paths' \
  "explicit integration owner"
do
  rg --fixed-strings --quiet "$required_policy" "$global_agents" \
    || fail "global AGENTS policy is missing: $required_policy"
done

if rg --fixed-strings --quiet "mem_current_project" "$global_agents"; then
  fail "ordinary global policy must not require mem_current_project"
fi

for required_boundary in \
  '`worktree-session guard`' \
  '`COORDINATOR_ONLY`' \
  "startup checkout" \
  "plan and descriptor bootstrap" \
  '`workdir`, `git -C`, or absolute paths'
do
  rg --fixed-strings --quiet "$required_boundary" "$skill_source" \
    || fail "parallel worktree skill boundary is missing: $required_boundary"
done

for required_shell_guard in \
  '`status` (read-only)' \
  '`path` (tied to `PATH`)' \
  '`git_status_text`' \
  '`changed_paths_text`' \
  'Bash-specific multiline wrappers' \
  'explicitly with `bash`'
do
  rg --fixed-strings --quiet "$required_shell_guard" "$global_agents" \
    || fail "global AGENTS shell guard is missing: $required_shell_guard"
  rg --fixed-strings --quiet "$required_shell_guard" "$skill_source" \
    || fail "parallel worktree skill shell guard is missing: $required_shell_guard"
done

stow --no-folding \
  --dir "$repo_root" \
  --target "$test_root" \
  codex-config

[[ -L "$test_root/.codex/parallel-work.config.toml" ]] \
  || fail "parallel-work.config.toml must be a symlink"
profile_link="$test_root/.codex/parallel-work.config.toml"
[[ "${profile_link:A}" == "$profile_source" ]] \
  || fail "parallel-work profile must resolve to the codex-config package"

skill_link="$test_root/.codex/skills/orchestrating-parallel-worktrees/SKILL.md"
helper_link="$test_root/.codex/skills/orchestrating-parallel-worktrees/scripts/worktree-session"
scripts_target="$test_root/.codex/skills/orchestrating-parallel-worktrees/scripts"
[[ -L "$skill_link" ]] || fail "orchestration SKILL.md must be a symlink"
[[ -L "$helper_link" ]] || fail "worktree-session helper must be a symlink"
[[ "${skill_link:A}" == "$skill_source" ]] \
  || fail "orchestration skill must resolve to the codex-config package"
[[ "${helper_link:A}" == "$helper_source" ]] \
  || fail "worktree-session helper must resolve to the codex-config package"
[[ -d "$scripts_target" && ! -L "$scripts_target" ]] \
  || fail "orchestration scripts must remain a real directory"

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
