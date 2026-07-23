# Trust-aware `binstall` design

Date: 2026-07-22
Status: Approved design, pending implementation

## Problem

`binstall` currently delegates directly to `brew bundle add --global --install
--formula`. With Homebrew 6, a fully qualified formula from a non-official tap
may be added to the global Brewfile without being installed because the formula
has not crossed Homebrew's explicit tap-trust boundary. The resulting state is
misleading: the dependency is declared, but its executable is unavailable.

## Goals

- Preserve the existing one-command install-and-record workflow.
- Trust only third-party formulae explicitly passed to `binstall`.
- Never trust an entire third-party tap implicitly.
- Record the formula-scoped trust decision in the global Brewfile so another
  machine can reproduce it and `brew bundle cleanup --force` will not discard
  it.
- Preserve existing behavior for official or short-name formulae.
- Fail visibly when trust, installation, or Brewfile persistence fails.

## Non-goals

- Changing `bcask` in this slice.
- Auditing or approving the contents of arbitrary third-party formulae.
- Disabling Homebrew's trust model.
- Rewriting or normalizing the entire Brewfile.

## Design

### Formula classification

`binstall` will treat a name in `owner/tap/formula` form as a third-party,
fully qualified formula. Short names such as `ripgrep` remain on the existing
Homebrew path and do not receive explicit trust metadata.

### Trust and installation flow

For each fully qualified formula, `binstall` will grant formula-scoped trust
with `brew trust --formula`. Once those trust operations succeed, it will run
the existing targeted command:

```sh
brew bundle add --global --install --formula ...
```

This retains Homebrew Bundle's description comments, duplicate handling, and
global Brewfile path selection. It also avoids running a general
`brew bundle install`, which could install or upgrade unrelated declarations.

### Durable Brewfile trust

Homebrew 6 does not make `brew bundle add` serialize existing trust as
`trusted: true`. After a successful add/install, `binstall` will update only the
exact declaration for each fully qualified formula:

```ruby
brew "owner/tap/formula", trusted: true
```

If the declaration already contains options, `trusted: true` will be appended
without removing those options. If it is already trusted, the operation is a
no-op. Other Brewfile lines, comments, quote styles, and ordering remain
unchanged.

The helper will use `HOMEBREW_BUNDLE_FILE_GLOBAL`, which this repository sets
to `~/dotfiles/homebrew/Brewfile`. It will report an actionable error rather
than guessing a different file when that variable is unavailable.

### Error handling

- No arguments: print usage and return a non-zero status.
- Formula-scoped trust failure: stop before installation.
- Bundle add/install failure: return its failure status and do not claim
  success.
- Missing or unwritable global Brewfile: report the path problem and return a
  non-zero status.
- Brewfile declaration not found after a successful bundle add: report the
  inconsistency and return a non-zero status.

Trust granted before a later installation failure remains in Homebrew's
formula-scoped trust store. This is acceptable because it grants authority only
to a formula the user explicitly requested, and the failure remains visible.

## Testing strategy

A dependency-free Zsh regression test will source the real function file while
placing a stub `brew` executable first on `PATH` and using a temporary global
Brewfile. Tests will verify:

1. A third-party formula receives `brew trust --formula` before bundle
   installation and is persisted with `trusted: true`.
2. A short-name/core formula is installed and recorded without an explicit
   trust operation or trust annotation.
3. Multiple and mixed formula arguments retain their original order.
4. Existing Brewfile options are preserved when trust metadata is added.
5. Repeated invocation does not duplicate `trusted: true`.
6. Trust and installation failures propagate as non-zero statuses.

Implementation will follow red-green-refactor: write the first regression test,
observe the expected failure against the current function, apply the smallest
production change, then expand coverage and refactor while keeping the suite
green.

## Verification

- Run the dedicated Zsh regression test.
- Parse the updated function file with `zsh -n`.
- Run ShellCheck in Zsh mode where its checks apply.
- Confirm the user's existing Brewfile entry remains:
  `brew 'gentleman-programming/tap/engram', trusted: true`.
- Do not perform a real package install as part of automated tests.
