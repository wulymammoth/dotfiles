# Use Emacs keybindings
bindkey -e

# Homebrew
HOMEBREW_PREFIX="/opt/homebrew"
eval "$(${HOMEBREW_PREFIX}/bin/brew shellenv)"

# Starship prompt
eval "$(starship init zsh)"

# Editor
export EDITOR="nvim"

# Define PATH segments
ASDF_SHIMS="${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
FZF_SHELL_COMPLETIONS="$(brew --prefix)/opt/fzf/shell/completion.zsh"
FZF_SHELL_KEY_BINDINGS="$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"

# Set PATH in an ordered way
export PATH="$ASDF_SHIMS:$PATH"

# Word characters
export WORDCHARS='*?_[]~=&;!#$%^(){}<>'

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f "$FZF_SHELL_COMPLETIONS" ] && source "$FZF_SHELL_COMPLETIONS"
[ -f "$FZF_SHELL_KEY_BINDINGS" ] && source "$FZF_SHELL_KEY_BINDINGS"

# Append ASDF completions to fpath
fpath=("${ASDF_DATA_DIR:-$HOME/.asdf}/completions" $fpath)

# Initialize ZSH completions
autoload -Uz compinit && compinit
