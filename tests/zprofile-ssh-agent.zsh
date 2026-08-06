#!/usr/bin/env zsh

emulate -LR zsh
setopt errexit nounset pipefail

if [[ "$OSTYPE" != darwin* ]]; then
  print -- "SKIP: zprofile SSH-agent recovery is macOS-specific"
  exit 0
fi

repo_root="${0:A:h:h}"
stale_socket="/tmp/dotfiles-stale-ssh-agent.sock"

fail() {
  print -u2 -- "FAIL: $*"
  exit 1
}

PROFILE_UNDER_TEST="$repo_root/zsh/.zprofile" \
STALE_SOCKET="$stale_socket" \
SSH_AUTH_SOCK="$stale_socket" \
  /bin/zsh -dfc '
    source "$PROFILE_UNDER_TEST"

    [[ "${SSH_AUTH_SOCK:-}" != "$STALE_SOCKET" ]] \
      || exit 10

    /usr/bin/ssh-add -l >/dev/null 2>&1
    ssh_add_status=$?
    (( ssh_add_status != 2 ))
  ' || fail "a non-interactive login profile did not replace the stale SSH_AUTH_SOCK with a reachable agent"

print -- "PASS: zprofile recovers a stale macOS SSH-agent socket"
