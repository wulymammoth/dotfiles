#!/usr/bin/env bash

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Directory: basename only (mirrors Starship [directory] default)
dir=$(basename "$cwd")

# Git branch and status (skip lock contention with -c core.fsmonitor=false)
branch=""
git_info=""
if git -C "$cwd" -c core.fsmonitor=false rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" -c core.fsmonitor=false symbolic-ref --short HEAD 2>/dev/null \
            || git -C "$cwd" -c core.fsmonitor=false rev-parse --short HEAD 2>/dev/null)

  # Check for modifications/staged/untracked (mirrors Starship git_status)
  status_flags=""
  git_status=$(git -C "$cwd" -c core.fsmonitor=false status --porcelain 2>/dev/null)
  if echo "$git_status" | grep -q '^.[MADRCU?]'; then
    status_flags="*"
  fi

  if [ -n "$branch" ]; then
    git_info=" $branch${status_flags}"
  fi
fi

# Context usage indicator
ctx_info=""
if [ -n "$used_pct" ]; then
  used_int=${used_pct%.*}
  if [ "$used_int" -ge 75 ]; then
    ctx_info=" ctx:${used_int}%"
  fi
fi

# Build and print the status line with ANSI colors
# Blue directory, bright-black git branch (matches Starship style), cyan model
printf '\033[34m%s\033[0m' "$dir"
if [ -n "$git_info" ]; then
  printf ' \033[90m%s\033[0m' "$git_info"
fi
if [ -n "$model" ]; then
  printf ' \033[36m%s\033[0m' "$model"
fi
if [ -n "$ctx_info" ]; then
  printf ' \033[33m%s\033[0m' "$ctx_info"
fi
printf '\n'
