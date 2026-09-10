#!/usr/bin/env zsh

emulate -LR zsh
setopt errexit nounset pipefail
umask 077

repo_root="${0:A:h:h}"
profile_source="$repo_root/codex-config/.codex/parallel-work.config.toml"
test_root="$(mktemp -d "${TMPDIR:-/tmp}/parallel-work-profile-test.XXXXXX")"
trap 'rm -rf -- "$test_root"' EXIT

home="$test_root/home"
codex_home="$test_root/codex-home"
workspace="$test_root/workspace"
xdg_config="$test_root/xdg-config"
xdg_cache="$test_root/xdg-cache"
xdg_data="$test_root/xdg-data"
xdg_state="$test_root/xdg-state"
mkdir -p "$home" "$codex_home" "$workspace" \
  "$xdg_config" "$xdg_cache" "$xdg_data" "$xdg_state"

fail() {
  print -u2 -- "FAIL: $*"
  exit 1
}

command -v codex >/dev/null 2>&1 || fail "codex is not installed"
codex_bin="$(command -v codex)"

run_isolated() {
  env -i \
    HOME="$home" CODEX_HOME="$codex_home" \
    XDG_CONFIG_HOME="$xdg_config" XDG_CACHE_HOME="$xdg_cache" \
    XDG_DATA_HOME="$xdg_data" XDG_STATE_HOME="$xdg_state" \
    TMPDIR="${TMPDIR:-/tmp}" PATH="$PATH" LANG="${LANG:-C.UTF-8}" \
    COMMAND_MODE="${COMMAND_MODE:-unix2003}" USER="${USER:-fixture-user}" \
    LOGNAME="${LOGNAME:-fixture-user}" \
    __CF_USER_TEXT_ENCODING="${__CF_USER_TEXT_ENCODING:-0x0:0x0:0x0}" \
    "$@"
}

run_codex() {
  run_isolated "$codex_bin" -p parallel-work "$@"
}
[[ -f "$profile_source" ]] || fail "tracked parallel-work profile is missing"
[[ "$(<"$profile_source")" == $'service_tier = "default"\n[plugins."engram@engram"]\nenabled = false\n\n[mcp_servers.engram]\nenabled = true' ]] \
  || fail "parallel-work overlay must inherit model and reasoning defaults, preserve the service tier, disable the Engram plugin, and retain Engram MCP"

cat >"$codex_home/config.toml" <<'TOML'
model_instructions_file = "__MODEL_INSTRUCTIONS__"
experimental_compact_prompt_file = "__COMPACT_INSTRUCTIONS__"

[plugins."engram@engram"]
enabled = true

[mcp_servers.engram]
command = "/usr/bin/true"
enabled = true

[sandbox_workspace_write]
writable_roots = ["/tmp/profile-unrelated-sentinel"]
TOML

model_instructions="$codex_home/engram-instructions.md"
compact_instructions="$codex_home/engram-compact-prompt.md"
print -r -- "fixture model instructions" >"$model_instructions"
print -r -- "fixture compact instructions" >"$compact_instructions"
sed -i '' \
  -e "s|__MODEL_INSTRUCTIONS__|$model_instructions|" \
  -e "s|__COMPACT_INSTRUCTIONS__|$compact_instructions|" \
  "$codex_home/config.toml"
base_config_before="$(<"$codex_home/config.toml")"

readonly instruction_marker="SYNTHETIC_PARALLEL_BASE_INSTRUCTION_7D91E2"
print -r -- "$instruction_marker" >"$workspace/AGENTS.md"
overlay_path="$codex_home/parallel-work.config.toml"
ln -s "$profile_source" "$overlay_path"
[[ -L "$overlay_path" ]] || fail "named overlay is not a symlink"
[[ "${overlay_path:A}" == "${profile_source:A}" ]] \
  || fail "named overlay does not resolve to the tracked profile"

version_output="$(run_codex --version)"
[[ "$version_output" == codex-cli\ * ]] \
  || fail "parallel-work profile did not parse: $version_output"

policy_output=""
if policy_output="$(run_isolated /usr/bin/python3 -B \
  "$repo_root/scripts/codex-memory-policy.py" --dry-run)"; then
  fail "contaminated base configuration should require reconciliation"
else
  policy_rc=$?
fi
[[ "$policy_rc" == 1 ]] \
  || fail "memory-policy dry-run returned unexpected status: $policy_rc"
[[ "$(print -r -- "$policy_output" | wc -l | tr -d ' ')" == 6 ]] \
  || fail "memory-policy dry-run must report only the config identity and four operations"
for expected_operation in \
  "model_instructions_file=remove" \
  "experimental_compact_prompt_file=remove" \
  "plugins.engram@engram.enabled=set_false" \
  "mcp_servers.engram.enabled=already_true"
do
  print -r -- "$policy_output" | rg --fixed-strings --quiet "$expected_operation" \
    || fail "memory-policy dry-run is missing: $expected_operation"
done
[[ "$(<"$codex_home/config.toml")" == "$base_config_before" ]] \
  || fail "memory-policy dry-run changed the fixture config"

config_version="$(print -r -- "$policy_output" | sed -n 's/^config_version=//p')"
[[ -n "$config_version" ]] || fail "memory-policy dry-run omitted config version"
run_isolated /usr/bin/python3 -B \
  "$repo_root/scripts/codex-memory-policy.py" \
  --apply --expected-version "$config_version" >/dev/null \
  || fail "synthetic native reconciliation failed"
reconciled_config="$(<"$codex_home/config.toml")"
[[ "$reconciled_config" != *"model_instructions_file"* ]] \
  || fail "model instruction override survived synthetic reconciliation"
[[ "$reconciled_config" != *"experimental_compact_prompt_file"* ]] \
  || fail "compact instruction override survived synthetic reconciliation"
[[ "$reconciled_config" == *$'[plugins."engram@engram"]\nenabled = false'* ]] \
  || fail "synthetic reconciliation did not disable the Engram plugin"
[[ "$reconciled_config" == *$'[mcp_servers.engram]\ncommand = "/usr/bin/true"\nenabled = true'* ]] \
  || fail "synthetic reconciliation did not retain the Engram MCP command and enable it"
[[ "$reconciled_config" == *'writable_roots = ["/tmp/profile-unrelated-sentinel"]'* ]] \
  || fail "synthetic reconciliation changed unrelated config"

mcp_json="$test_root/mcp.json"
run_codex mcp list --json >"$mcp_json"
[[ "$(/usr/bin/plutil -extract 0.name raw -o - "$mcp_json")" == "engram" ]] \
  || fail "synthetic base Engram MCP entry was not retained"
[[ "$(/usr/bin/plutil -extract 0.enabled raw -o - "$mcp_json")" == "true" ]] \
  || fail "parallel-work profile did not retain the enabled Engram MCP entry"
[[ "$(/usr/bin/plutil -extract 0.transport.command raw -o - "$mcp_json")" == \
  "/usr/bin/true" ]] || fail "synthetic MCP command changed under the profile"

if run_codex debug prompt-input --help >/dev/null 2>&1; then
  prompt_json="$test_root/prompt-input.json"
  (cd "$workspace" && run_codex debug prompt-input "retention probe") \
    >"$prompt_json"
  rg --fixed-strings --quiet "$instruction_marker" "$prompt_json" \
    || fail "synthetic base instruction file was not retained"
fi

[[ "$(<"$codex_home/config.toml")" == "$reconciled_config" ]] \
  || fail "parallel-work profile checks changed the reconciled fixture config"

print -- "PASS: parallel-work profile disables Engram hooks while retaining MCP availability"
print -- "PENDING_CANARY: no safe offline Codex surface proved hook suppression plus policy and Superpowers loading"
