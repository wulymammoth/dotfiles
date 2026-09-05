#!/usr/bin/env zsh
emulate -LR zsh
setopt errexit nounset pipefail

repo_root="${0:A:h:h}"
test_root="$(mktemp -d /tmp/maestro-integration.XXXXXX)"
trap 'rm -rf "$test_root"' EXIT
fail() { print -u2 -- "FAIL: $*"; exit 1; }

# Doctor/test targets are inspection only; activation is a separate target.
doctor_recipe="$(make -s -n -C "$repo_root" maestro-doctor)"
[[ "$doctor_recipe" == *'maestro-toolchain doctor --ios'* ]] || fail "missing iOS doctor command"
[[ "$doctor_recipe" != *' install'* && "$doctor_recipe" != *'stow '* ]] || fail "doctor must not install or activate"
activate_recipe="$(make -s -n -C "$repo_root" maestro-activate)"
[[ "$activate_recipe" == *'--no-folding'*'maestro codex-config'* ]] || fail "activation must preserve mutable directories"

mkdir -p "$test_root/home/.local/bin" "$test_root/home/.local/share" "$test_root/home/.codex/skills" "$test_root/home/.cargo"
print -r -- 'sentinel cli' > "$test_root/home/.local/bin/unrelated"
print -r -- 'sentinel state' > "$test_root/home/.codex/state.json"
touch "$test_root/home/.cargo/env"
stow --no-folding -d "$repo_root" -t "$test_root/home" maestro codex-config
stow --no-folding -d "$repo_root" -t "$test_root/home" maestro codex-config

for directory in .local .local/bin .local/share .codex .codex/skills; do
  [[ -d "$test_root/home/$directory" && ! -L "$test_root/home/$directory" ]] || fail "directory folded: $directory"
done
for command_name in maestro maestro-toolchain; do
  [[ -L "$test_root/home/.local/bin/$command_name" && -x "$test_root/home/.local/bin/$command_name" ]] || fail "missing executable link: $command_name"
done
[[ -L "$test_root/home/.codex/skills/maestro-mobile-testing/SKILL.md" ]] || fail "Maestro skill must be discoverable as a leaf link"
[[ "$(<"$test_root/home/.local/bin/unrelated")" == 'sentinel cli' ]] || fail "unrelated executable changed"
[[ "$(<"$test_root/home/.codex/state.json")" == 'sentinel state' ]] || fail "Codex state changed"
[[ ! -e "$test_root/home/.local/share/maestro-cli" ]] || fail "activation must not install binaries"

ln -s "$repo_root/zsh/.zshenv" "$test_root/home/.zshenv"
discovered="$(env -i HOME="$test_root/home" PATH=/usr/bin:/bin /bin/zsh -c 'command -v maestro; command -v maestro-toolchain')"
[[ "$discovered" == "$test_root/home/.local/bin/maestro"$'\n'"$test_root/home/.local/bin/maestro-toolchain" ]] || fail "fresh noninteractive shell cannot discover shared commands: $discovered"
env -i HOME="$test_root/home" PATH=/usr/bin:/bin /bin/zsh -c '
  source "$HOME/.zshenv"
  matched_count=0
  for entry in "${(@s/:/)PATH}"; do
    [[ "$entry" != "$HOME/.local/bin" ]] || (( matched_count += 1 ))
  done
  [[ "$matched_count" == 1 ]]
' || fail "noninteractive PATH must be idempotent"

mkdir -p "$test_root/conflict/.local/bin"
print -r -- 'local maestro owner' > "$test_root/conflict/.local/bin/maestro"
if stow --no-folding -d "$repo_root" -t "$test_root/conflict" maestro > "$test_root/conflict.log" 2>&1; then
  fail "activation must reject a conflicting local maestro"
fi
[[ "$(<"$test_root/conflict/.local/bin/maestro")" == 'local maestro owner' ]] || fail "conflicting file overwritten"
print -- "PASS: Maestro no-folding activation, conflict preservation, and noninteractive discovery"
