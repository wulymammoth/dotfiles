bindkey -e # use emacs keybinds 

eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(starship init zsh)"

export EDITOR="nvim"
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
export WORDCHARS='*?_[]~=&;!#$%^(){}<>'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f $(brew --prefix)/opt/fzf/shell/completion.zsh ] && source $(brew --prefix)/opt/fzf/shell/completion.zsh # Apple Silicon
[ -f $(brew --prefix)/opt/fzf/shell/key-bindings.zsh ] && source $(brew --prefix)/opt/fzf/shell/key-bindings.zsh # Apple Silicon

# append completions to fpath
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
