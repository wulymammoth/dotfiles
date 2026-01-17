# dotfiles | dot-dot-dot

![](./shellshot.png)

## quick setup
- install basics: `bundle install && brew bundle --file=$HOME/dotfiles/homebrew/Brewfile`
- symlink with stow (allow-list so you only link what you use): `cd ~/dotfiles && stow zsh git tmux ghostty wezterm nvim bash starship ssh ripgrep gdircolors`
- preview before linking: `stow -nv <pkg>`; apply with `stow -v <pkg>`
- skip deprecated packages (e.g., `alacritty`) and add new ones only when in active use

## where things land (stow packages)
- `zsh/` → `~/.zshrc`, `~/.zprofile`, `~/.zshenv`, and companion dotfiles
- `bash/` → `~/.bashrc`, `~/.bash_profile`, and helper dotfiles
- `nvim/` → `~/.config/nvim` (LazyVim + blink.cmp, Mason v2)
- `tmux/` → `~/.tmux.conf` and plugins dir
- `wezterm/` → `~/.config/wezterm/wezterm.lua`
- `ghostty/` → `~/.config/ghostty/config`
- `git/` → git helpers under `~/.config/git/`
- `ssh/` → `~/.ssh/config`

## tooling (macOS)

- [asdf](https://asdf-vm.com/) : Extendable version manager with support for Ruby, Node.js, Erlang & more
- [bat](https://github.com/sharkdp/bat) : cat clone with syntax highlighting and git integration
- [direnv](https://direnv.net/) : Load/unload environment variables based on $PWD
- [eza](https://github.com/eza-community/eza) : Modern, maintained replacement for ls
- [fd](https://github.com/sharkdp/fd) : simple, fast and user-friendly alternative to find
- [fzf](https://github.com/junegunn/fzf) : command-line fuzzy finder and file system navigation
- [gh](https://github.com/cli/cli) : Github command-line tool
- [htop](https://github.com/htop-dev/htop) : interactive process viewer
- [jq](https://stedolan.github.io/jq/) : lightweight and flexible command-line json processor
- [neovim](https://github.com/neovim/neovim) : text editor
- [ripgrep](https://github.com/burntsushi/ripgrep) : command-line search utility (faster than grep and ag)
- [starship](https://starship.rs) : cross-shell prompt for astronauts
- [tldr](https://tldr.sh/) : Simplified and community-driven man pages
- [tmux](https://github.com/tmux/tmux) : terminal multiplexer
- [tree](http://mama.indstate.edu/users/ice/tree) : display directories as trees (with optional color/html output)
- [wezterm](https://wezfurlong.org/wezterm/) : A GPU-accelerated cross-platform terminal emulator and multiplexer written by @wez and implemented in Rust
- [zoxide](https://github.com/ajeetdsouza/zoxide) : a faster way to navigate the filesystem

other utilities and applications can be found in my [Brewfile](./homebrew/Brewfile)

- installation: `bundle install && brew bundle --file=$HOME/dotfiles/homebrew/Brewfile`
- help: `brew bundle --help`
