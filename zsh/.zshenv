. "$HOME/.cargo/env"

# asdf initialization (must be in zshenv for non-interactive shells like Mason)
export ASDF_DIR="/opt/homebrew/opt/asdf/libexec"
if [ -f "${ASDF_DIR}/asdf.sh" ]; then
  . "${ASDF_DIR}/asdf.sh"
fi
