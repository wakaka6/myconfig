--[[
    Tag Persistence Module
    保存和恢复动态创建的 tags 及窗口布局
--]]

local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local json = require("lib.dkjson")

local M = {}

-- Layout 名称到对象的映射表（懒加载，因为 awful.layout.layouts 在 rc.lua 中稍后设置）
local layout_by_name = nil
local function get_layout_by_name()
	if not layout_by_name then
		layout_by_name = {}
		for _, layout in ipairs(awful.layout.layouts) do
			layout_by_name[awful.layout.getname(layout)] = layout
		end
	end
	return layout_by_name
end

-- 持久化文件路径
local cache_dir = gears.filesystem.get_cache_dir()
local persist_file = cache_dir .. "dynamic_tags.json"
local clients_file = cache_dir .. "tag_clients.json"

-- 待恢复的窗口映射（用于延迟匹配）
local pending_restore = {}

-- 获取屏幕输出名称
local function get_screen_output(s)
	if s.outputs then
		for name, _ in pairs(s.outputs) do
			return name
		end
	end
	return tostring(s.index)
end

-- 生成窗口唯一标识符（用于匹配）
-- 使用 window_id，在 AwesomeWM 重载时保持不变
local function get_client_id(c)
	return c.window
end

-- 保存所有窗口与 tag 的对应关系
-- 格式: { window_id = { screen_output, tag_name }, ... }
local function save_clients()
	local data = {}

	for s in screen do
		local output = get_screen_output(s)
		for _, t in ipairs(s.tags) do
			for _, c in ipairs(t:clients()) do
				local wid = get_client_id(c)
				if wid then
					data[tostring(wid)] = {
						screen = output,
						tag = t.name,
					}
				end
			end
		end
	end

	-- 写入文件
	local file = io.open(clients_file, "w")
	if file then
		file:write(json.encode(data))
		file:close()
	end
end

-- 保存动态 tags 到文件
function M.save()
	local data = {}

	for s in screen do
		local output = get_screen_output(s)
		data[output] = {}

		for _, t in ipairs(s.tags) do
			-- 标记为动态创建的 tag
			if t.dynamic then
				table.insert(data[output], {
					name = t.name,
					layout = awful.layout.getname(t.layout),
					index = t.index,
				})
			end
		end
	end

	-- 写入文件
	local file = io.open(persist_file, "w")
	if file then
		file:write(json.encode(data))
		file:close()
	end

	-- 同时保存窗口信息
	save_clients()
end

-- 查找屏幕（遍历所有 outputs，不只是第一个）
local function find_screen_by_output(output_name)
	for s in screen do
		if s.outputs then
			for k, _ in pairs(s.outputs) do
				if k == output_name then
					return s
				end
			end
		end
	end
	return nil
end

-- 加载窗口恢复数据
local function load_clients_data()
	local file = io.open(clients_file, "r")
	if not file then
		return nil
	end

	local content = file:read("*all")
	file:close()

	if not content or content == "" then
		return nil
	end

	return json.decode(content)
end

-- 尝试将窗口移动到正确的 tag
local function try_restore_client(c)
	local wid = get_client_id(c)
	if not wid then
		return false
	end

	local info = pending_restore[tostring(wid)]
	if not info then
		return false
	end

	-- 找到目标屏幕和 tag
	local target_screen = find_screen_by_output(info.screen)
	if not target_screen then
		return false
	end

	for _, t in ipairs(target_screen.tags) do
		if t.name == info.tag then
			c:move_to_tag(t)
			-- 从待恢复列表中移除
			pending_restore[tostring(wid)] = nil
			return true
		end
	end

	return false
end

-- 从文件恢复动态 tags
function M.restore()
	local file = io.open(persist_file, "r")
	if not file then
		return
	end

	local content = file:read("*all")
	file:close()

	if not content or content == "" then
		return
	end

	local data = json.decode(content)
	if type(data) ~= "table" then
		return
	end

	for output, tags in pairs(data) do
		-- 找到对应屏幕（精确匹配 output 名称）
		local target_screen = find_screen_by_output(output)

		if target_screen and type(tags) == "table" then
			for _, tag_info in ipairs(tags) do
				-- 检查是否已存在
				local exists = false
				for _, t in ipairs(target_screen.tags) do
					if t.name == tag_info.name then
						exists = true
						break
					end
				end

				if not exists then
					-- 恢复保存的 layout，如果找不到则使用 tile
					local saved_layout = get_layout_by_name()[tag_info.layout] or awful.layout.suit.tile
					local t = awful.tag.add(tag_info.name, {
						screen = target_screen,
						layout = saved_layout,
					})
					t.dynamic = true -- 标记为动态

					-- 尝试移动到正确位置
					if tag_info.index and tag_info.index <= #target_screen.tags then
						t.index = tag_info.index
					end
				end
			end
		end
	end

	-- 加载窗口恢复数据
	pending_restore = load_clients_data() or {}

	-- 使用 startup 信号恢复窗口位置
	-- 此时所有窗口已完成 manage
	awesome.connect_signal("startup", function()
		for c in awful.client.iterate(function() return true end) do
			try_restore_client(c)
		end
	end)
end

-- 初始化：监听新窗口创建事件，尝试恢复位置
function M.init()
	-- 启动期间不通过 manage 信号恢复，由 restore() 统一处理
	client.connect_signal("manage", function(c)
		-- 只在非启动期间处理（运行时新窗口）
		if not awesome.startup then
			try_restore_client(c)
		end
	end)

	-- 定期保存（每 30 秒）
	gears.timer.start_new(30, function()
		M.save()
		return true
	end)

	-- 在 awesome 退出/重载前保存最新状态
	awesome.connect_signal("exit", function()
		M.save()
	end)
end

-- 创建动态 tag（带持久化标记）
function M.create_tag(name, s)
	local t = awful.tag.add(name, {
		screen = s or awful.screen.focused(),
		layout = awful.layout.suit.tile,
	})
	t.dynamic = true -- 标记为动态创建
	t:view_only()
	M.save() -- 保存
	return t
end

-- 删除 tag（并更新持久化）
function M.delete_tag(t)
	if t then
		t:delete()
		M.save() -- 保存
	end
end

-- 重命名 tag（并更新持久化）
function M.rename_tag(t, new_name)
	if t and new_name then
		t.name = new_name
		M.save() -- 保存
	end
end

return M
