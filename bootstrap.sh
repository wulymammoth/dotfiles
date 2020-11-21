#!/usr/local/bin/bash
# NOTE: this only works with Bash 4.0+ (instsall via Homebrew)

: '
RESOURCES:
1. http://robertmuth.blogspot.com/2012/08/better-bash-scripting-in-15-minutes.html
2. http://www.tldp.org/LDP/abs/html/moreadv.html
3. https://devhints.io/bash
'

# This will take care of two very common errors:
# Referencing undefined variables (that default to "")
# Ignoring failing commands
set -o nounset
set -o errexit

echo -e '\n--- SSH ---'
if [ ! -f ~/.ssh/id_rsa ]; then
  echo 'setting up SSH key';
  ssh-keygen -t rsa -b 4096 -C "$(scutil --get ComputerName)"
  ssh-add -K ~/.ssh/id_rsa
else
  echo 'SSH key already exists';
fi

echo -e '\n--- Homebrew ---'
if ! command -v brew; then
  echo 'installing Homebrew';
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)";
  # brew install "mas-cli/tap/mas";
else
  echo 'Homebrew already installed';
fi

echo -e '\n--- linking dotfiles ---';
dotfiles=(
  aliases
  bash_profile
  bashrc
  dir_colors
  exports
  functions
  gitconfig
  gitignore_global
  ripgreprc
  tmux.conf
  tool-versions
  utilities
)
for dotfile in "${dotfiles[@]}"; do
  if [ -r "$dotfile" ] && [ -f "$dotfile" ]; then # readable and is file (options)
    echo "linking ${dotfile}";
    ln -s "$dotfile" "$HOME/.${dotfile}".;
  else
    echo "${dotfile} already linked"
  fi
done

echo -e '\n--- checking for vim-plug ---';
if [[ ! -e ~/.local/share/nvim/site/autoload/plug.vim ]]; then
  echo 'installing vim-plug';
  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim \
    --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
  echo 'vim-plug already installed';
fi

echo -e '\n--- checking Neovim config ---'
if [[ ! -d ~/.config/nvim ]]; then # directory exists
  echo 'linking Neovim config';
  mkdir -p ~/.config/nvim && ln -s ~/.dotfiles/neovim/init.vim ~/.config/nvim/init.vim
else
  echo 'Neovim config already linked';
fi

echo -e '\n--- BOOTSTRAPPING FINISHED ---'
