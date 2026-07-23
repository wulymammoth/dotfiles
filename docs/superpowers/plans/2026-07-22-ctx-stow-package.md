# ctx Stow Package Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Manage ctx's durable configuration with GNU Stow while keeping its private mutable index and runtime state outside the dotfiles worktree.

**Architecture:** Add a conventional `ctx/.ctx/config.toml` package, but invoke that state-adjacent package in a separate Stow command with `--no-folding` so `~/.ctx` always remains a real directory. A Zsh regression test exercises the package against a temporary target containing sentinel state before the real config is adopted.

**Tech Stack:** GNU Stow 2.4.1, GNU Make, Zsh, ctx 0.25.0, Git.

## Global Constraints

- Manage only `~/.ctx/config.toml`; never move databases, locks, caches, logs, runtime assets, object storage, or spool storage into the repository.
- Keep `~/.local/bin/ctx` and `~/.local/bin/ctx.install.json` installer-managed and outside Stow.
- Invoke ctx separately with `stow --no-folding ctx`; do not change tree-folding behavior for existing packages.
- Keep exactly one process-level upgrade guard, `CTX_UPGRADE_OFF=1`, in `zsh/.zshenv`; remove the duplicate ctx block from `zsh/.exports`.
- Keep bundled ctx agent skills installer-managed; ignore the generated OpenCode copy that lands through the existing Stow link.
- Normalize `~/.zshenv` from an absolute link to the equivalent relative Stow-owned link without changing its resolved destination.
- Preserve the unrelated modification to `docs/superpowers/specs/2026-07-22-binstall-trust-aware-design.md`.
- Use TDD and observe the regression test fail before creating the package or changing the Makefile.
- Obtain explicit user approval before staging or committing.

---

## File structure

- Create `tests/ctx-stow.zsh`: regression harness proving file-only Stow behavior around mutable ctx state.
- Create `ctx/.ctx/config.toml`: durable ctx preferences and the only file owned by the ctx Stow package.
- Modify `.gitignore`: ignore the exact installer-managed OpenCode ctx skill directory.
- Modify `Makefile`: add a separately invoked stateful package group using `--no-folding`.
- Modify `zsh/.zshenv`: retain one canonical process-level ctx upgrade guard.
- Modify `zsh/.exports`: remove the redundant interactive-only ctx guard.
- Modify `README.md`: document ctx ownership, installation boundary, and Stow behavior.
- Use `docs/superpowers/specs/2026-07-22-ctx-stow-package-design.md`: approved design record.
- Update `~/Desktop/notes/main--2026-07-22.md`: local completion and continuation record; do not commit it.

### Task 1: Add the ctx package with a red-green Stow regression

**Files:**
- Create: `tests/ctx-stow.zsh`
- Create: `ctx/.ctx/config.toml`
- Modify: `Makefile:1-25`
- Modify: `zsh/.zshenv:1-8`
- Modify: `zsh/.exports:1-9`
- Test: `tests/ctx-stow.zsh`

**Interfaces:**
- Consumes: repository root derived from `${0:A:h:h}`, GNU Stow, and a temporary target directory.
- Produces: `make stow-preview`, `make stow-apply`, and `make stow-list` coverage for a stateful `ctx` package; a file-level `~/.ctx/config.toml` link that preserves sibling state.

- [ ] **Step 1: Write the failing regression test**

Create `tests/ctx-stow.zsh`:

```zsh
#!/usr/bin/env zsh

emulate -LR zsh
setopt errexit nounset pipefail

repo_root="${0:A:h:h}"
test_root="$(mktemp -d /tmp/ctx-stow-test.XXXXXX)"
trap 'rm -rf "$test_root"' EXIT

fail() {
  print -u2 -- "FAIL: $*"
  exit 1
}

mkdir -p "$test_root/.ctx"
print -r -- "sentinel database" >"$test_root/.ctx/work.sqlite"

guard_files="$(rg -l '^export CTX_UPGRADE_OFF=1$' \
  "$repo_root/zsh/.zshenv" "$repo_root/zsh/.exports")"
[[ "$guard_files" == "$repo_root/zsh/.zshenv" ]] \
  || fail "CTX_UPGRADE_OFF must be defined only in zsh/.zshenv"
! rg -q '^export CTX_DISABLE_AUTO_UPGRADE=' \
  "$repo_root/zsh/.zshenv" "$repo_root/zsh/.exports" \
  || fail "duplicate ctx upgrade alias must be removed"

generated_skill="opencode/.config/opencode/skills/ctx-agent-history-search/SKILL.md"
git -C "$repo_root" check-ignore -q -- "$generated_skill" \
  || fail "installer-managed OpenCode ctx skill must be ignored"

[[ -f "$repo_root/ctx/.ctx/config.toml" ]] \
  || fail "ctx package config is missing"

stow --no-folding \
  --dir "$repo_root" \
  --target "$test_root" \
  ctx

[[ -d "$test_root/.ctx" && ! -L "$test_root/.ctx" ]] \
  || fail ".ctx must remain a real directory"
[[ -L "$test_root/.ctx/config.toml" ]] \
  || fail "config.toml must be a symlink"
config_link="$test_root/.ctx/config.toml"
[[ "${config_link:A}" == "$repo_root/ctx/.ctx/config.toml" ]] \
  || fail "config.toml must resolve to the ctx package"
[[ "$(<"$test_root/.ctx/work.sqlite")" == "sentinel database" ]] \
  || fail "existing ctx state changed"

typeset -a package_entries
package_entries=("$repo_root/ctx/.ctx"/*(DN))
(( ${#package_entries[@]} == 1 )) \
  || fail "ctx package must contain only config.toml"
[[ "${package_entries[1]:t}" == "config.toml" ]] \
  || fail "unexpected ctx package entry: ${package_entries[1]}"

apply_recipe="$(make -s -n -C "$repo_root" stow-apply)"
[[ "$apply_recipe" == *'stow --no-folding -v ctx'* ]] \
  || fail "ctx must use a separate no-folding Stow command"
[[ "$(make -s -C "$repo_root" stow-list)" == *$'\nctx'* ]] \
  || fail "ctx must appear in the default Stow package list"

print -- "PASS: ctx config-only Stow package"
```

- [ ] **Step 2: Run the regression and verify RED**

Run:

```sh
zsh tests/ctx-stow.zsh
```

Expected on the first run: exit `1` with `FAIL: CTX_UPGRADE_OFF must be defined only in zsh/.zshenv` because the current installation duplicated both supported guards across two files. After fixing that boundary and before changing `.gitignore`, expect `FAIL: installer-managed OpenCode ctx skill must be ignored`.

- [ ] **Step 3: Add the minimal package and Makefile behavior**

Create `ctx/.ctx/config.toml`:

```toml
[daemon]
enabled = false

[search]
semantic = false

[upgrade]
auto = "off"
```

Keep the beginning of `zsh/.zshenv` as:

```zsh
. "$HOME/.cargo/env"

# Keep installer-managed ctx upgrades opt-in in every zsh process.
export CTX_UPGRADE_OFF=1

# asdf initialization (must be in zshenv for non-interactive shells like Mason)
```

Remove the complete ctx block from `zsh/.exports`, so its first setting after
the shebang is the existing history configuration.

Add this focused generated-artifact rule to `.gitignore`:

```gitignore
# Generated and updated by the ctx installer through the OpenCode Stow link.
opencode/.config/opencode/skills/ctx-agent-history-search/
```

Change the Makefile package definitions and targets to:

```make
ALLOW_PACKAGES := asdf bat gdircolors ghostty git homebrew nvim ripgrep ssh starship tmux zsh
STATEFUL_PACKAGES := ctx

STOW ?= stow

.PHONY: help stow-preview stow-apply stow-list

help:
	@echo "stow-preview  Preview links with stow -nv (no changes)"
	@echo "stow-apply    Apply links with stow -v"
	@echo "stow-list     Print current allow-list"

stow-preview:
	@echo "Previewing packages: $(ALLOW_PACKAGES)"
	@$(STOW) -nv $(ALLOW_PACKAGES)
	@echo "Previewing stateful packages without tree folding: $(STATEFUL_PACKAGES)"
	@$(STOW) --no-folding -nv $(STATEFUL_PACKAGES)

stow-apply:
	@echo "Stowing packages: $(ALLOW_PACKAGES)"
	@$(STOW) -v $(ALLOW_PACKAGES)
	@echo "Stowing stateful packages without tree folding: $(STATEFUL_PACKAGES)"
	@$(STOW) --no-folding -v $(STATEFUL_PACKAGES)

stow-list:
	@printf "%s\n" $(ALLOW_PACKAGES) $(STATEFUL_PACKAGES)
```

- [ ] **Step 4: Run the regression and verify GREEN**

Run:

```sh
zsh tests/ctx-stow.zsh
```

Expected: exit `0` with `PASS: ctx config-only Stow package`.

- [ ] **Step 5: Verify syntax and diff hygiene**

Run:

```sh
zsh -n tests/ctx-stow.zsh
make -n stow-preview
git diff --check
```

Expected: all commands exit `0`; the preview shows ordinary packages on the existing Stow command and ctx on `stow --no-folding -nv ctx`.

### Task 2: Adopt the live config and document the boundary

**Files:**
- Modify: `README.md:5-65`
- Adopt: `~/.ctx/config.toml` as a symlink to `ctx/.ctx/config.toml`
- Normalize: `~/.zshenv` as a relative symlink to `dotfiles/zsh/.zshenv`
- Update: `~/Desktop/notes/main--2026-07-22.md`

**Interfaces:**
- Consumes: the green package from Task 1 and the existing `~/.ctx/config.toml` with identical content.
- Produces: a live file-level Stow link, documented ownership boundaries, verified ctx access, and a local continuation note.

- [ ] **Step 1: Document ctx in the README**

Add ctx to the core package table:

```markdown
| `ctx/` | `~/.ctx/config.toml` | Durable ctx preferences; private index/runtime state remains local |
```

After the package table, add:

```markdown
The `ctx` package is state-adjacent: `~/.ctx` must remain a real local directory
because it contains private, mutable search indexes and runtime files. The
Makefile therefore stows `ctx` separately with `--no-folding`, linking only
`config.toml`. The installer-managed `~/.local/bin/ctx` binary is not part of
the package.
```

- [ ] **Step 2: Confirm adoption is content-preserving**

Run:

```sh
cmp -s ~/.ctx/config.toml ctx/.ctx/config.toml
stow --adopt --no-folding -nv ctx
```

Expected: `cmp` exits `0`; Stow reports adopting `.ctx/config.toml` and linking it without moving any sibling state.

- [ ] **Step 3: Apply the real Stow migration**

Run:

```sh
stow --adopt --no-folding -v ctx
```

Expected: `~/.ctx` remains a real directory and `~/.ctx/config.toml` becomes a relative symlink into `~/dotfiles/ctx/.ctx/config.toml`.

- [ ] **Step 4: Verify the live runtime boundary**

Run:

```sh
test -d ~/.ctx
test ! -L ~/.ctx
test -L ~/.ctx/config.toml
readlink ~/.ctx/config.toml
ctx status --json
```

Expected: all checks exit `0`; the config link resolves into the repository; ctx reports `config_path` and `data_root` under `~/.ctx`, `initialized: true`, and the existing index counts.

- [ ] **Step 5: Normalize the existing zshenv link for Stow ownership**

First verify that the current absolute link resolves to the intended tracked
file, then replace only the link representation:

```sh
test "$(readlink ~/.zshenv)" = "$HOME/dotfiles/zsh/.zshenv"
ln -sfn dotfiles/zsh/.zshenv ~/.zshenv
test "$(readlink ~/.zshenv)" = "dotfiles/zsh/.zshenv"
test "$(realpath ~/.zshenv)" = "$HOME/dotfiles/zsh/.zshenv"
```

Expected: every command exits `0`; the relative link resolves to the same
tracked file as before.

- [ ] **Step 6: Run the complete verification set**

Run:

```sh
zsh tests/ctx-stow.zsh
zsh -n tests/ctx-stow.zsh
make stow-preview
git diff --check
git status --short
```

Expected: the regression and syntax checks pass; Stow preview has no conflicts; diff check passes; pre-existing unrelated modifications remain unstaged and intact.

- [ ] **Step 7: Update the branch progress note**

Append this entry to `~/Desktop/notes/main--2026-07-22.md`:

```markdown
## ctx Stow package

- `ctx/.ctx/config.toml` is the durable source of truth and is linked at `~/.ctx/config.toml`.
- `~/.ctx` remains a real local directory; SQLite indexes, locks, objects, spool data, runtime assets, and logs stay outside the repo.
- The Makefile uses a separate `stow --no-folding ctx` command to prevent state-directory folding on fresh machines.
- `CTX_UPGRADE_OFF=1` lives once in `.zshenv`; the redundant `.exports` block and alias were removed.
- `~/.zshenv` now uses the repository's relative Stow-owned link form without changing its resolved destination.
- The generated OpenCode ctx skill remains installer-managed and current but is ignored by Git.
- Verification: `zsh tests/ctx-stow.zsh`, `zsh -n tests/ctx-stow.zsh`, `make stow-preview`, `git diff --check`, and `ctx status --json` pass.
```

- [ ] **Step 8: Present the atomic commit for approval**

Proposed commit message:

```text
feat(ctx): manage durable config with stow
```

Show the exact files, diff stat, and verification results. Wait for explicit confirmation before staging or committing. Include the reviewed ctx-related changes in `zsh/.exports` and `zsh/.zshenv`; exclude the unrelated binstall design change.

- [ ] **Step 9: Commit only after approval**

Run:

```sh
git add .gitignore Makefile README.md ctx/.ctx/config.toml tests/ctx-stow.zsh zsh/.exports zsh/.zshenv
git add -f docs/superpowers/specs/2026-07-22-ctx-stow-package-design.md docs/superpowers/plans/2026-07-22-ctx-stow-package.md
git diff --cached --check
git commit -m "feat(ctx): manage durable config with stow"
```

Expected: one atomic commit for the package, shell guard, regression, docs, approved design, and plan; the unrelated binstall design change remains outside the commit.
