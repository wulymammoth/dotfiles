# Simplified XDG setup - only what's needed for zsh
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Create only the directories we actually use
mkdir -p "$XDG_CACHE_HOME/zsh"

# Use Emacs keybindings
bindkey -e

# Source core configurations in specific order
for config in {exports,options,completions,utilities,aliases,functions}; do
    config_path="$HOME/.${config}"
    if [[ -r "$config_path" ]]; then
        source "$config_path"
    else
        echo "Could not read $config_path"
    fi
done

# After the source loop
if ! (( $+commands[starship] )); then
    echo "starship not found in PATH"
    echo "PATH: $PATH"
fi
