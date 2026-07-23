. "$HOME/.cargo/env"

# Keep installer-managed ctx upgrades opt-in in every zsh process.
export CTX_UPGRADE_OFF=1

# asdf initialization (must be in zshenv for non-interactive shells like Mason)
export ASDF_DIR="/opt/homebrew/opt/asdf/libexec"
if [ -f "${ASDF_DIR}/asdf.sh" ]; then
  . "${ASDF_DIR}/asdf.sh"
fi
