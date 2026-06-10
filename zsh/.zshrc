# Keep this file focused on interactive shell startup. Login and
# non-interactive environment setup belongs in .zprofile/.zshenv.
[[ -o interactive ]] || return

# Disable extended history to not screw up my command history
unsetopt EXTENDED_HISTORY

# Simplified XDG setup - only what's needed for zsh
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Raise the soft fd limit for long-lived interactive tools like Codex.
current_nofile_limit=$(ulimit -n 2>/dev/null)
if [[ "$current_nofile_limit" == <-> ]] && (( current_nofile_limit < 10240 )); then
    ulimit -n 10240 2>/dev/null || true
fi

# Create only the directories we actually use
mkdir -p "$XDG_CACHE_HOME/zsh"

# Use Emacs keybindings
bindkey -e

# Completion paths must be configured before .completions runs compinit.
[[ -d "$HOME/.docker/completions" ]] && fpath=("$HOME/.docker/completions" $fpath)

# Source core configurations in dependency order.
for config in {exports,exports_local,options,completions,utilities,aliases,functions}; do
    config_path="$HOME/.${config}"
    [[ -r "$config_path" ]] && source "$config_path"

    work_config_path="$HOME/.${config}_work"
    [[ -r "$work_config_path" ]] && source "$work_config_path"
done

# ctrl-x + ctrl-e to edit the command line in the default editor
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# Add $HOME/.local/bin to $PATH for user-installed tools.
export PATH="$HOME/.local/bin:$PATH"
