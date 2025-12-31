-- Agent Session Tracker
-- 通用 agent 会话追踪模块
-- 使用 pid（进程 PID）作为主键，window_id 异步缓存
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
-- sessions[pid] = {
--     pid = number,              -- 主键：Agent 进程 PID
--     agent_type = string,       -- "claude" | "codex" | "copilot" | ...
--     project = string,
--     started_at = number,
--     state = "running" | "idle" | "pending",
--     description = string,      -- 任务描述（可选）
--     metadata = {},             -- agent 类型特有的元数据
-- }
local sessions = {}

-- pid -> window_id 缓存（异步更新）
local window_cache = {}

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

-- 验证进程是否存在（同步，但 /proc 读取极快）
local function process_exists(pid)
	if not pid then
		return false
	end
	return gears.filesystem.file_readable("/proc/" .. pid .. "/stat")
end

-- 异步更新单个 pid 的 window_id 缓存
local function update_window_cache_for_pid(pid, callback)
	if not pid or not process_exists(pid) then
		window_cache[pid] = nil
		if callback then
			callback(nil)
		end
		return
	end

	-- 使用 shell 脚本遍历进程树查找窗口
	local cmd = string.format(
		[[
		pid=%d
		while [ "$pid" -gt 1 ]; do
			wid=$(xdotool search --pid "$pid" 2>/dev/null | head -1)
			if [ -n "$wid" ]; then
				echo "$wid"
				exit 0
			fi
			pid=$(awk '{print $4}' /proc/$pid/stat 2>/dev/null)
		done
	]],
		pid
	)

	awful.spawn.easy_async_with_shell(cmd, function(stdout)
		local wid = tonumber(stdout:match("(%d+)"))
		window_cache[pid] = wid
		if callback then
			callback(wid)
		end
	end)
end

-- 异步更新所有会话的 window_id 缓存
local function update_all_window_cache()
	for pid, _ in pairs(sessions) do
		update_window_cache_for_pid(pid)
	end
end

-- 通过 window ID 聚焦窗口
local function focus_window_by_id(window_id)
	if not window_id then
		return false
	end

	for _, c in ipairs(client.get()) do
		if c.window == window_id then
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

	-- 恢复会话时验证进程存在性
	for pid_str, session in pairs(saved) do
		local pid = tonumber(pid_str)
		if pid and type(session) == "table" and process_exists(pid) then
			sessions[pid] = session
		end
	end

	-- 异步更新窗口缓存
	update_all_window_cache()

	if next(sessions) then
		notify_subscribers()
	end
end

-- 清理无效会话
local function cleanup_invalid_sessions()
	local changed = false
	for pid, _ in pairs(sessions) do
		if not process_exists(pid) then
			sessions[pid] = nil
			window_cache[pid] = nil
			changed = true
		end
	end
	if changed then
		notify_subscribers()
	end
end

---注册新会话（首次出现时调用）
---@param pid number Agent 进程 PID
---@param project string 项目名
---@param agent_type string agent 类型
---@param metadata table|nil agent 类型特有的元数据
function M.register(pid, project, agent_type, metadata)
	pid = tonumber(pid)
	if not pid then
		return
	end

	if not sessions[pid] then
		sessions[pid] = {
			pid = pid,
			agent_type = agent_type or "default",
			project = project or "unknown",
			started_at = os.time(),
			state = "idle",
			description = nil,
			metadata = metadata or {},
		}
		-- 异步获取 window_id
		update_window_cache_for_pid(pid, function()
			notify_subscribers()
		end)
	end
end

-- 验证会话有效性
local function validate_session(pid)
	pid = tonumber(pid)
	local session = sessions[pid]
	if not session then
		return false
	end
	if not process_exists(pid) then
		sessions[pid] = nil
		window_cache[pid] = nil
		notify_subscribers()
		return false
	end
	return true
end

---设置为运行中状态
---@param pid number
function M.set_running(pid)
	pid = tonumber(pid)
	if validate_session(pid) then
		sessions[pid].state = "running"
		notify_subscribers()
	end
end

---设置为空闲状态
---@param pid number
function M.set_idle(pid)
	pid = tonumber(pid)
	if validate_session(pid) then
		sessions[pid].state = "idle"
		notify_subscribers()
	end
end

---设置为待审批状态
---@param pid number
function M.set_pending(pid)
	pid = tonumber(pid)
	if validate_session(pid) then
		sessions[pid].state = "pending"
		notify_subscribers()
	end
end

---设置任务描述
---@param pid number
---@param description string
function M.set_description(pid, description)
	pid = tonumber(pid)
	if validate_session(pid) then
		sessions[pid].description = description
		notify_subscribers()
	end
end

---移除会话
---@param pid number
function M.remove(pid)
	pid = tonumber(pid)
	if pid and sessions[pid] then
		sessions[pid] = nil
		window_cache[pid] = nil
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

	for pid, session in pairs(sessions) do
		local config = get_agent_config(session.agent_type)
		table.insert(result, {
			pid = pid,
			window_id = window_cache[pid], -- 从缓存读取
			agent_type = session.agent_type,
			agent_icon = config.icon,
			agent_name = config.name,
			project = session.project,
			description = session.description,
			started_at = session.started_at,
			duration = now - session.started_at,
			duration_str = format_duration(now - session.started_at),
			state = session.state,
			metadata = session.metadata,
		})
	end

	table.sort(result, function(a, b)
		return a.started_at > b.started_at
	end)

	return result
end

---聚焦会话窗口
---@param pid number
---@return boolean
function M.focus_session(pid)
	pid = tonumber(pid)
	if not pid then
		return false
	end

	-- 优先使用缓存
	local window_id = window_cache[pid]
	if window_id then
		return focus_window_by_id(window_id)
	end

	-- 缓存未命中，异步获取后聚焦
	update_window_cache_for_pid(pid, function(wid)
		if wid then
			focus_window_by_id(wid)
		end
	end)
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

---获取 window_id（供外部使用）
---@param pid number
---@return number|nil
function M.get_window_id(pid)
	return window_cache[tonumber(pid)]
end

---初始化模块
function M.init()
	-- 使用 startup 信号恢复会话
	awesome.connect_signal("startup", function()
		restore_sessions()
	end)

	-- 在 awesome 退出/重载前保存会话
	awesome.connect_signal("exit", function()
		save_sessions()
	end)

	-- 定期清理无效会话并更新窗口缓存
	gears.timer({
		timeout = 30,
		autostart = true,
		callback = function()
			cleanup_invalid_sessions()
			update_all_window_cache()
		end,
	})
end

return M
