#!/bin/bash
# Agent Tracker interactive dashboard for tmux
# Rich single-line display per agent, summary header, preview pane

FORMAT='#{@agent_type}|#{@agent_state}|#{@agent_project}|#{@agent_started}|#{@agent_cwd}|#{@agent_notes}|#{pane_id}|#{session_name}:#{window_index}.#{pane_index}|#{pane_title}'

# Colors
RST='\033[0m'
GRN='\033[32m'
YEL='\033[33m'
CYN='\033[36m'
DIM='\033[2m'
PUR='\033[35m'
BLD='\033[1m'

state_icon() {
    case "$1" in
        running) printf "${GRN}${BLD}󰓕 running${RST}" ;;
        pending) printf "${YEL}${BLD}󰏤 pending${RST}" ;;
        idle)    printf "${CYN}󰏤 idle${RST}" ;;
        *)       printf "  unknown" ;;
    esac
}

duration() {
    local started=$1
    [ -z "$started" ] && echo "?" && return
    local now=$(date +%s)
    local elapsed=$((now - started))
    if [ "$elapsed" -lt 60 ]; then
        echo "${elapsed}s"
    elif [ "$elapsed" -lt 3600 ]; then
        echo "$((elapsed / 60))m"
    else
        echo "$((elapsed / 3600))h$((elapsed % 3600 / 60))m"
    fi
}

# Collect agent panes
entries=()
running=0; idle=0; pending=0

while IFS= read -r line; do
    type=$(echo "$line" | cut -d'|' -f1)
    [ -z "$type" ] && continue

    state=$(echo "$line" | cut -d'|' -f2)
    project=$(echo "$line" | cut -d'|' -f3)
    started=$(echo "$line" | cut -d'|' -f4)
    cwd=$(echo "$line" | cut -d'|' -f5)
    notes=$(echo "$line" | cut -d'|' -f6)
    pane_id=$(echo "$line" | cut -d'|' -f7)
    location=$(echo "$line" | cut -d'|' -f8)

    case "$state" in
        running) ((running++)) ;;
        idle)    ((idle++)) ;;
        pending) ((pending++)) ;;
    esac

    icon=$(state_icon "$state")
    dur=$(duration "$started")
    short_cwd="${cwd/#$HOME/~}"

    # Single rich line: state | project | duration | location | cwd | notes
    display="${icon}  ${PUR}󱜚${RST} ${BLD}${project}${RST}"
    display+="  ${DIM}${dur}${RST}"
    display+="  ${DIM}${location}${RST}"
    display+="  ${DIM}${short_cwd}${RST}"
    [ -n "$notes" ] && display+="  ${CYN}📝 ${notes}${RST}"

    entries+=("${pane_id}	${display}")
done < <(tmux list-panes -a -F "$FORMAT" 2>/dev/null)

if [ ${#entries[@]} -eq 0 ]; then
    echo "No active agents found."
    read -n 1 -s -r -p "Press any key to close..."
    exit 0
fi

# Build summary
summary="  ${GRN}󰓕 ${running} running${RST}  ${YEL}󰏤 ${pending} pending${RST}  ${CYN}󰏤 ${idle} idle${RST}"

# Build fzf input
fzf_input=""
for entry in "${entries[@]}"; do
    fzf_input+="${entry}"$'\n'
done

# Run fzf
selected=$(printf '%b' "$fzf_input" | fzf --ansi \
    --header="$(printf '%b' "${summary}")
Enter:switch  Ctrl-N:notes  Ctrl-K:kill  Ctrl-F:focus-pending" \
    --expect="ctrl-n,ctrl-k,ctrl-f" \
    --preview="tmux capture-pane -t {1} -p 2>/dev/null | tail -40" \
    --preview-window=right:50%:wrap \
    --delimiter=$'\t' \
    --with-nth=2.. \
    --no-sort)

[ -z "$selected" ] && exit 0

key=$(echo "$selected" | head -1)
choice=$(echo "$selected" | sed -n '2p')
pane_id=$(echo "$choice" | cut -f1)

# Handle Ctrl-F (focus pending) without needing a selection
if [ "$key" = "ctrl-f" ]; then
    "$(dirname "$0")/tracker-focus.sh"
    exit 0
fi

[ -z "$pane_id" ] && exit 0

case "$key" in
    ctrl-n)
        current_notes=$(tmux show -p -t "$pane_id" -v @agent_notes 2>/dev/null)
        printf "Notes [%s]: " "$current_notes"
        read -r new_notes
        if [ -n "$new_notes" ]; then
            tmux set -p -t "$pane_id" @agent_notes "$new_notes"
        fi
        exec "$0"
        ;;
    ctrl-k)
        printf "Kill pane %s? [y/N] " "$pane_id"
        read -r confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            tmux kill-pane -t "$pane_id"
            sleep 0.2
            "$(dirname "$0")/tracker-summary.sh"
        fi
        exec "$0"
        ;;
    *)
        tmux switch-client -t "$pane_id" 2>/dev/null || tmux select-pane -t "$pane_id" 2>/dev/null
        ;;
esac
