shopt -s histappend # append to history on exit

# activate NORD theme (directory colors for utilities such as ls, tree, fd)
eval $(dircolors ~/.dir_colors)

# asdf-vm
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

# zoxide
eval "$(zoxide init bash)"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
