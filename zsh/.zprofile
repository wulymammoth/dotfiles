# Minimal login env for non-interactive shells (launchd etc.)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR="nvim"
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

# Long-lived apps can retain a launchd SSH-agent socket after macOS replaces
# it. ssh-add exits 2 only when it cannot contact the configured agent; exit 1
# still means the agent is reachable but currently has no identities.
_ssh_add_status=2
if [[ -n "${SSH_AUTH_SOCK:-}" ]]; then
  /usr/bin/ssh-add -l >/dev/null 2>&1
  _ssh_add_status=$?
fi

if [[ "$OSTYPE" == darwin* ]] && (( _ssh_add_status == 2 )); then
  _launchd_ssh_auth_sock="$(
    /bin/launchctl print "gui/${UID}/com.openssh.ssh-agent" 2>/dev/null \
      | /usr/bin/awk '$1 == "SSH_AUTH_SOCK" && $2 == "=>" { print $3; exit }'
  )"

  if [[ -S "$_launchd_ssh_auth_sock" ]]; then
    SSH_AUTH_SOCK="$_launchd_ssh_auth_sock" /usr/bin/ssh-add -l \
      >/dev/null 2>&1
    _ssh_add_status=$?
    if (( _ssh_add_status != 2 )); then
      export SSH_AUTH_SOCK="$_launchd_ssh_auth_sock"
    fi
  fi
fi

if (( _ssh_add_status == 2 )); then
  unset SSH_AUTH_SOCK
fi
unset _launchd_ssh_auth_sock _ssh_add_status

# Keep non-interactive shells clean
if [[ $- != *i* ]]; then
  return
fi

# ----- Interactive only below -----

# Path setup
ASDF_SHIMS="${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
LOCAL_BIN="$HOME/.local/bin"
CARGO_BINS=$HOME/.cargo/bin
LLVM_PATH=/usr/local/opt/llvm/bin
OPENSSL_PATH=/usr/local/opt/openssl@3/bin
TREE_SITTER_PATH=/usr/local/opt/tree-sitter/bin
PYTHON_BINS=$HOME/.local/bin

path=(
  $ASDF_SHIMS
  $CARGO_BINS
  $GOPATH/bin
  $LLVM_PATH
  $TREE_SITTER_PATH
  $PYTHON_BINS
  $BREW_PATHS
  $OPENSSL_PATH
  $path
)
typeset -U path

# SSH agent setup
if [[ -z "$SSH_AUTH_SOCK" ]]; then
  eval "$(ssh-agent -t 3600 -s)"
fi

function add_ssh_key() {
  local key_path=$1
  local use_keychain_flag=$2
  if [[ -f "$key_path" ]]; then
    local public_key="${key_path}.pub"
    if [[ -f "$public_key" ]]; then
      local fp=$(ssh-keygen -lf "$public_key" | awk '{print $2}')
      if ! ssh-add -l 2>/dev/null | grep -q "$fp"; then
        ssh-add $use_keychain_flag "$key_path"
      fi
    else
      echo "Warning: Public key file for $key_path not found."
    fi
  fi
}

add_ssh_key ~/.ssh/id_ed25519
add_ssh_key ~/.ssh/id_rsa --apple-use-keychain
