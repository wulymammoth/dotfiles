# dotfiles | dot-dot-dot

![](./shellshot.png)

## why are my directories structured the way that they are?

I'm using [GNU Stow](https://www.gnu.org/software/stow/) to symlink my dotfiles and each directory that you see here mirrors that of my `$HOME` directory -- some application and utility configurations typically go under `$XDG_CONFIG` (`~/.config`).

## some of my favorite tools and utilities:

- [Alacritty](https://github.com/alacritty/alacritty) : terminal
- [Neovim](https://github.com/neovim/neovim) : text editor
- [bat](https://github.com/sharkdp/bat) : cat clone with syntax highlighting and Git integration
- [exa](https://github.com/ogham/exa) : a modern replacement for ls
- [fd](https://github.com/sharkdp/fd) : simple, fast and user-friendly alternative to find
- [fzf](https://github.com/junegunn/fzf) : command-line fuzzy finder and file system navigation
- [htop](https://github.com/htop-dev/htop) : interactive process viewer
- [ripgrep](https://github.com/BurntSushi/ripgrep) : command-line search utility (faster than grep and ag)
- [tmux](https://github.com/tmux/tmux) : terminal multiplexer for project/session management and restore, because re-opening projects is 😭
- [zoxide](https://github.com/ajeetdsouza/zoxide) : a faster way to navigate the filesystem
- [tree](http://mama.indstate.edu/users/ice/tree) : Display directories as trees (with optional color/HTML output)

My other utilities and applications (primarily macOS) can be found in my [Brewfile](./homebrew/Brewfile)

## installation

**Linux**:

- asdf
  `git clone https://github.com/asdf-vm/asdf.git ~/.asdf`

- bat
  `cargo install --locked bat`

- dircolors
  `sudo yum install coreutils`

- exa
  `cargo install exa`

- fd
  `cargo install fd-find`

- git-delta
  `cargo install git-delta`

- starship
  `sh -c "$(curl -fsSL https://starship.rs/install.sh)"`

- vim-plug (nvim)
  ```
  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  ```
