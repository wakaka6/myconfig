#!/bin/bash
# Claude Agent Tracker Hook
# 职责：将 Claude 事件转换为明确的 tracker 接口调用
# 使用 Claude 进程 PID 作为主键，session_id 作为 metadata
set -u

json=$(cat)
[ -z "$json" ] && exit 0

# 查找 Claude 主进程 PID（遍历进程树向上查找）
find_claude_pid() {
    local pid=$$
    while [ "$pid" -gt 1 ]; do
        local comm=$(cat /proc/$pid/comm 2>/dev/null)
        if [[ "$comm" == "claude" ]]; then
            echo "$pid"
            return 0
        fi
        # 获取父进程 PID（stat 文件第 4 个字段）
        pid=$(awk '{print $4}' /proc/$pid/stat 2>/dev/null)
    done
    return 1
}

claude_pid=$(find_claude_pid)
[ -z "$claude_pid" ] && exit 0

# session_id 作为 metadata 传递
session_id=$(echo "$json" | jq -r '.session_id // empty')

event=$(echo "$json" | jq -r '.hook_event_name // empty')
cwd=$(echo "$json" | jq -r '.cwd // empty')
project=$(basename "$cwd" 2>/dev/null || echo "unknown")

tracker="require('modules.tracker')"

# Claude 事件 → 明确的 tracker 接口调用
# 事件分类：
#   [RUNNING] 触发运行状态的事件
#   [IDLE]    触发空闲状态的事件
#   [PENDING] 触发待审批状态的事件
#   [REMOVE]  触发移除会话的事件
#   [NOOP]    仅追踪，不改变状态的事件
case "$event" in
    # === 会话生命周期 ===
    SessionStart)
        # 注册新会话，初始状态 idle
        # metadata 包含 claude_session_id
        metadata="{claude_session_id='$session_id'}"
        awesome-client "$tracker.register($claude_pid, '$project', 'claude', $metadata)"
        ;;
    SessionEnd)
        # [REMOVE] 会话结束，移除
        awesome-client "$tracker.remove($claude_pid)"
        ;;

    # === 触发 RUNNING 状态的事件 ===
    UserPromptSubmit)
        # [RUNNING] 用户提交问题 → 开始工作
        awesome-client "$tracker.set_running($claude_pid)"
        ;;

    # === 触发 IDLE 状态的事件 ===
    Stop)
        # [IDLE] 主 agent 完成响应，等待用户输入
        awesome-client "$tracker.set_idle($claude_pid)"
        ;;

    # === 触发 PENDING 状态的事件 ===
    PermissionRequest)
        # [PENDING] 等待用户审批
        awesome-client "$tracker.set_pending($claude_pid)"
        ;;

    # === 仅追踪，不改变状态的事件 ===
    PreToolUse)
        # [NOOP] 工具即将执行 - 已经是 running 状态
        # 可用于追踪工具调用详情
        ;;
    PostToolUse)
        # [NOOP] 工具执行完成 - 继续保持 running
        # 可用于追踪工具执行结果
        ;;
    SubagentStop)
        # [NOOP] 子任务完成 - 主 agent 状态不变
        # 可用于追踪子任务完成情况
        ;;
    Notification)
        # [NOOP] 通知事件 - 不代表工作状态
        # 可用于追踪通知内容
        ;;
    PreCompact)
        # [NOOP] 上下文压缩前 - 不影响工作状态
        # 可用于追踪上下文管理
        ;;
esac 2>/dev/null || true

exit 0
