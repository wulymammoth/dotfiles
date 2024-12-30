# Source other configuration files
for file in ~/.{exports,exports_local,bashrc,profile,aliases,aliases_work,functions,functions_work,utilities}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done

# Start the SSH agent if not running
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)"
fi

# Function to add an SSH key if it exists
add_ssh_key() {
  local key_path=$1
  local use_keychain_flag=$2

  if [ -f "$key_path" ]; then
    local public_key="${key_path}.pub"
    if [ -f "$public_key" ]; then
      local public_key_fingerprint
      public_key_fingerprint=$(ssh-keygen -lf "$public_key" | awk '{print $2}')

      # Check if the key is already loaded
      if ! ssh-add -l 2>/dev/null | grep -q "$public_key_fingerprint"; then
        ssh-add $use_keychain_flag "$key_path"
      fi
    else
      echo "Warning: Public key file for $key_path not found."
    fi
  fi
}

# Try adding keys in order of preference
add_ssh_key ~/.ssh/id_ed25519
add_ssh_key ~/.ssh/id_rsa --apple-use-keychain
