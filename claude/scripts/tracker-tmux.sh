#!/bin/bash
# Claude Agent Tracker Hook for tmux
# Uses $TMUX_PANE as primary key + tmux per-pane user options for state storage
# Zero PID discovery, zero external state files, automatic cleanup
set -u

# Bail out if not inside tmux
[ -z "${TMUX:-}" ] && exit 0
[ -z "${TMUX_PANE:-}" ] && exit 0

SUMMARY_SCRIPT="$(dirname "$0")/tracker-summary.sh"

json=$(cat)
[ -z "$json" ] && exit 0

event=$(echo "$json" | jq -r '.hook_event_name // empty')
[ -z "$event" ] && exit 0

# NOOP events: exit early without touching state or calling summary
case "$event" in
    PreToolUse|PostToolUse|SubagentStop|Notification|PreCompact)
        exit 0
        ;;
esac

cwd=$(echo "$json" | jq -r '.cwd // empty')
project=$(basename "$cwd" 2>/dev/null || echo "unknown")

pane="$TMUX_PANE"

case "$event" in
    SessionStart)
        tmux set -p -t "$pane" @agent_type "claude"
        tmux set -p -t "$pane" @agent_state "idle"
        tmux set -p -t "$pane" @agent_project "$project"
        tmux set -p -t "$pane" @agent_started "$(date +%s)"
        tmux set -p -t "$pane" @agent_cwd "$cwd"
        ;;
    SessionEnd)
        tmux set -pu -t "$pane" @agent_type 2>/dev/null
        tmux set -pu -t "$pane" @agent_state 2>/dev/null
        tmux set -pu -t "$pane" @agent_project 2>/dev/null
        tmux set -pu -t "$pane" @agent_started 2>/dev/null
        tmux set -pu -t "$pane" @agent_cwd 2>/dev/null
        tmux set -pu -t "$pane" @agent_notes 2>/dev/null
        ;;
    UserPromptSubmit)
        tmux set -p -t "$pane" @agent_state "running"
        # Update cwd in case user changed directory
        [ -n "$cwd" ] && tmux set -p -t "$pane" @agent_cwd "$cwd"
        ;;
    Stop)
        tmux set -p -t "$pane" @agent_state "idle"
        ;;
    PermissionRequest)
        tmux set -p -t "$pane" @agent_state "pending"
        ;;
    *)
        exit 0
        ;;
esac

# Update summary in background
"$SUMMARY_SCRIPT" &
exit 0
