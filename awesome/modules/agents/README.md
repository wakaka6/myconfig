# Agents

用于 Claude CLI 的 Agent 配置模块。

## 创建新 Agent

### 1. 创建 Agent 文件

在 `modules/agents/` 目录下创建 `your_agent.lua`：

```lua
local M = {}

M.id = "your_agent"          -- 唯一标识符
M.icon = "󰊕"                  -- 菜单图标
M.label = "你的Agent"         -- 菜单显示名称

-- 可选配置
M.config = {
    tools = "Read,Write",     -- 允许的工具，不设置则无工具
    max_turns = 5,            -- 最大轮次，防止死循环
}

-- 可选：系统提示（定义角色）
M.system_prompt = [[你是一个专业的助手...]]

-- 任务提示（可以是字符串或函数）
-- ctx 包含: date, save_dir, selection
function M.prompt(ctx)
    return "请处理以下内容..."
end

-- 或者静态字符串
-- M.prompt = "请处理以下内容..."

-- 可选：成功回调
function M.on_success(result, ctx)
    return {
        message = "处理完成: " .. result,
        file_path = "/path/to/file",  -- 可选
        action = "open_editor",        -- 可选，支持 "open_editor"
    }
end

return M
```

### 2. 注册 Agent

编辑 `modules/agents/init.lua`，在 `agent_files` 表中添加文件名：

```lua
local agent_files = { "save_notes", "your_agent" }
```

### 3. 添加菜单项

编辑 `modules/claude.lua`，在 `MENU_ITEMS` 表中添加：

```lua
local MENU_ITEMS = {
    -- ...existing items...
    { icon = "󰊕", label = "你的Agent", agent_id = "your_agent" },
}
```

## 可用的 ctx 字段

| 字段 | 说明 | 示例 |
|------|------|------|
| `ctx.date` | 当前日期 | `"2025-12-05"` |
| `ctx.save_dir` | 保存目录 | `"~/Documents/scratchpad/2025-12-05"` |
| `ctx.selection` | 用户选中的文本 | `"..."` |

## 工具权限格式

```lua
M.config = {
    -- 无工具
    tools = nil,

    -- 单个工具
    tools = "Read",

    -- 多个工具
    tools = "Read,Write,Grep",

    -- Bash 子命令限制
    tools = "Bash(git:*,npm:*),Read,Write",
}
```

## 示例：代码审查 Agent

```lua
local M = {}

M.id = "code_review"
M.icon = "󰀫"
M.label = "代码审查"

M.config = {
    max_turns = 3,
}

M.system_prompt = [[你是一个代码审查专家。
- 指出潜在的 bug 和安全问题
- 提供改进建议
- 评估代码质量（1-10分）]]

M.prompt = "请审查以下代码："

return M
```

## 示例：翻译 Agent

```lua
local M = {}

M.id = "translate_zh"
M.icon = "󰗊"
M.label = "翻译成中文"

M.prompt = "将以下内容翻译成中文，保持原有格式："

return M
```
