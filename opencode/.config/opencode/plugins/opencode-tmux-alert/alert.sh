#!/usr/bin/env bash
# Frozen local fork of seanhalberthal/opencode-tmux-alert.

set -euo pipefail

PANE_ID="${TMUX_PANE:-}"
[ -z "$PANE_ID" ] && exit 0

tmux set-option -w -t "$PANE_ID" @opencode-alert 1 2>/dev/null || true

# Pass Ghostty's OSC 9 desktop notification through tmux. Unlike BEL, this
# shows a notification without triggering Ghostty's macOS Dock attention bounce.
printf '\033Ptmux;\033\033]9;OpenCode\033\033\\\033\\'
