for file in ~/.{exports,exports_local,bashrc,profile,aliases,aliases_work,functions,functions_work,utilities}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done

# start the ssh agent if not running
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)"
fi

# get the public key's fingerprint
PUBLIC_KEY_FINGERPRINT=$(ssh-keygen -lf ~/.ssh/id_ed25519.pub | awk '{print $2}')

# Check if the key is already loaded
if ! ssh-add -l 2>/dev/null | grep -q "$PUBLIC_KEY_FINGERPRINT"; then
  ssh-add ~/.ssh/id_ed25519
fi
