-- Agent Session Tracker
-- 通用 agent 会话追踪模块
-- 只提供通用接口，不包含任何 Agent 特有逻辑
local awful = require("awful")
local gears = require("gears")
local json = require("lib.dkjson")

local M = {}

-- 持久化文件路径
local PERSIST_FILE = gears.filesystem.get_cache_dir() .. "tracker_sessions.json"

-- 支持的 agent 类型及其图标
local AGENT_TYPES = {
	claude = { icon = "󱜚 ", name = "Claude" },
	codex = { icon = "󰧑 ", name = "Codex" },
	copilot = { icon = "󰚩 ", name = "Copilot" },
	default = { icon = "󰚩 ", name = "Agent" },
}

-- 会话记录表
-- sessions[agent_id] = {
--     agent_id = string,      -- 由 hook 脚本生成的唯一标识
--     window_id = number,     -- 用于聚焦窗口
--     agent_type = string,    -- "claude" | "codex" | "copilot" | ...
--     project = string,
--     started_at = number,
--     state = "running" | "idle" | "pending"
-- }
local sessions = {}

-- 订阅者列表
local subscribers = {}

-- 获取 agent 配置
local function get_agent_config(agent_type)
	return AGENT_TYPES[agent_type] or AGENT_TYPES.default
end

-- 通知所有订阅者
local function notify_subscribers()
	for _, callback in ipairs(subscribers) do
		pcall(callback)
	end
end

-- 通过 window ID 聚焦窗口
local function focus_window_by_id(window_id)
	if not window_id then
		return false
	end
	local id = tonumber(window_id)
	if not id then
		return false
	end

	for _, c in ipairs(client.get()) do
		if c.window == id then
			if c.hidden then
				c.hidden = false
			end
			if c.first_tag then
				c.first_tag:view_only()
			end
			c:emit_signal("request::activate", "tracker", { raise = true })
			return true
		end
	end
	return false
end

-- 验证窗口是否存在
local function window_exists(window_id)
	if not window_id then
		return false
	end
	for _, c in ipairs(client.get()) do
		if c.window == window_id then
			return true
		end
	end
	return false
end

-- 格式化时长显示
local function format_duration(seconds)
	local hours = math.floor(seconds / 3600)
	local mins = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60

	if hours > 0 then
		return string.format("%d:%02d:%02d", hours, mins, secs)
	else
		return string.format("%02d:%02d", mins, secs)
	end
end

-- 保存会话到文件
local function save_sessions()
	local file = io.open(PERSIST_FILE, "w")
	if file then
		file:write(json.encode(sessions))
		file:close()
	end
end

-- 从文件恢复会话
local function restore_sessions()
	local file = io.open(PERSIST_FILE, "r")
	if not file then
		return
	end
	local content = file:read("*a")
	file:close()

	if not content or content == "" then
		return
	end

	local saved = json.decode(content)
	if type(saved) ~= "table" then
		return
	end

	-- 恢复会话时验证窗口存在性，只恢复有效会话
	for agent_id, session in pairs(saved) do
		if agent_id and type(session) == "table" then
			if session.window_id and window_exists(session.window_id) then
				sessions[agent_id] = session
			end
		end
	end

	-- 如有恢复的会话，通知订阅者
	if next(sessions) then
		notify_subscribers()
	end
end

---注册新会话（首次出现时调用）
---@param agent_id string 由 hook 脚本生成的唯一标识
---@param window_id string|number 窗口 ID
---@param project string 项目名
---@param agent_type string agent 类型
function M.register(agent_id, window_id, project, agent_type)
	if not agent_id or agent_id == "" then
		return
	end
	local wid = tonumber(window_id)

	if not sessions[agent_id] then
		sessions[agent_id] = {
			agent_id = agent_id,
			window_id = wid,
			agent_type = agent_type or "default",
			project = project or "unknown",
			started_at = os.time(),
			state = "idle", -- 新会话默认 idle
		}
		notify_subscribers()
	end
end

-- 验证会话有效性（兜底：无 window_id 或窗口不存在则移除）
local function validate_session(agent_id)
	local session = sessions[agent_id]
	if not session then
		return false
	end
	if not session.window_id or not window_exists(session.window_id) then
		sessions[agent_id] = nil
		notify_subscribers()
		return false
	end
	return true
end

---设置为运行中状态
---@param agent_id string
function M.set_running(agent_id)
	if validate_session(agent_id) then
		sessions[agent_id].state = "running"
		notify_subscribers()
	end
end

---设置为空闲状态
---@param agent_id string
function M.set_idle(agent_id)
	if validate_session(agent_id) then
		sessions[agent_id].state = "idle"
		notify_subscribers()
	end
end

---设置为待审批状态
---@param agent_id string
function M.set_pending(agent_id)
	if validate_session(agent_id) then
		sessions[agent_id].state = "pending"
		notify_subscribers()
	end
end

---移除会话
---@param agent_id string
function M.remove(agent_id)
	if agent_id and sessions[agent_id] then
		sessions[agent_id] = nil
		notify_subscribers()
	end
end

---获取运行中的会话数量
---@return number
function M.get_running_count()
	local count = 0
	for _, session in pairs(sessions) do
		if session.state == "running" then
			count = count + 1
		end
	end
	return count
end

---获取空闲的会话数量
---@return number
function M.get_idle_count()
	local count = 0
	for _, session in pairs(sessions) do
		if session.state == "idle" then
			count = count + 1
		end
	end
	return count
end

---获取待审批的会话数量
---@return number
function M.get_pending_count()
	local count = 0
	for _, session in pairs(sessions) do
		if session.state == "pending" then
			count = count + 1
		end
	end
	return count
end

---获取所有活跃会话
---@return table[]
function M.get_active_sessions()
	local result = {}
	local now = os.time()

	for aid, session in pairs(sessions) do
		local config = get_agent_config(session.agent_type)
		table.insert(result, {
			agent_id = aid,
			window_id = session.window_id,
			agent_type = session.agent_type,
			agent_icon = config.icon,
			agent_name = config.name,
			project = session.project,
			started_at = session.started_at,
			duration = now - session.started_at,
			duration_str = format_duration(now - session.started_at),
			state = session.state,
		})
	end

	-- 按开始时间排序（最新的在前）
	table.sort(result, function(a, b)
		return a.started_at > b.started_at
	end)

	return result
end

---聚焦会话窗口
---@param agent_id string
---@return boolean
function M.focus_session(agent_id)
	local session = sessions[agent_id]
	if session and session.window_id then
		return focus_window_by_id(session.window_id)
	end
	return false
end

---订阅状态变化
---@param callback function
function M.subscribe(callback)
	table.insert(subscribers, callback)
end

---获取 agent 图标
---@param agent_type string
---@return string
function M.get_agent_icon(agent_type)
	return get_agent_config(agent_type).icon
end

---初始化模块
function M.init()
	-- 使用 startup 信号恢复会话
	-- AwesomeWM 进入事件循环时，所有窗口已被管理
	awesome.connect_signal("startup", function()
		restore_sessions()
	end)

	-- 在 awesome 退出/重载前保存会话
	awesome.connect_signal("exit", function()
		save_sessions()
	end)

	-- 监听窗口关闭事件，清理该窗口的所有会话（备用机制）
	client.connect_signal("unmanage", function(c)
		local wid = c.window
		local changed = false
		for aid, session in pairs(sessions) do
			if session.window_id == wid then
				sessions[aid] = nil
				changed = true
			end
		end
		if changed then
			notify_subscribers()
		end
	end)
end

return M
