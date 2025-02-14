# Use Emacs keybindings
bindkey -e

# Homebrew
HOMEBREW_PREFIX="/opt/homebrew"
HOMEBREW_SITE_FUNCTIONS="$HOMEBREW_PREFIX/share/zsh/site-functions"
eval "$(${HOMEBREW_PREFIX}/bin/brew shellenv)"

# Starship prompt
eval "$(starship init zsh)"

# Editor
export EDITOR="nvim"

# Define PATH segments
ASDF_SHIMS="${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
LOCAL_BIN="$HOME/.local/bin"
FZF_SHELL_COMPLETIONS="$(brew --prefix)/opt/fzf/shell/completion.zsh"
FZF_SHELL_KEY_BINDINGS="$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"

# Set PATH in an ordered way
export PATH="$LOCAL_BIN:$ASDF_SHIMS:$PATH"

# Word characters
export WORDCHARS='*?_[]~=&;!#$%^(){}<>'

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f "$FZF_SHELL_COMPLETIONS" ] && source "$FZF_SHELL_COMPLETIONS"
[ -f "$FZF_SHELL_KEY_BINDINGS" ] && source "$FZF_SHELL_KEY_BINDINGS"

# Define fpath segments
ASDF_COMPLETIONS="${ASDF_DATA_DIR:-$HOME/.asdf}/completions"

# Append custom completion paths to fpath
fpath=(
  "$ASDF_COMPLETIONS"
  "$HOMEBREW_SITE_FUNCTIONS"
  $fpath
)

# Initialize ZSH completions
autoload -Uz compinit && compinit
