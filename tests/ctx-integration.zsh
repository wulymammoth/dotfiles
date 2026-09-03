#!/usr/bin/env zsh

emulate -LR zsh
setopt errexit nounset pipefail

repo_root="${0:A:h:h}"

fail() {
  print -u2 -- "FAIL: $*"
  exit 1
}

upgrade_guard_files="$(rg -l '^export CTX_UPGRADE_AUTO=off$' \
  "$repo_root/zsh/.zshenv" "$repo_root/zsh/.exports" || true)"
[[ "$upgrade_guard_files" == "$repo_root/zsh/.zshenv" ]] \
  || fail "CTX_UPGRADE_AUTO must be defined only in zsh/.zshenv"

semantic_guard_files="$(rg -l '^export CTX_SEARCH_SEMANTIC=false$' \
  "$repo_root/zsh/.zshenv" "$repo_root/zsh/.exports" || true)"
[[ "$semantic_guard_files" == "$repo_root/zsh/.zshenv" ]] \
  || fail "CTX_SEARCH_SEMANTIC must be defined only in zsh/.zshenv"

! rg -q '^export (CTX_UPGRADE_OFF|CTX_DISABLE_AUTO_UPGRADE)=' \
  "$repo_root/zsh/.zshenv" "$repo_root/zsh/.exports" \
  || fail "deprecated ctx upgrade aliases must be removed"

legacy_unset_files="$(rg -l '^unset CTX_UPGRADE_OFF CTX_DISABLE_AUTO_UPGRADE$' \
  "$repo_root/zsh/.zshenv" "$repo_root/zsh/.exports" || true)"
[[ "$legacy_unset_files" == "$repo_root/zsh/.zshenv" ]] \
  || fail "zsh/.zshenv must clear inherited deprecated ctx upgrade aliases"

! rg -q '^opencode/\.config/opencode/skills/(ctx|ctx-agent-history-search)/$' \
  "$repo_root/.gitignore" \
  || fail "installer-managed OpenCode ctx skills must live outside the repository"

for generated_skill_dir in \
  "$repo_root/opencode/.config/opencode/skills/ctx" \
  "$repo_root/opencode/.config/opencode/skills/ctx-agent-history-search"; do
  [[ ! -e "$generated_skill_dir" ]] \
    || fail "installer-managed OpenCode ctx skill leaked into the repository: $generated_skill_dir"
done

rg -q '^stow --no-folding opencode$' "$repo_root/opencode/README.md" \
  || fail "OpenCode activation must use Stow without tree folding"

tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/ctx-opencode-stow.XXXXXX")"
trap 'rm -rf "$tmp_root"' EXIT
mkdir -p "$tmp_root/home/.config/opencode"
print -r -- '{}' > "$tmp_root/home/.config/opencode/package.json"
stow --no-folding -d "$repo_root" -t "$tmp_root/home" opencode

skills_root="$tmp_root/home/.config/opencode/skills"
[[ -d "$skills_root" && ! -L "$skills_root" ]] \
  || fail "OpenCode skills root must remain a real directory for managed skills"
[[ -f "$skills_root/supabase-postgres-best-practices/SKILL.md" ]] \
  || fail "tracked OpenCode skills must remain visible after no-folding activation"

mkdir "$skills_root/ctx"
print -r -- 'managed locally' > "$skills_root/ctx/SKILL.md"
[[ ! -e "$repo_root/opencode/.config/opencode/skills/ctx" ]] \
  || fail "a managed OpenCode skill must not write through into the repository"

[[ ! -e "$repo_root/ctx" ]] \
  || fail "ctx v1 config must remain a private regular file outside Stow"

apply_recipe="$(make -s -n -C "$repo_root" stow-apply)"
[[ "$apply_recipe" == *'stow --no-folding -v codex-config'* ]] \
  || fail "codex-config must retain separate no-folding Stow activation"
[[ "$apply_recipe" != *'stow --no-folding -v ctx'* ]] \
  || fail "ctx must not be activated through Stow"

package_list=$'\n'"$(make -s -C "$repo_root" stow-list)"$'\n'
[[ "$package_list" != *$'\nctx\n'* ]] \
  || fail "ctx must not appear in the Stow package list"

print -- "PASS: ctx v1 non-Stow integration policy"
