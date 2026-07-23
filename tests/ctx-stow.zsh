#!/usr/bin/env zsh

emulate -LR zsh
setopt errexit nounset pipefail

repo_root="${0:A:h:h}"
test_root="$(mktemp -d /tmp/ctx-stow-test.XXXXXX)"
trap 'rm -rf "$test_root"' EXIT

fail() {
  print -u2 -- "FAIL: $*"
  exit 1
}

mkdir -p "$test_root/.ctx"
print -r -- "sentinel database" >"$test_root/.ctx/work.sqlite"

guard_files="$(rg -l '^export CTX_UPGRADE_OFF=1$' \
  "$repo_root/zsh/.zshenv" "$repo_root/zsh/.exports")"
[[ "$guard_files" == "$repo_root/zsh/.zshenv" ]] \
  || fail "CTX_UPGRADE_OFF must be defined only in zsh/.zshenv"
! rg -q '^export CTX_DISABLE_AUTO_UPGRADE=' \
  "$repo_root/zsh/.zshenv" "$repo_root/zsh/.exports" \
  || fail "duplicate ctx upgrade alias must be removed"

generated_skill="opencode/.config/opencode/skills/ctx-agent-history-search/SKILL.md"
git -C "$repo_root" check-ignore -q -- "$generated_skill" \
  || fail "installer-managed OpenCode ctx skill must be ignored"

[[ -f "$repo_root/ctx/.ctx/config.toml" ]] \
  || fail "ctx package config is missing"

stow --no-folding \
  --dir "$repo_root" \
  --target "$test_root" \
  ctx

[[ -d "$test_root/.ctx" && ! -L "$test_root/.ctx" ]] \
  || fail ".ctx must remain a real directory"
[[ -L "$test_root/.ctx/config.toml" ]] \
  || fail "config.toml must be a symlink"
config_link="$test_root/.ctx/config.toml"
[[ "${config_link:A}" == "$repo_root/ctx/.ctx/config.toml" ]] \
  || fail "config.toml must resolve to the ctx package"
[[ "$(<"$test_root/.ctx/work.sqlite")" == "sentinel database" ]] \
  || fail "existing ctx state changed"

typeset -a package_entries
package_entries=("$repo_root/ctx/.ctx"/*(DN))
(( ${#package_entries[@]} == 1 )) \
  || fail "ctx package must contain only config.toml"
[[ "${package_entries[1]:t}" == "config.toml" ]] \
  || fail "unexpected ctx package entry: ${package_entries[1]}"

apply_recipe="$(make -s -n -C "$repo_root" stow-apply)"
[[ "$apply_recipe" == *'stow --no-folding -v ctx'* ]] \
  || fail "ctx must use a separate no-folding Stow command"
[[ "$(make -s -C "$repo_root" stow-list)" == *$'\nctx'* ]] \
  || fail "ctx must appear in the default Stow package list"

print -- "PASS: ctx config-only Stow package"
