. "$HOME/.cargo/env"

# Shared user CLIs must also be visible in fresh noninteractive agent shells.
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

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
