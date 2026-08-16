# dotfiles | dot-dot-dot

![](./shellshot.png)

Personal macOS dotfiles managed with GNU Stow and Homebrew. Most configs live in self-contained package directories so you can link only the pieces you actively use.

## Setup

1. Clone the repo to `~/dotfiles`.
2. Optionally run [`bootstrap.sh`](./bootstrap.sh) to create an SSH key and install Homebrew.
3. Install packages from [`homebrew/Brewfile`](./homebrew/Brewfile):

   ```sh
   brew bundle --file="$HOME/dotfiles/homebrew/Brewfile"
   ```

4. Preview the default Stow allow-list:

   ```sh
   cd ~/dotfiles
   make stow-preview
   ```

5. Apply those links when the preview looks correct:

   ```sh
   make stow-apply
   ```

If you want tighter control than the default allow-list in [`Makefile`](./Makefile), use Stow directly:

```sh
cd ~/dotfiles
stow -nv zsh git tmux nvim ghostty starship ssh ripgrep gdircolors
stow --no-folding -nv ctx codex-config
stow -v zsh git tmux nvim ghostty starship ssh ripgrep gdircolors
stow --no-folding -v ctx codex-config
```

Use `make stow-list` to inspect the current default package set.

## Package map

### Core packages

| Package | Target | Notes |
| --- | --- | --- |
| `zsh/` | `~/.zshrc`, `~/.zprofile`, `~/.zshenv`, helpers | Primary shell setup |
| `bash/` | `~/.bashrc`, `~/.bash_profile`, helpers | Secondary shell config |
| `git/` | `~/.gitconfig`, `~/.gitignore_global`, `~/.config/git/` | Git defaults and scripts |
| `ssh/` | `~/.ssh/config` | SSH host aliases and options |
| `tmux/` | `~/.tmux.conf`, `~/.tmux/` | Tmux config and plugins |
| `nvim/` | `~/.config/nvim/` | Neovim configuration |
| `ghostty/` | `~/.config/ghostty/config` | Primary terminal config |
| `starship/` | `~/.config/starship.toml` | Cross-shell prompt |
| `ripgrep/` | `~/.ripgreprc` | Shared ripgrep defaults |
| `gdircolors/` | `~/.dir_colors` | Shared directory color theme for shell tools |
| `asdf/` | `~/.asdfrc`, `~/.tool-versions` | Runtime version management |
| `bat/` | `~/.config/bat/` | `bat` theme/config |
| `ctx/` | `~/.ctx/config.toml` | Durable ctx preferences; private index/runtime state remains local |
| `codex-config/` | `~/.codex/AGENTS.md`, `~/.codex/policies/`, `~/.codex/parallel-work.config.toml`, `~/.codex/skills/orchestrating-parallel-worktrees/` | Global and progressive Codex policy plus the opt-in parallel-work profile and local orchestration skill; private runtime state remains local |
| `homebrew/` | Brew bundle files | Package bootstrap via Brewfile |

The `ctx` package is state-adjacent: `~/.ctx` must remain a real local directory
because it contains private, mutable search indexes and runtime files. The
Makefile therefore stows `ctx` separately with `--no-folding`, linking only
`config.toml`. The installer-managed `~/.local/bin/ctx` binary is not part of
the package. Bundled ctx agent skills also remain installer-managed; the
OpenCode copy is ignored by Git because its global skills directory links into
this repository.

The `codex-config` package follows the same state-adjacent pattern. `~/.codex`
must remain a real local directory because it contains private, mutable runtime
state. Stowing `codex-config` with `--no-folding` links tracked policy, profile,
and skill files without replacing or folding the real runtime directory. The
parallel profile remains inactive unless Codex is launched with
`-p parallel-work`.

For ordinary isolated task work, create the worktree before starting Codex, then
make that worktree the session's startup checkout:

```sh
git worktree add /path/to/repository/.worktrees/task-slug -b task-branch main
cd /path/to/repository/.worktrees/task-slug
codex -p parallel-work
```

That sole owner does not need a session descriptor, claim, or memory-project
check. The task profile preserves the tracked model and service defaults while
disabling both the Engram plugin and Engram MCP server. Codex
transcript/resume, live Git, and committed task-local plans or notes carry the
working context.

Use the orchestration helper only when two or more writer sessions will work in
parallel, or when an existing `.superpowers/parallel/session.conf` already
selects the protocol. The coordinator names file ownership, dependencies, the
integration owner, and reconciliation order before preparing and launching each
writer:

```sh
session_helper="${CODEX_HOME:-$HOME/.codex}/skills/orchestrating-parallel-worktrees/scripts/worktree-session"
task_root="/path/to/repository/.worktrees/task-slug"

"$session_helper" guard
CODEX_THREAD_ID="coordinator-thread" "$session_helper" prepare \
  --worktree "$task_root" \
  --task-id "TASK-123" \
  --task-slug "task-slug" \
  --plan "docs/plans/task-plan.md" \
  --base-ref "main" \
  --base-sha "0123456789abcdef0123456789abcdef01234567" \
  --target-branch "main" \
  --integration-owner "integration-coordinator"
"$session_helper" launch --worktree "$task_root"
```

From a repository's primary checkout, `guard` reports `COORDINATOR_ONLY`.
That state permits only explicit coordination and the narrow creation of an
approved plan and descriptor in a new, unclaimed linked worktree. It never
permits implementation in another checkout through `workdir`, `git -C`, or
absolute paths. Prepared workers run `guard` and `claim` before writing and
repeat both plus live-state reconciliation after compaction or resume.

New descriptors use schema v2 and contain no memory fields. Existing schema-v1
descriptors remain readable through their current lifecycle so prepared work is
not stranded, but launch and resume do not inject their legacy Engram values.
The deprecated `verify --memory-project` command exists only for schema-v1
compatibility; schema v2 rejects it with migration guidance.

Task-project injection was not a complete session-isolation boundary: it
isolated explicit or manual Engram MCP calls, but did not isolate automatic
session registration, prompts, passive capture, or summaries. Preserve existing
Engram history as searchable legacy material; do not delete or blindly merge it.
Curated canonical memory, when desired, is written deliberately from a
reconciled canonical checkout after integration rather than from task worktrees.

Stow activation and provider-backed canary execution remain separate approval
gates; installing these tracked files does not prove live multi-worker behavior.

### Optional or machine-specific packages

These packages are kept in the repo for selective use and are not part of the default `make stow-*` allow-list:

`alacritty/`, `cursor/`, `iterm2/`, `neofetch/`, `opencode/`, `wezterm/`, `wtf/`

## Tooling

The Brewfile installs the CLI tools and desktop apps this repo expects, including:

- shells and prompt: `bash`, `starship`, `asdf`, `direnv`, `coreutils`
- terminal/editor workflow: `tmux`, `neovim`, `ghostty`
- search/navigation: `ripgrep`, `fd`, `fzf`, `zoxide`, `bat`, `eza`
- git/dev utilities: `git`, `gh`, `git-delta`, `lazygit`, `pre-commit`

See [`homebrew/Brewfile`](./homebrew/Brewfile) for the full package list, casks, MAS apps, and VS Code extensions.
