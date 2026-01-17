SHELL := /bin/bash

# Adjust this allow-list to only the packages you actively use.
# Example: add/remove ghostty, wezterm, yabai, cursor, etc.
ALLOW_PACKAGES := asdf bat ghostty git homebrew nvim ripgrep ssh starship tmux zsh

STOW ?= stow

.PHONY: help stow-preview stow-apply stow-list

help:
	@echo "stow-preview  Preview links with stow -nv (no changes)"
	@echo "stow-apply    Apply links with stow -v"
	@echo "stow-list     Print current allow-list"

stow-preview:
	@echo "Previewing packages: $(ALLOW_PACKAGES)"
	@$(STOW) -nv $(ALLOW_PACKAGES)

stow-apply:
	@echo "Stowing packages: $(ALLOW_PACKAGES)"
	@$(STOW) -v $(ALLOW_PACKAGES)

stow-list:
	@printf "%s\n" $(ALLOW_PACKAGES)
