# Simplified XDG setup - only what's needed for zsh
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Create only the directories we actually use
mkdir -p "$XDG_CACHE_HOME/zsh"

# Use Emacs keybindings
bindkey -e

# Source core configurations in specific order
for config in {exports,exports_local,options,completions,utilities,aliases,functions}; do
    # Load base config if it exists
    config_path="$HOME/.${config}"
    if [[ -r "$config_path" ]]; then
        source "$config_path"
    fi

    # Load work-specific config if it exists
    work_config_path="$HOME/.${config}_work"
    if [[ -r "$work_config_path" ]]; then
        source "$work_config_path"
    fi
done

# Load zsh-autosuggestions
local autosuggestions_paths=(
    "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
)

# for path in $autosuggestions_paths; do
#     if [[ -f "$path" ]]; then
#         source "$path"
#         break  
#     fi
# done