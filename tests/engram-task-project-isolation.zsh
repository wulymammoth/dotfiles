#!/usr/bin/env zsh

emulate -LR zsh
setopt errexit nounset pipefail
unsetopt bg_nice
umask 077

test_root="$(mktemp -d "${TMPDIR:-/tmp}/engram-isolation-test.XXXXXX")"
trap 'rm -rf -- "$test_root"' EXIT
data_dir="$test_root/data"
mkdir -p "$data_dir"

fail() {
  print -u2 -- "FAIL: $*"
  exit 1
}

assert_contains() {
  local haystack="$1" needle="$2" label="$3"
  [[ "$haystack" == *"$needle"* ]] \
    || fail "$label is missing '$needle': $haystack"
}

assert_not_contains() {
  local haystack="$1" needle="$2" label="$3"
  [[ "$haystack" != *"$needle"* ]] \
    || fail "$label unexpectedly contains '$needle': $haystack"
}

tool_text() {
  local responses="$1" wanted_id="$2" line response_id decoded
  while IFS= read -r line; do
    response_id="$(print -rn -- "$line" | \
      /usr/bin/plutil -extract id raw -o - - 2>/dev/null)" || continue
    [[ "$response_id" == "$wanted_id" ]] || continue
    decoded="$(print -rn -- "$line" | \
      /usr/bin/plutil -extract result.content.0.text raw -o - - 2>/dev/null)" \
      || fail "response $wanted_id has no decoded result.content[0].text: $line"
    print -r -- "$decoded"
    return 0
  done <"$responses"
  fail "missing MCP response id $wanted_id in $responses"
}

run_mcp_stream() {
  local requests="$1" responses="$2" stderr_file="$3"
  local environment_project="$4" cli_project="${5:-}"
  local request_fifo="$test_root/request.fifo"
  local response_fifo="$test_root/response.fifo"
  rm -f -- "$request_fifo" "$response_fifo"
  mkfifo "$request_fifo" "$response_fifo"

  local request_fd response_fd
  exec {request_fd}<>"$request_fifo"
  exec {response_fd}<>"$response_fifo"

  local -a mcp_command=(engram mcp)
  [[ -z "$cli_project" ]] || mcp_command+=(--project "$cli_project")
  mcp_command+=(--tools=mem_current_project,mem_save,mem_search)
  (
    exec {request_fd}>&-
    exec {response_fd}>&-
    ENGRAM_DATA_DIR="$data_dir" ENGRAM_PROJECT="$environment_project" \
      "${mcp_command[@]}" <"$request_fifo" >"$response_fifo" \
      2>"$stderr_file"
  ) &
  local mcp_pid=$!

  : >"$responses"
  local request request_id response response_id
  while IFS= read -r request; do
    print -r -u "$request_fd" -- "$request"
    if request_id="$(print -rn -- "$request" | \
      /usr/bin/plutil -extract id raw -o - - 2>/dev/null)"; then
      while true; do
        if ! IFS= read -r -t 10 -u "$response_fd" response; then
          kill "$mcp_pid" 2>/dev/null || true
          fail "timed out waiting for MCP response $request_id: $(<"$stderr_file")"
        fi
        print -r -- "$response" >>"$responses"
        if response_id="$(print -rn -- "$response" | \
          /usr/bin/plutil -extract id raw -o - - 2>/dev/null)"; then
          [[ "$response_id" == "$request_id" ]] \
            || fail "MCP response ID mismatch: expected $request_id, actual $response_id"
          break
        fi
      done
    fi
  done <"$requests"

  exec {request_fd}>&-
  wait "$mcp_pid" || fail "MCP stream failed: $(<"$stderr_file")"
  exec {response_fd}>&-
  rm -f -- "$request_fifo" "$response_fifo"
}

command -v engram >/dev/null 2>&1 || fail "engram is not installed"
[[ -x /usr/bin/plutil ]] || fail "/usr/bin/plutil is unavailable"

task_a_requests="$test_root/task-a.requests"
task_a_responses="$test_root/task-a.responses"
task_a_stderr="$test_root/task-a.stderr"
cat >"$task_a_requests" <<'JSON'
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"parallel-isolation-test","version":"1"}}}
{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}
{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"mem_current_project","arguments":{}}}
{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"mem_save","arguments":{"title":"isolation-marker-a","type":"discovery","scope":"project","capture_prompt":false,"content":"**What**: marker-only-in-task-a\n**Why**: isolated regression\n**Where**: disposable Engram data"}}}
{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"mem_search","arguments":{"query":"marker-only-in-task-a","limit":5}}}
JSON

run_mcp_stream "$task_a_requests" "$task_a_responses" "$task_a_stderr" \
  parallel-probe-task-a

task_a_project="$(tool_text "$task_a_responses" 2)"
task_a_save="$(tool_text "$task_a_responses" 3)"
task_a_search="$(tool_text "$task_a_responses" 4)"
assert_contains "$task_a_project" "parallel-probe-task-a" \
  "task A current project"
assert_contains "$task_a_save" "Memory saved" "task A save"
assert_contains "$task_a_search" "marker-only-in-task-a" \
  "task A default search"
assert_contains "$task_a_search" "isolation-marker-a" \
  "task A saved observation"

task_b_requests="$test_root/task-b.requests"
task_b_responses="$test_root/task-b.responses"
task_b_stderr="$test_root/task-b.stderr"
cat >"$task_b_requests" <<'JSON'
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"parallel-isolation-test","version":"1"}}}
{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}
{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"mem_current_project","arguments":{}}}
{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"mem_search","arguments":{"query":"marker-only-in-task-a","limit":5}}}
JSON

run_mcp_stream "$task_b_requests" "$task_b_responses" "$task_b_stderr" \
  parallel-probe-task-a parallel-probe-task-b

task_b_project="$(tool_text "$task_b_responses" 2)"
task_b_search="$(tool_text "$task_b_responses" 3)"
assert_contains "$task_b_project" "parallel-probe-task-b" \
  "task B current project"
assert_not_contains "$task_b_project" "parallel-probe-task-a" \
  "task B project override"
assert_contains "$task_b_search" "No memories found" \
  "task B empty default search"
assert_not_contains "$task_b_search" "isolation-marker-a" \
  "task B default search result"

print -- "PASS: Engram process-level task projects are isolated"
