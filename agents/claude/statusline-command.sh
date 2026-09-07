#!/usr/bin/env bash
# Claude Code statusline.
# Everything below comes straight from the JSON payload on stdin — including
# rate_limits, which are the same official numbers /usage reports. No ccusage,
# no network, no cache: renders instantly.
input=$(cat)

eval "$(printf '%s' "$input" | jq -r '
  @sh "model=\(.model.display_name // "")",
  @sh "effort=\(.effort.level // "")",
  @sh "fast=\(.fast_mode // false | tostring)",
  @sh "cwd=\(.cwd // .workspace.current_dir // "")",
  @sh "worktree=\(.workspace.git_worktree // "")",
  @sh "ctx_left=\(.context_window.remaining_percentage // "")",
  @sh "win=\(.context_window.context_window_size // "")",
  @sh "h5_used=\(.rate_limits.five_hour.used_percentage // "")",
  @sh "h5_reset=\(.rate_limits.five_hour.resets_at // "")",
  @sh "wk_used=\(.rate_limits.seven_day.used_percentage // "")",
  @sh "wk_reset=\(.rate_limits.seven_day.resets_at // "")"
')"

DIM=$'\033[2m'; RESET=$'\033[0m'
GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'
CYAN=$'\033[36m'; MAGENTA=$'\033[35m'; BLUE=$'\033[34m'

# Green when there's plenty left, yellow under 30%, red under 10%.
color_for_left() {
  if   [ "$1" -lt 10 ]; then printf '%s' "$RED"
  elif [ "$1" -lt 30 ]; then printf '%s' "$YELLOW"
  else printf '%s' "$GREEN"; fi
}

# "3d4h" / "1h32m" / "12m" until an epoch timestamp; empty if already past.
until_hm() {
  local secs=$(( $1 - $(date +%s) ))
  [ "$secs" -le 0 ] && return
  local d=$(( secs / 86400 )) h=$(( (secs % 86400) / 3600 )) m=$(( (secs % 3600) / 60 ))
  if   [ "$d" -gt 0 ]; then printf '%dd%dh' "$d" "$h"
  elif [ "$h" -gt 0 ]; then printf '%dh%02dm' "$h" "$m"
  else printf '%dm' "$m"; fi
}

# "left%  window" — reset countdown only once the window is worth watching.
window_part() {
  local label=$1 used=$2 reset=$3
  [ -z "$used" ] && return
  local left=$(( 100 - used ))
  local out="${DIM}${label}${RESET} $(color_for_left "$left")${left}% left${RESET}"
  if [ "$left" -lt 50 ] && [ -n "$reset" ]; then
    local t; t=$(until_hm "$reset")
    [ -n "$t" ] && out="$out ${DIM}(${t})${RESET}"
  fi
  printf '%s' "$out"
}

parts=()

# Model, with reasoning effort and the modifiers that change how it answers.
if [ -n "$model" ]; then
  m="${MAGENTA}${model}${RESET}"
  [ -n "$effort" ] && m="$m ${DIM}${effort}${RESET}"
  [ "$fast" = "true" ] && m="$m ${YELLOW}fast${RESET}"
  parts+=("$m")
fi

# Context left, with the window size so 96% has a scale.
if [ -n "$ctx_left" ]; then
  printf -v cl '%.0f' "$ctx_left"
  c="${DIM}ctx${RESET} $(color_for_left "$cl")${cl}% left${RESET}"
  if [ -n "$win" ] && [ "$win" -gt 0 ]; then
    if [ "$win" -ge 1000000 ]; then wl="$(( win / 1000000 ))M"; else wl="$(( win / 1000 ))K"; fi
    c="$c ${DIM}of ${wl}${RESET}"
  fi
  parts+=("$c")
fi

p=$(window_part "5h" "$h5_used" "$h5_reset");  [ -n "$p" ] && parts+=("$p")
p=$(window_part "week" "$wk_used" "$wk_reset"); [ -n "$p" ] && parts+=("$p")

# Repo + branch. The worktree name usually echoes the branch, so show it as a
# marker rather than a second copy of the same string.
if repo=$(git -C "$cwd" -c gc.auto=0 rev-parse --path-format=absolute --git-common-dir 2>/dev/null); then
  repo=$(basename "$(dirname "$repo")")
  branch=$(git -C "$cwd" -c gc.auto=0 symbolic-ref --short HEAD 2>/dev/null) \
    || branch=$(git -C "$cwd" -c gc.auto=0 rev-parse --short HEAD 2>/dev/null)
  g="${CYAN}${repo}${RESET}"
  [ -n "$branch" ] && g="$g ${BLUE}${branch}${RESET}"
  [ -n "$worktree" ] && g="$g ${DIM}⑂${RESET}"
  parts+=("$g")
fi

printf '%s' "${parts[0]}"
for part in "${parts[@]:1}"; do printf ' %s·%s %s' "$DIM" "$RESET" "$part"; done
printf '\n'
