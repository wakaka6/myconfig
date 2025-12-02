--[[
    Environment Detection Module
    自动检测显示器数量并返回对应的环境配置
    使用屏幕角色而非硬编码输出名称
--]]

local awful = require("awful")

local M = {}

-- 环境类型
M.ENV_SINGLE = "single"
M.ENV_HOME = "home"
M.ENV_OFFICE = "office"

-- 屏幕角色
M.ROLE_PRIMARY = "primary" -- 主屏（开发主力）
M.ROLE_SECONDARY = "secondary" -- 副屏（浏览器/聊天）
M.ROLE_TERTIARY = "tertiary" -- 第三屏（debug/db/远程）

-- 根据显示器数量检测环境
function M.detect()
	local screen_count = screen.count()

	if screen_count >= 3 then
		return M.ENV_OFFICE
	elseif screen_count == 2 then
		return M.ENV_HOME
	else
		return M.ENV_SINGLE
	end
end

-- 获取屏幕的分辨率（像素总数）
local function get_screen_pixels(s)
	local geo = s.geometry
	return geo.width * geo.height
end

-- 获取屏幕角色
-- primary: xrandr 设置的主屏
-- secondary: 非 primary 中分辨率较小的（通常是 1080p 副屏）
-- tertiary: 非 primary 中分辨率较大的（通常是带鱼屏）
function M.get_screen_role(s)
	-- 主屏直接返回
	if s == screen.primary then
		return M.ROLE_PRIMARY
	end

	-- 单屏或双屏情况
	if screen.count() <= 2 then
		return M.ROLE_SECONDARY
	end

	-- 三屏情况：收集非 primary 屏幕
	local others = {}
	for other in screen do
		if other ~= screen.primary then
			table.insert(others, other)
		end
	end

	-- 按分辨率排序（小的在前）
	table.sort(others, function(a, b)
		return get_screen_pixels(a) < get_screen_pixels(b)
	end)

	-- 分辨率小的是 secondary，大的是 tertiary
	if s == others[1] then
		return M.ROLE_SECONDARY
	else
		return M.ROLE_TERTIARY
	end
end

-- 根据角色获取屏幕对象
function M.get_screen_by_role(role)
	for s in screen do
		if M.get_screen_role(s) == role then
			return s
		end
	end
	return screen.primary
end

-- 获取指定屏幕的 tags
function M.get_tags(env, s, total_screens)
	local role = M.get_screen_role(s)

	if env == M.ENV_OFFICE then
		-- 公司三屏配置
		if role == M.ROLE_PRIMARY then
			return { "proj-main" }
		elseif role == M.ROLE_SECONDARY then
			return { "web", "chat", "misc" }
		else -- ROLE_TERTIARY
			return { "debug", "db", "rdp" }
		end
	elseif env == M.ENV_HOME then
		-- 家里双屏配置
		if role == M.ROLE_PRIMARY then
			return { "web", "chat", "misc", "debug", "rdp", "db" }
		else
			return { "1", "2", "3", "4", "5" }
		end
	else
		-- 单屏配置
		return { "web", "chat", "misc", "debug", "rdp", "db", "7", "8", "9", "0" }
	end
end

-- 根据 tag 名称查找其所在的屏幕
function M.get_screen_by_tag(tag_name)
	for s in screen do
		for _, t in ipairs(s.tags) do
			if t.name == tag_name then
				return s
			end
		end
	end
	return screen.primary
end

-- 获取指定屏幕的默认布局
function M.get_default_layout(env, s)
	local role = M.get_screen_role(s)

	if env == M.ENV_OFFICE then
		-- 副屏（浏览器/聊天）用 max 布局
		if role == M.ROLE_SECONDARY then
			return awful.layout.suit.max
		else
			return awful.layout.suit.tile
		end
	else
		return awful.layout.suit.tile
	end
end

return M
