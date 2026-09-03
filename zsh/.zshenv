. "$HOME/.cargo/env"

# Keep installer-managed ctx upgrades opt-in in every zsh process.
unset CTX_UPGRADE_OFF CTX_DISABLE_AUTO_UPGRADE
export CTX_UPGRADE_AUTO=off

# Keep ctx lexical-only until semantic search proves incremental value.
export CTX_SEARCH_SEMANTIC=false

# asdf initialization (must be in zshenv for non-interactive shells like Mason)
export ASDF_DIR="/opt/homebrew/opt/asdf/libexec"
if [ -f "${ASDF_DIR}/asdf.sh" ]; then
  . "${ASDF_DIR}/asdf.sh"
fi
