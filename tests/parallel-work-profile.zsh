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

run_codex() {
  HOME="$home" CODEX_HOME="$codex_home" \
    XDG_CONFIG_HOME="$xdg_config" XDG_CACHE_HOME="$xdg_cache" \
    XDG_DATA_HOME="$xdg_data" XDG_STATE_HOME="$xdg_state" \
    codex -p parallel-work "$@"
}

command -v codex >/dev/null 2>&1 || fail "codex is not installed"
[[ -f "$profile_source" ]] || fail "tracked parallel-work profile is missing"
[[ "$(<"$profile_source")" == $'[plugins."engram@engram"]\nenabled = false' ]] \
  || fail "parallel-work overlay must contain only the Engram plugin override"

cat >"$codex_home/config.toml" <<'TOML'
[mcp_servers.engram]
command = "/usr/bin/true"
TOML

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

mcp_json="$test_root/mcp.json"
run_codex mcp list --json >"$mcp_json"
[[ "$(/usr/bin/plutil -extract 0.name raw -o - "$mcp_json")" == "engram" ]] \
  || fail "synthetic base Engram MCP entry was not retained"
[[ "$(/usr/bin/plutil -extract 0.enabled raw -o - "$mcp_json")" == "true" ]] \
  || fail "synthetic base Engram MCP entry is not enabled"
[[ "$(/usr/bin/plutil -extract 0.transport.command raw -o - "$mcp_json")" == \
  "/usr/bin/true" ]] || fail "synthetic MCP command changed under the profile"

if run_codex debug prompt-input --help >/dev/null 2>&1; then
  prompt_json="$test_root/prompt-input.json"
  (cd "$workspace" && run_codex debug prompt-input "retention probe") \
    >"$prompt_json"
  rg --fixed-strings --quiet "$instruction_marker" "$prompt_json" \
    || fail "synthetic base instruction file was not retained"
fi

print -- "PASS: parallel-work profile syntax and base MCP retention"
print -- "PENDING_CANARY: no safe offline Codex surface proved hook suppression plus policy and Superpowers loading"
