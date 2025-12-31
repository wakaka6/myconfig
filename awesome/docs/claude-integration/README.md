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

## 架构

```
┌─────────────────────────────────────────────────────────────┐
│  Claude Code                                                 │
│  (触发 Hook 事件: SessionStart, Stop, PermissionRequest...) │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Hook Scripts (myconfig/claude/scripts/)                     │
│  - tracker.sh: 事件 → tracker.lua API 调用                   │
│  - notify.sh:  事件 → claude.lua 通知                        │
│  安装后链接到: ~/.claude/scripts/                            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  AwesomeWM Modules (myconfig/awesome/modules/)               │
│  - tracker.lua: 通用会话追踪器                                │
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
│   └── hooks.json          # Hook 配置模板
├── awesome/
│   ├── modules/
│   │   ├── tracker.lua     # 通用会话追踪器
│   │   ├── claude.lua      # Claude 通知处理
│   │   └── widgets.lua     # 状态栏组件
│   └── docs/
│       └── claude-integration/
│           ├── README.md           # 本文档
│           ├── config-reference.json
│           └── AI_ASSISTANT_GUIDE.md
└── auto_config.sh          # 自动配置脚本
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

3. **重载 AwesomeWM**

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

## 文件说明

### myconfig/claude/

| 文件 | 说明 |
|------|------|
| `scripts/tracker.sh` | 将 Claude 事件转换为 tracker.lua API 调用 |
| `scripts/notify.sh` | 将事件转换为桌面通知 |
| `hooks.json` | Hook 配置模板，合并到 settings.json |

### myconfig/awesome/modules/

| 文件 | 说明 |
|------|------|
| `tracker.lua` | 通用会话追踪器，以 agent_id 为主键 |
| `claude.lua` | Claude 专用通知处理和快捷操作 |
| `widgets.lua` | 状态栏 Agent 状态组件 |

## Tracker API

tracker.lua 提供通用接口，可用于任何带 hook 的 agent：

```lua
local tracker = require("modules.tracker")

-- 注册新会话
tracker.register(agent_id, window_id, project, agent_type)

-- 状态切换
tracker.set_running(agent_id)
tracker.set_idle(agent_id)
tracker.set_pending(agent_id)

-- 移除会话
tracker.remove(agent_id)

-- 聚焦会话窗口
tracker.focus_session(agent_id)

-- 获取所有活跃会话
local sessions = tracker.get_active_sessions()

-- 订阅状态变化
tracker.subscribe(function()
    -- 状态变化时的回调
end)
```

## 扩展其他 Agent

tracker.lua 设计为通用模块，支持任何 agent。只需编写对应的 hook 脚本：

```bash
#!/bin/bash
# 示例：其他 agent 的 hook 脚本

# 生成唯一 agent_id（各 agent 自行决定）
agent_id="${MY_AGENT_SESSION_ID:-${ALACRITTY_WINDOW_ID:-$$}}"
window_id="${ALACRITTY_WINDOW_ID:-}"
tracker="require('modules.tracker')"

case "$EVENT" in
    start)
        awesome-client "$tracker.register('$agent_id', '$window_id', 'project', 'my_agent')"
        ;;
    running)
        awesome-client "$tracker.set_running('$agent_id')"
        ;;
    idle)
        awesome-client "$tracker.set_idle('$agent_id')"
        ;;
    end)
        awesome-client "$tracker.remove('$agent_id')"
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
echo "require('modules.tracker').set_running('test-id')" | awesome-client
```

检查配置状态：

```bash
cd ~/myconfig
./auto_config.sh status -p claude-scripts -p claude-hooks
```

## 依赖

- AwesomeWM 4.3+
- jq (JSON 解析)
- xclip (剪贴板)
- paplay (通知音效，可选)

## 参考

- [Claude Code Hooks 文档](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [AwesomeWM API](https://awesomewm.org/doc/api/)
