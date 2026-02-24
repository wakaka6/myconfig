#!/bin/bash
# Aggregate agent states from tmux per-pane options and update global summary
# Called by tracker-tmux.sh (after state changes) and tmux hooks (pane-exited/died)

states=$(tmux list-panes -a -F '#{@agent_state}' 2>/dev/null)
[ -z "$states" ] && { tmux set -g @tracker_summary '' 2>/dev/null; tmux refresh-client -S 2>/dev/null; exit 0; }

running=$(echo "$states" | grep -c '^running$' || true)
idle=$(echo "$states" | grep -c '^idle$' || true)
pending=$(echo "$states" | grep -c '^pending$' || true)

summary=""
[ "$running" -gt 0 ] && summary="${summary}#[fg=green]󰓕 ${running} "
[ "$pending" -gt 0 ] && summary="${summary}#[fg=yellow]󰏤 ${pending} "
[ "$idle" -gt 0 ] && summary="${summary}#[fg=cyan]󰏤 ${idle} "

# Trim trailing space
summary="${summary% }"

tmux set -g @tracker_summary "$summary" 2>/dev/null
tmux refresh-client -S 2>/dev/null
