#!/bin/bash
# Claude Code Hook -> AwesomeWM naughty 通知
# 根据 https://code.claude.com/docs/en/hooks 最佳实践编写

# 注意：不使用 set -e，因为 jq 在没有匹配时返回非零会导致脚本失败
set -u

json=$(cat)
[ -z "$json" ] && exit 0

# 获取 Alacritty 窗口 ID
window_id="${ALACRITTY_WINDOW_ID:-}"

# 获取事件类型
event=$(echo "$json" | jq -r '.hook_event_name // empty')

# 根据事件类型提取相关消息
last_message=""
case "$event" in
    Stop)
        # 从主 session transcript 提取最后一条 assistant 文本消息
        transcript_path=$(echo "$json" | jq -r '.transcript_path // empty') || true
        if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
            last_message=$(tac "$transcript_path" 2>/dev/null | \
                jq -r 'select(.type == "assistant") |
                       .message.content |
                       if type == "array" then .[] else . end |
                       select(.type == "text") | .text // empty' 2>/dev/null | \
                head -1 | head -c 300) || true
        fi
        ;;
    SubagentStop)
        # 从 agent_transcript_path 读取（不是 transcript_path）
        transcript_path=$(echo "$json" | jq -r '.agent_transcript_path // empty') || true
        if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
            last_message=$(tac "$transcript_path" 2>/dev/null | \
                jq -r 'select(.type == "assistant") |
                       .message.content |
                       if type == "array" then .[] else . end |
                       select(.type == "text") | .text // empty' 2>/dev/null | \
                head -1 | head -c 300) || true
        fi
        ;;
    PermissionRequest)
        # 提取工具名称和输入参数摘要
        tool_name=$(echo "$json" | jq -r '.tool_name // empty') || true
        tool_input=$(echo "$json" | jq -c '.tool_input // {}' 2>/dev/null) || true
        # 为常见工具提取关键参数
        case "$tool_name" in
            AskUserQuestion)
                # 解析问题和选项
                questions=$(echo "$tool_input" | jq -r '
                    .questions[] | "❓ " + .question, (.options[] | "  • " + .label)
                ' 2>/dev/null | head -20) || true
                last_message="${questions:-}"
                ;;
            ExitPlanMode)
                # 提取计划标题和目标
                plan=$(echo "$tool_input" | jq -r '.plan // empty' 2>/dev/null) || true
                if [ -n "$plan" ]; then
                    # 提取第一行标题和目标部分
                    title=$(echo "$plan" | grep -m1 "^#" | sed 's/^#* */📋 /') || true
                    goal=$(echo "$plan" | grep -A1 "## 目标" | tail -1 | head -c 100) || true
                    last_message="${title:-计划就绪}"$'\n'"${goal:-}"
                else
                    last_message="计划就绪"
                fi
                ;;
            Bash)
                cmd=$(echo "$tool_input" | jq -r '.command // empty' 2>/dev/null | head -c 100) || true
                last_message="${cmd:-}"
                ;;
            Write|Edit|Read)
                file=$(echo "$tool_input" | jq -r '.file_path // empty' 2>/dev/null) || true
                last_message="${file:-}"
                ;;
            Task)
                desc=$(echo "$tool_input" | jq -r '.description // empty' 2>/dev/null) || true
                last_message="${desc:-}"
                ;;
            WebFetch)
                url=$(echo "$tool_input" | jq -r '.url // empty' 2>/dev/null) || true
                prompt=$(echo "$tool_input" | jq -r '.prompt // empty' 2>/dev/null | head -c 80) || true
                if [ -n "$prompt" ]; then
                    last_message="🌐 ${url:-}"$'\n'"💬 ${prompt}"
                else
                    last_message="${url:-}"
                fi
                ;;
            WebSearch)
                query=$(echo "$tool_input" | jq -r '.query // empty' 2>/dev/null) || true
                last_message="🔍 ${query:-}"
                ;;
            mcp__*)
                # MCP 工具，显示简化的工具名
                last_message="${tool_name#mcp__}"
                ;;
            *)
                last_message=$(echo "$tool_input" | jq -c '.' 2>/dev/null | head -c 100) || true
                ;;
        esac
        ;;
    Notification)
        # 直接使用通知消息
        last_message=$(echo "$json" | jq -r '.message // empty') || true
        ;;
esac

# 构建增强的 JSON 传递给 AwesomeWM
enhanced_json=$(echo "$json" | jq -c \
    --arg wid "${window_id:-}" \
    --arg msg "${last_message:-}" \
    '. + {window_id: $wid, last_message: $msg}') || enhanced_json="$json"

# 调用 awesome-client
awesome-client "require('modules.claude').hook('$(echo -n "$enhanced_json" | base64 -w0)')" || true

exit 0
