#!/usr/bin/env bash
# Frozen local fork of seanhalberthal/opencode-tmux-alert.

set -euo pipefail

PANE_ID="${TMUX_PANE:-}"
[ -z "$PANE_ID" ] && exit 0

tmux set-option -w -u -t "$PANE_ID" @opencode-alert 2>/dev/null || true
