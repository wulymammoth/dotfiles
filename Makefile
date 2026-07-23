SHELL := /bin/bash

# Adjust this allow-list to only the packages you actively use.
# Example: add/remove ghostty, wezterm, neofetch, cursor, etc.
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
