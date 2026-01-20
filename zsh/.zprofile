# Minimal login env for non-interactive shells (launchd etc.)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR="nvim"
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

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
