#!/bin/bash
# Jump to the first agent pane that needs attention (pending > idle)
# Used as a quick shortcut without opening the full popup

FORMAT='#{@agent_state}|#{pane_id}'

# Priority: pending first, then idle
target=""
fallback=""

while IFS='|' read -r state pane_id; do
    [ -z "$state" ] && continue
    if [ "$state" = "pending" ] && [ -z "$target" ]; then
        target="$pane_id"
        break
    elif [ "$state" = "idle" ] && [ -z "$fallback" ]; then
        fallback="$pane_id"
    fi
done < <(tmux list-panes -a -F "$FORMAT" 2>/dev/null)

pane="${target:-$fallback}"

if [ -n "$pane" ]; then
    tmux switch-client -t "$pane" 2>/dev/null || tmux select-pane -t "$pane" 2>/dev/null
fi
