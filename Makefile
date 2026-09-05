SHELL := /bin/bash

# Adjust this allow-list to only the packages you actively use.
# Example: add/remove ghostty, wezterm, neofetch, cursor, etc.
ALLOW_PACKAGES := asdf bat gdircolors ghostty git homebrew nvim ripgrep ssh starship tmux zsh
STATEFUL_PACKAGES := codex-config

STOW ?= stow
PYTHON ?= python3

.PHONY: help stow-preview stow-apply stow-list maestro-install maestro-preview maestro-activate maestro-doctor test-maestro

help:
	@echo "stow-preview  Preview links with stow -nv (no changes)"
	@echo "stow-apply    Apply links with stow -v"
	@echo "stow-list     Print current allow-list"
	@echo "maestro-<action>  install | preview | activate | doctor (mobile tooling)"
	@echo "test-maestro      Run offline toolchain and activation tests"

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

# Selective mobile tooling: intentionally not an unpinned Brewfile dependency.
maestro-install:
	$(PYTHON) maestro/.local/bin/maestro-toolchain install

maestro-preview:
	$(STOW) --no-folding -nv --target="$(HOME)" maestro codex-config

maestro-activate:
	$(STOW) --no-folding -v --target="$(HOME)" maestro codex-config

maestro-doctor:
	$(PYTHON) maestro/.local/bin/maestro-toolchain doctor --ios

test-maestro:
	$(PYTHON) -B -m unittest discover -s tests -p 'test_maestro_toolchain.py' -v
	zsh tests/maestro-integration.zsh
	shellcheck maestro/.local/bin/maestro
