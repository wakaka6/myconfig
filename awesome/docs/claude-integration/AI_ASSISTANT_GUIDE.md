# AI Assistant Configuration Guide

This document is intended for AI assistants to help users configure Claude Code + AwesomeWM integration.

## Quick Reference

### Repository Structure

```
myconfig/
├── claude/
│   ├── scripts/
│   │   ├── tracker.sh      # Event → Tracker API calls
│   │   └── notify.sh       # Event → Desktop notifications
│   └── hooks.json          # Hook configuration template
├── awesome/
│   └── modules/
│       ├── tracker.lua     # Generic session tracker
│       ├── claude.lua      # Claude notification handling
│       └── widgets.lua     # Status bar widget
└── auto_config.sh          # Auto configuration script
```

### Installation Paths

| Source (myconfig) | Target | Method |
|-------------------|--------|--------|
| `claude/scripts/` | `~/.claude/scripts/` | symlink |
| `claude/hooks.json` | `~/.claude/settings.json` | merge |
| `awesome/` | `~/.config/awesome/` | symlink |

### Key Concepts

1. **agent_id** - Unique session identifier (Claude uses `session_id` from hook JSON)
2. **window_id** - Terminal window ID for focusing (from `ALACRITTY_WINDOW_ID` or JSON)
3. **State Machine**: idle → running → idle/pending → idle

---

## Installation Methods

### Method 1: Using auto_config.sh (Recommended)

```bash
cd ~/myconfig
./auto_config.sh -p claude-scripts -p claude-hooks
```

This will:
1. Symlink `myconfig/claude/scripts/` → `~/.claude/scripts/`
2. Merge `myconfig/claude/hooks.json` into `~/.claude/settings.json`

Check status:
```bash
./auto_config.sh status -p claude-scripts -p claude-hooks
```

### Method 2: Manual Installation

```bash
# 1. Symlink scripts
mkdir -p ~/.claude
ln -s ~/myconfig/claude/scripts ~/.claude/scripts
chmod +x ~/.claude/scripts/*.sh

# 2. Merge hooks config
jq -s '.[0] * .[1]' ~/.claude/settings.json ~/myconfig/claude/hooks.json > /tmp/merged.json
mv /tmp/merged.json ~/.claude/settings.json

# 3. Reload AwesomeWM
echo 'awesome.restart()' | awesome-client
```

---

## File Contents Reference

### myconfig/claude/scripts/tracker.sh

Converts Claude events to tracker API calls:

```bash
#!/bin/bash
set -u

json=$(cat)
[ -z "$json" ] && exit 0

agent_id=$(echo "$json" | jq -r '.session_id // empty')
[ -z "$agent_id" ] && exit 0

window_id="${ALACRITTY_WINDOW_ID:-$(echo "$json" | jq -r '.window_id // empty')}"
event=$(echo "$json" | jq -r '.hook_event_name // empty')
cwd=$(echo "$json" | jq -r '.cwd // empty')
project=$(basename "$cwd" 2>/dev/null || echo "unknown")

tracker="require('modules.tracker')"

case "$event" in
    SessionStart)
        awesome-client "$tracker.register('$agent_id', '$window_id', '$project', 'claude')"
        ;;
    UserPromptSubmit)
        awesome-client "$tracker.set_running('$agent_id')"
        ;;
    Stop)
        awesome-client "$tracker.set_idle('$agent_id')"
        ;;
    PermissionRequest)
        awesome-client "$tracker.set_pending('$agent_id')"
        ;;
    SessionEnd)
        awesome-client "$tracker.remove('$agent_id')"
        ;;
esac 2>/dev/null || true

exit 0
```

### myconfig/claude/hooks.json

Hook configuration template (merged into settings.json):

```json
{
  "hooks": {
    "SessionStart": [{"matcher": "", "hooks": [{"type": "command", "command": "~/.claude/scripts/tracker.sh"}]}],
    "SessionEnd": [{"matcher": "", "hooks": [{"type": "command", "command": "~/.claude/scripts/tracker.sh"}]}],
    "UserPromptSubmit": [{"matcher": "", "hooks": [{"type": "command", "command": "~/.claude/scripts/tracker.sh"}]}],
    "Stop": [{"matcher": "", "hooks": [
      {"type": "command", "command": "~/.claude/scripts/notify.sh"},
      {"type": "command", "command": "~/.claude/scripts/tracker.sh"}
    ]}],
    "PermissionRequest": [{"matcher": "", "hooks": [
      {"type": "command", "command": "~/.claude/scripts/notify.sh"},
      {"type": "command", "command": "~/.claude/scripts/tracker.sh"}
    ]}]
  }
}
```

### myconfig/awesome/modules/tracker.lua

Key data structure:
```lua
sessions[agent_id] = {
    agent_id = string,      -- Primary key
    window_id = number,     -- For focusing
    agent_type = string,    -- "claude" | "codex" | etc
    project = string,
    started_at = number,
    state = "running" | "idle" | "pending"
}
```

Key functions:
```lua
function M.register(agent_id, window_id, project, agent_type)
function M.set_running(agent_id)
function M.set_idle(agent_id)
function M.set_pending(agent_id)
function M.remove(agent_id)
function M.focus_session(agent_id)
function M.get_active_sessions()
function M.subscribe(callback)
```

---

## Troubleshooting Commands

```bash
# Check if hooks are configured
cat ~/.claude/settings.json | jq '.hooks'

# Check symlink status
ls -la ~/.claude/scripts/

# Test tracker manually
echo "return require('modules.tracker').get_active_sessions()" | awesome-client

# View hook debug log
tail -f ~/.claude/hook_debug.log

# Test notification
echo '{"hook_event_name":"Stop","cwd":"/test"}' | ~/.claude/scripts/notify.sh

# Check auto_config status
cd ~/myconfig && ./auto_config.sh status -p claude-scripts -p claude-hooks
```

---

## Event Reference

| Event | When Triggered | State Action |
|-------|----------------|--------------|
| `SessionStart` | Session begins | `register()` → idle |
| `SessionEnd` | Session exits | `remove()` |
| `UserPromptSubmit` | User sends prompt | `set_running()` |
| `Stop` | Response complete | `set_idle()` |
| `PermissionRequest` | Tool needs approval | `set_pending()` |
| `PreToolUse` | Before tool runs | (no change) |
| `PostToolUse` | After tool runs | (no change) |
| `SubagentStop` | Subagent finishes | (no change) |
| `Notification` | Info notification | (no change) |
| `PreCompact` | Before context trim | (no change) |

---

## Common Issues

### Issue: Widget not updating
**Check**: Is `tracker.init()` called in `rc.lua`?
```bash
grep "tracker.init" ~/.config/awesome/rc.lua
```

### Issue: Notifications not appearing
**Check**: Is `claude.init()` called?
```bash
grep "claude.init" ~/.config/awesome/rc.lua
```

### Issue: Scripts not found
**Check**: Is symlink correct?
```bash
ls -la ~/.claude/scripts/
# Should show: scripts -> /home/user/myconfig/claude/scripts
```

### Issue: Hooks not working
**Check**: Is hooks section in settings.json?
```bash
cat ~/.claude/settings.json | jq '.hooks | keys'
```

### Issue: Window focus not working
**Check**: Is ALACRITTY_WINDOW_ID set?
```bash
echo $ALACRITTY_WINDOW_ID  # Run inside Alacritty
```

---

## For AI Assistants: Implementation Notes

1. **Repository structure**: All config files are in `myconfig/` repo
   - Claude-specific: `myconfig/claude/`
   - AwesomeWM modules: `myconfig/awesome/modules/`

2. **Installation via auto_config.sh**:
   - `claude-scripts`: symlinks scripts directory
   - `claude-hooks`: merges hooks.json into settings.json

3. **agent_id vs window_id**:
   - `agent_id` is the primary key (session_id from Claude)
   - `window_id` is only for focusing windows

4. **State transitions**: Only these events change state:
   - `UserPromptSubmit` → running
   - `Stop` → idle
   - `PermissionRequest` → pending

5. **Generic design**: `tracker.lua` has no Claude-specific logic. All agent-specific logic is in hook scripts.

6. **Cleanup**: Sessions are removed on `SessionEnd` or when window closes.

7. **Dependencies**: jq is required for JSON merging in auto_config.sh
