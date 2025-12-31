# Claude Code + AwesomeWM 集成

将 Claude Code 的会话状态实时显示在 AwesomeWM 状态栏中，支持通知、窗口聚焦和多会话追踪。

## 功能

- **状态栏指示器** - 实时显示所有 Claude 会话状态
  - 󰓕 运行中 (绿色) - Agent 正在工作
  - 󰏤 空闲 (灰色) - 等待用户输入
  - 󰌆 待审批 (黄色) - 需要用户授权
- **桌面通知** - 任务完成、权限请求等事件通知
- **点击跳转** - 点击通知或状态栏可直接跳转到对应终端
- **多会话支持** - 同时追踪多个 Claude 会话
- **任务描述** - Claude 可通过 MCP 更新任务描述，显示在状态栏
- **按 Tag 分组** - 弹出窗口按工作空间分组显示会话

## 架构

```
┌─────────────────────────────────────────────────────────────┐
│  Claude Code                                                 │
│  (触发 Hook 事件: SessionStart, Stop, PermissionRequest...) │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
┌──────────────────────────┐    ┌──────────────────────────────┐
│  Hook Scripts            │    │  MCP Server                   │
│  ~/.claude/scripts/      │    │  ~/.claude/mcp/tracker-server │
│  - tracker.sh            │    │  - update_description 工具    │
│  - notify.sh             │    │  - 自动识别 Claude PID        │
└──────────────────────────┘    └──────────────────────────────┘
              │                               │
              └───────────────┬───────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  AwesomeWM Modules (myconfig/awesome/modules/)               │
│  - tracker.lua: 通用会话追踪器（pid 为主键）                  │
│  - claude.lua:  通知处理和 UI                                 │
│  - widgets.lua: 状态栏组件                                    │
└─────────────────────────────────────────────────────────────┘
```

## 仓库文件结构

```
myconfig/
├── claude/
│   ├── scripts/
│   │   ├── tracker.sh      # 状态追踪脚本
│   │   └── notify.sh       # 通知脚本
│   ├── mcp/
│   │   └── tracker-server.py  # MCP 服务器
│   ├── hooks.json          # Hook 配置模板
│   └── mcp.json            # MCP 配置模板
├── awesome/
│   ├── modules/
│   │   ├── tracker.lua     # 通用会话追踪器
│   │   ├── claude.lua      # Claude 通知处理
│   │   └── widgets.lua     # 状态栏组件
│   └── docs/
│       └── claude-integration/
│           ├── README.md           # 本文档
│           └── AI_ASSISTANT_GUIDE.md
└── auto_config.sh          # 自动配置脚本

~/.claude/
├── scripts/
│   ├── tracker.sh          # 链接到 myconfig/claude/scripts/
│   └── notify.sh
├── mcp/
│   └── tracker-server.py   # MCP 服务器
└── .mcp.json               # MCP 配置
```

## 安装

### 方法一：使用 auto_config.sh（推荐）

```bash
cd ~/myconfig
./auto_config.sh -p claude-scripts -p claude-hooks
```

这会自动：
1. 创建 `~/.claude/scripts/` 目录并链接脚本
2. 将 `hooks.json` 合并到 `~/.claude/settings.json`

### 方法二：手动安装

1. **链接脚本目录**

```bash
mkdir -p ~/.claude
ln -s ~/myconfig/claude/scripts ~/.claude/scripts
chmod +x ~/.claude/scripts/*.sh
```

2. **合并 Hook 配置**

使用 jq 合并配置：
```bash
jq -s '.[0] * .[1]' ~/.claude/settings.json ~/myconfig/claude/hooks.json > /tmp/merged.json
mv /tmp/merged.json ~/.claude/settings.json
```

或手动复制 `hooks.json` 中的 hooks 部分到 `~/.claude/settings.json`。

3. **配置 MCP 服务器**（可选，用于任务描述更新）

```bash
# 链接 MCP 目录
ln -s ~/myconfig/claude/mcp ~/.claude/mcp
chmod +x ~/.claude/mcp/*.py

# 复制 MCP 配置（或合并到现有 .mcp.json）
cp ~/myconfig/claude/mcp.json ~/.claude/.mcp.json
```

4. **重载 AwesomeWM**

```bash
echo 'awesome.restart()' | awesome-client
```

## 事件与状态映射

| 事件 | 状态变化 | 说明 |
|------|---------|------|
| SessionStart | → idle | 新会话注册 |
| UserPromptSubmit | → running | 用户提交问题 |
| Stop | → idle | Agent 完成响应 |
| PermissionRequest | → pending | 等待用户授权 |
| SessionEnd | (移除) | 会话结束 |
| PreToolUse | (不变) | 工具执行前 |
| PostToolUse | (不变) | 工具执行后 |
| SubagentStop | (不变) | 子任务完成 |
| Notification | (不变) | 通知事件 |
| PreCompact | (不变) | 上下文压缩 |

## Tracker API

tracker.lua 使用 **进程 PID** 作为主键，提供通用接口：

```lua
local tracker = require("modules.tracker")

-- 注册新会话
-- pid: Claude 进程 PID
-- project: 项目名称
-- agent_type: agent 类型 ("claude", "codex", "copilot", ...)
-- metadata: 可选元数据表 { claude_session_id = "..." }
tracker.register(pid, project, agent_type, metadata)

-- 状态切换
tracker.set_running(pid)
tracker.set_idle(pid)
tracker.set_pending(pid)

-- 设置任务描述（显示在弹出窗口中）
tracker.set_description(pid, "正在实现用户认证功能")

-- 移除会话
tracker.remove(pid)

-- 聚焦会话窗口
tracker.focus_session(pid)

-- 获取 window_id（从缓存）
local wid = tracker.get_window_id(pid)

-- 获取所有活跃会话
local sessions = tracker.get_active_sessions()
-- 返回: { pid, window_id, agent_type, project, description, state, ... }

-- 订阅状态变化
tracker.subscribe(function()
    -- 状态变化时的回调
end)
```

### 会话数据结构

```lua
{
    pid = number,              -- 主键：Agent 进程 PID
    agent_type = string,       -- "claude" | "codex" | "copilot" | ...
    project = string,          -- 项目名称
    started_at = number,       -- 开始时间戳
    state = string,            -- "running" | "idle" | "pending"
    description = string,      -- 任务描述（可选）
    metadata = {               -- agent 类型特有的元数据
        claude_session_id = string,  -- Claude 专有
    }
}
```

### 设计特点

- **PID 为主键** - 唯一且幂等，Claude 进程 PID 在会话期间不变
- **异步 window_id** - 使用 `awful.spawn.easy_async` 避免阻塞主循环
- **缓存机制** - window_id 缓存定期更新（30秒），`get_active_sessions()` 立即返回
- **进程树遍历** - 自动向上查找拥有窗口的祖先进程（如终端）

## MCP 服务器

`tracker-server.py` 提供 MCP 工具，让 Claude 可以更新自己的任务描述：

```python
# Claude 可以调用这个工具
update_description(description="正在重构认证模块")
```

这个描述会显示在 wibar 的 agent tracker 弹出窗口中，帮助用户区分多个 Claude 会话。

## 扩展其他 Agent

tracker.lua 设计为通用模块，支持任何 agent。只需编写对应的 hook 脚本：

```bash
#!/bin/bash
# 示例：其他 agent 的 hook 脚本

# 查找 agent 主进程 PID（遍历进程树）
find_agent_pid() {
    local pid=$$
    while [ "$pid" -gt 1 ]; do
        local comm=$(cat /proc/$pid/comm 2>/dev/null)
        if [[ "$comm" == "my_agent" ]]; then
            echo "$pid"
            return 0
        fi
        pid=$(awk '{print $4}' /proc/$pid/stat 2>/dev/null)
    done
    return 1
}

agent_pid=$(find_agent_pid)
tracker="require('modules.tracker')"

case "$EVENT" in
    start)
        awesome-client "$tracker.register($agent_pid, 'project', 'my_agent')"
        ;;
    running)
        awesome-client "$tracker.set_running($agent_pid)"
        ;;
    idle)
        awesome-client "$tracker.set_idle($agent_pid)"
        ;;
    end)
        awesome-client "$tracker.remove($agent_pid)"
        ;;
esac
```

## 调试

查看 hook 日志：

```bash
tail -f ~/.claude/hook_debug.log
```

测试 tracker 状态：

```bash
# 查看当前会话
echo "return require('modules.tracker').get_active_sessions()" | awesome-client

# 手动触发状态
echo "require('modules.tracker').set_running(12345)" | awesome-client

# 测试 window_id 查找
echo "return require('modules.tracker').get_window_id(12345)" | awesome-client
```

检查配置状态：

```bash
cd ~/myconfig
./auto_config.sh status -p claude-scripts -p claude-hooks
```

## 依赖

- AwesomeWM 4.3+
- jq (JSON 解析)
- xdotool (窗口查找)
- xclip (剪贴板)
- paplay (通知音效，可选)

## 参考

- [Claude Code Hooks 文档](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [AwesomeWM API](https://awesomewm.org/doc/api/)
