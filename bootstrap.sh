#!/usr/local/bin/bash
# NOTE: this only works with Bash 4.0+

# This will take care of two very common errors:
# Referencing undefined variables (that default to "")
# Ignoring failing commands
set -o nounset
set -o errexit

echo -e '\n--- SSH ---'
if [ ! -f ~/.ssh/id_ed25519 ]; then
  echo 'setting up SSH key';
  ssh-keygen -t ed25519 -C "$(scutil --get ComputerName)"
  # WARNING: The -K and -A flags are deprecated and have been replaced
  # by the --apple-use-keychain and --apple-load-keychain
  # flags, respectively.  To suppress this warning, set the
  # environment variable APPLE_SSH_ADD_BEHAVIOR as described in
  # the ssh-add(1) manual page.
  ssh-add ~/.ssh/id_ed25519
else
  echo 'SSH key already exists';
fi

echo -e '\n--- Homebrew ---'
if ! command -v brew; then
  echo 'installing Homebrew';
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)";
else
  echo 'Homebrew already installed';
fi

echo -e '\n--- BOOTSTRAPPING FINISHED ---'
