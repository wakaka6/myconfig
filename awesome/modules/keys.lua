--[[
    Keybindings Module
    Vim-style keybindings migrated from i3wm
--]]

local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")
local beautiful = require("beautiful")
local scratchpad = require("modules.scratchpad")
local tag_persist = require("modules.tag_persist")
local claude = require("modules.claude")

local M = {}

local modkey = "Mod4"

-- Helper: Volume control
local function volume_control(action)
	if action == "up" then
		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
		naughty.notify({ text = "Volume +5%", timeout = 1 })
	elseif action == "down" then
		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
		naughty.notify({ text = "Volume -5%", timeout = 1 })
	elseif action == "mute" then
		awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
		naughty.notify({ text = "Volume Mute Toggle", timeout = 1 })
	end
end

-- Helper: Brightness control
local function brightness_control(action)
	if action == "up" then
		awful.spawn("xbacklight -inc 10")
		naughty.notify({ text = "Brightness +10%", timeout = 1 })
	elseif action == "down" then
		awful.spawn("xbacklight -dec 10")
		naughty.notify({ text = "Brightness -10%", timeout = 1 })
	end
end

-- 记录每个屏幕上最后聚焦的窗口（用于跨屏返回时恢复）
local last_focused_client = {}

-- 记录当前聚焦的屏幕（用于判断是否是跨屏切换导致的焦点变化）
local current_focused_screen = nil

-- 监听焦点变化，记录每个屏幕的最后聚焦窗口
client.connect_signal("focus", function(c)
	if c.screen then
		local client_screen = c.screen.index
		-- 只有当窗口所在屏幕是当前聚焦屏幕时才记录
		-- 这样可以避免跨屏切换时错误覆盖记录
		local focused_screen = awful.screen.focused()
		if focused_screen and focused_screen.index == client_screen then
			last_focused_client[client_screen] = c
		end
	end
end)

-- Helper: 检查当前布局是否为 max 类型
local function is_max_layout(s)
	local tag = s and s.selected_tag
	if not tag then
		return false
	end
	return tag.layout == awful.layout.suit.max or tag.layout == awful.layout.suit.max.fullscreen
end

-- Helper: 获取当前窗口在指定方向上的其他窗口
local function get_clients_in_direction(c, dir)
	local dominated = {}
	local c_geo = c:geometry()

	for _, other in ipairs(c.screen.clients) do
		if other ~= c and not other.minimized then
			local other_geo = other:geometry()
			local in_dir = false

			if dir == "left" then
				in_dir = other_geo.x + other_geo.width <= c_geo.x
			elseif dir == "right" then
				in_dir = other_geo.x >= c_geo.x + c_geo.width
			elseif dir == "up" then
				in_dir = other_geo.y + other_geo.height <= c_geo.y
			elseif dir == "down" then
				in_dir = other_geo.y >= c_geo.y + c_geo.height
			end

			if in_dir then
				table.insert(dominated, other)
			end
		end
	end

	return dominated
end

-- Helper: 移动鼠标到屏幕中心
local function move_mouse_to_screen_center(s)
	local geo = s.geometry
	mouse.coords({
		x = geo.x + geo.width / 2,
		y = geo.y + geo.height / 2
	}, true)
end

-- Helper: 聚焦目标屏幕上的窗口（根据目标屏幕布局决定策略）
local function focus_client_on_screen(target_screen, dir)
	-- 优先：全屏窗口
	for _, c in ipairs(target_screen.clients) do
		if c.fullscreen and not c.minimized then
			c:emit_signal("request::activate", "focus_direction", { raise = true })
			return
		end
	end

	-- max 布局：优先恢复上次聚焦的窗口
	if is_max_layout(target_screen) then
		local last_client = last_focused_client[target_screen.index]
		if last_client and last_client.valid and not last_client.minimized and last_client.screen == target_screen then
			last_client:emit_signal("request::activate", "focus_direction", { raise = true })
			return
		end
		-- 回退：选第一个非最小化窗口
		for _, c in ipairs(target_screen.clients) do
			if not c.minimized then
				c:emit_signal("request::activate", "focus_direction", { raise = true })
				return
			end
		end
		move_mouse_to_screen_center(target_screen)
		return
	end

	-- tile/floating 布局：按进入方向选择边缘窗口
	local clients = target_screen.clients
	if #clients == 0 then
		move_mouse_to_screen_center(target_screen)
		return
	end

	local target = nil
	for _, c in ipairs(clients) do
		if not c.minimized then
			local c_geo = c:geometry()
			if dir == "left" then
				-- 从左边进入（按 h 循环），选最右边的窗口
				if target == nil or c_geo.x > target:geometry().x then
					target = c
				end
			elseif dir == "right" then
				-- 从右边进入（按 l 循环），选最左边的窗口
				if target == nil or c_geo.x < target:geometry().x then
					target = c
				end
			elseif dir == "up" then
				-- 从上边进入，选最下边的窗口
				if target == nil or c_geo.y > target:geometry().y then
					target = c
				end
			elseif dir == "down" then
				-- 从下边进入，选最上边的窗口
				if target == nil or c_geo.y < target:geometry().y then
					target = c
				end
			end
		end
	end

	if target then
		target:emit_signal("request::activate", "focus_direction", { raise = true })
	end
end

-- Helper: 按物理方向查找相邻屏幕（支持循环）
local function get_screen_in_direction(s, dir)
	if not s then
		return nil
	end

	-- 单屏幕时不需要切换
	if screen.count() <= 1 then
		return nil
	end

	local geo = s.geometry
	local target = nil
	local best_distance = math.huge

	-- 首先尝试找物理方向上的相邻屏幕
	for other_screen in screen do
		if other_screen ~= s then
			local other_geo = other_screen.geometry
			local dominated = false
			local distance = 0

			if dir == "left" then
				if other_geo.x + other_geo.width <= geo.x then
					local overlap = math.min(geo.y + geo.height, other_geo.y + other_geo.height)
						- math.max(geo.y, other_geo.y)
					if overlap > 0 then
						distance = geo.x - (other_geo.x + other_geo.width)
						dominated = true
					end
				end
			elseif dir == "right" then
				if other_geo.x >= geo.x + geo.width then
					local overlap = math.min(geo.y + geo.height, other_geo.y + other_geo.height)
						- math.max(geo.y, other_geo.y)
					if overlap > 0 then
						distance = other_geo.x - (geo.x + geo.width)
						dominated = true
					end
				end
			elseif dir == "up" then
				if other_geo.y + other_geo.height <= geo.y then
					local overlap = math.min(geo.x + geo.width, other_geo.x + other_geo.width)
						- math.max(geo.x, other_geo.x)
					if overlap > 0 then
						distance = geo.y - (other_geo.y + other_geo.height)
						dominated = true
					end
				end
			elseif dir == "down" then
				if other_geo.y >= geo.y + geo.height then
					local overlap = math.min(geo.x + geo.width, other_geo.x + other_geo.width)
						- math.max(geo.x, other_geo.x)
					if overlap > 0 then
						distance = other_geo.y - (geo.y + geo.height)
						dominated = true
					end
				end
			end

			if dominated and distance < best_distance then
				best_distance = distance
				target = other_screen
			end
		end
	end

	-- 如果找到了相邻屏幕，返回它
	if target then
		return target
	end

	-- 没有找到相邻屏幕，实现循环：找对侧最远端的屏幕
	-- 按 left 在最左边 → 去最右边屏幕
	-- 按 right 在最右边 → 去最左边屏幕
	local wrap_target = nil
	local wrap_distance = -math.huge

	for other_screen in screen do
		if other_screen ~= s then
			local other_geo = other_screen.geometry

			if dir == "left" or dir == "right" then
				local overlap = math.min(geo.y + geo.height, other_geo.y + other_geo.height)
					- math.max(geo.y, other_geo.y)
				if overlap > 0 then
					if dir == "left" then
						-- 按 left 循环：找最右边的屏幕
						if other_geo.x + other_geo.width > wrap_distance then
							wrap_distance = other_geo.x + other_geo.width
							wrap_target = other_screen
						end
					else
						-- 按 right 循环：找最左边的屏幕
						if wrap_target == nil or other_geo.x < wrap_target.geometry.x then
							wrap_target = other_screen
						end
					end
				end
			else
				local overlap = math.min(geo.x + geo.width, other_geo.x + other_geo.width)
					- math.max(geo.x, other_geo.x)
				if overlap > 0 then
					if dir == "up" then
						-- 按 up 循环：找最下面的屏幕
						if other_geo.y + other_geo.height > wrap_distance then
							wrap_distance = other_geo.y + other_geo.height
							wrap_target = other_screen
						end
					else
						-- 按 down 循环：找最上面的屏幕
						if wrap_target == nil or other_geo.y < wrap_target.geometry.y then
							wrap_target = other_screen
						end
					end
				end
			end
		end
	end

	return wrap_target
end

-- Helper: 智能跨屏幕焦点切换
-- 源屏幕布局决定何时离开，目标屏幕布局决定聚焦哪个窗口
local function focus_global_direction(dir)
	local old_client = client.focus
	local old_screen = awful.screen.focused()

	-- 没有聚焦窗口时直接跨屏
	if not old_client then
		local target_screen = get_screen_in_direction(old_screen, dir)
		if target_screen then
			awful.screen.focus(target_screen)
			focus_client_on_screen(target_screen, dir)
		end
		return
	end

	-- 判断是否应该直接跨屏（基于源屏幕布局）
	local should_cross_immediately = is_max_layout(old_screen) or old_client.fullscreen

	if should_cross_immediately then
		-- max/fullscreen：直接跨屏
		local target_screen = get_screen_in_direction(old_screen, dir)
		if target_screen then
			awful.screen.focus(target_screen)
			focus_client_on_screen(target_screen, dir)
		end
	else
		-- tile/floating：先检查该方向是否有窗口
		local clients_in_dir = get_clients_in_direction(old_client, dir)

		if #clients_in_dir == 0 then
			-- 到边缘了，跨屏
			local target_screen = get_screen_in_direction(old_screen, dir)
			if target_screen then
				awful.screen.focus(target_screen)
				focus_client_on_screen(target_screen, dir)
			end
		else
			-- 同屏切换
			awful.client.focus.bydirection(dir)
		end
	end

	if client.focus then
		client.focus:raise()
	end
end

-- Global keybindings
M.globalkeys = gears.table.join(
	-- {{{ Help
	awful.key({ modkey }, "F1", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	-- }}}

	-- {{{ Alt-Tab 窗口切换器
	-- Alt+Tab: rofi 窗口切换（推荐，美观）
	awful.key({ "Mod1" }, "Tab", function()
		awful.spawn("rofi -show window -window-format '{c} {t}'")
	end, { description = "window switcher (rofi)", group = "client" }),

	-- Mod+Tab: 快速切换到上一个窗口
	awful.key({ modkey }, "Tab", function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, { description = "go back to previous window", group = "client" }),

	-- Mod+`: 在当前 tag 的窗口间循环
	awful.key({ modkey }, "`", function()
		awful.client.focus.byidx(1)
		if client.focus then
			client.focus:raise()
		end
	end, { description = "cycle through windows", group = "client" }),

	awful.key({ modkey, "Shift" }, "`", function()
		awful.client.focus.byidx(-1)
		if client.focus then
			client.focus:raise()
		end
	end, { description = "cycle through windows (reverse)", group = "client" }),
	-- }}}

	-- }}}

	-- {{{ 动态 Tag 管理
	-- Mod+Ctrl+a: 创建新 tag
	awful.key({ modkey, "Control" }, "a", function()
		awful.prompt.run({
			prompt = "New tag name: ",
			textbox = awful.screen.focused().mypromptbox.widget,
			exe_callback = function(name)
				if name and #name > 0 then
					tag_persist.create_tag(name)
					naughty.notify({ text = "Created tag: " .. name, timeout = 2 })
				end
			end,
		})
	end, { description = "create new tag", group = "tag" }),

	-- Mod+Ctrl+d: 删除当前空 tag
	awful.key({ modkey, "Control" }, "d", function()
		local t = awful.screen.focused().selected_tag
		if not t then
			return
		end

		if #t:clients() > 0 then
			naughty.notify({
				text = "Tag not empty! (" .. #t:clients() .. " windows)",
				timeout = 2,
			})
		else
			local tag_name = t.name
			tag_persist.delete_tag(t)
			naughty.notify({ text = "Deleted tag: " .. tag_name, timeout = 2 })
		end
	end, { description = "delete empty tag", group = "tag" }),

	-- Mod+Ctrl+r: 重命名当前 tag
	awful.key({ modkey, "Control" }, "r", function()
		local t = awful.screen.focused().selected_tag
		if not t then
			return
		end

		awful.prompt.run({
			prompt = "Rename tag (" .. t.name .. "): ",
			textbox = awful.screen.focused().mypromptbox.widget,
			exe_callback = function(new_name)
				if new_name and #new_name > 0 then
					tag_persist.rename_tag(t, new_name)
					naughty.notify({ text = "Renamed to: " .. new_name, timeout = 2 })
				end
			end,
		})
	end, { description = "rename tag", group = "tag" }),

	-- Mod+Ctrl+f: 按名称搜索并切换 tag (rofi)
	awful.key({ modkey, "Control" }, "f", function()
		local s = awful.screen.focused()
		local tags_list = ""
		for i, t in ipairs(s.tags) do
			local occupied = #t:clients() > 0 and " *" or ""
			tags_list = tags_list .. string.format("%d: %s%s\n", i, t.name, occupied)
		end

		awful.spawn.easy_async_with_shell(
			string.format("echo -n '%s' | rofi -dmenu -i -p 'Switch to tag'", tags_list:gsub("'", "\\'")),
			function(stdout)
				local selected = stdout:gsub("\n", "")
				local index = tonumber(selected:match("^(%d+):"))
				if index and s.tags[index] then
					s.tags[index]:view_only()
				end
			end
		)
	end, { description = "search and switch tag (rofi)", group = "tag" }),
	-- }}}

	-- {{{ Client focus (vim-style hjkl) - 智能跨屏幕
	awful.key({ modkey }, "h", function()
		focus_global_direction("left")
	end, { description = "focus left (cross-screen)", group = "client" }),

	awful.key({ modkey }, "j", function()
		focus_global_direction("down")
	end, { description = "focus down (cross-screen)", group = "client" }),

	awful.key({ modkey }, "k", function()
		focus_global_direction("up")
	end, { description = "focus up (cross-screen)", group = "client" }),

	awful.key({ modkey }, "l", function()
		focus_global_direction("right")
	end, { description = "focus right (cross-screen)", group = "client" }),

	-- Arrow keys for tag navigation
	awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous tag", group = "tag" }),
	awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next tag", group = "tag" }),

	-- Focus between screens (like i3's mod+n/p)
	awful.key({ modkey }, "n", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus previous screen", group = "screen" }),

	awful.key({ modkey }, "p", function()
		awful.screen.focus_relative(1)
	end, { description = "focus next screen", group = "screen" }),
	-- }}}

	-- {{{ Client movement (vim-style with Shift)
	-- 智能判断：浮动窗口移动位置，非浮动窗口交换位置
	awful.key({ modkey, "Shift" }, "h", function()
		local c = client.focus
		if not c then
			return
		end
		if c.floating or awful.layout.get(c.screen) == awful.layout.suit.floating then
			c:relative_move(-50, 0, 0, 0)
		else
			awful.client.swap.bydirection("left")
		end
	end, { description = "swap/move left", group = "client" }),

	awful.key({ modkey, "Shift" }, "j", function()
		local c = client.focus
		if not c then
			return
		end
		if c.floating or awful.layout.get(c.screen) == awful.layout.suit.floating then
			c:relative_move(0, 50, 0, 0)
		else
			awful.client.swap.bydirection("down")
		end
	end, { description = "swap/move down", group = "client" }),

	awful.key({ modkey, "Shift" }, "k", function()
		local c = client.focus
		if not c then
			return
		end
		if c.floating or awful.layout.get(c.screen) == awful.layout.suit.floating then
			c:relative_move(0, -50, 0, 0)
		else
			awful.client.swap.bydirection("up")
		end
	end, { description = "swap/move up", group = "client" }),

	awful.key({ modkey, "Shift" }, "l", function()
		local c = client.focus
		if not c then
			return
		end
		if c.floating or awful.layout.get(c.screen) == awful.layout.suit.floating then
			c:relative_move(50, 0, 0, 0)
		else
			awful.client.swap.bydirection("right")
		end
	end, { description = "swap/move right", group = "client" }),

	-- Move client to screen (like i3's mod+shift+n/p)
	awful.key({ modkey, "Shift" }, "n", function()
		if client.focus then
			client.focus:move_to_screen(client.focus.screen.index - 1)
		end
	end, { description = "move to previous screen", group = "client" }),

	awful.key({ modkey, "Shift" }, "p", function()
		if client.focus then
			client.focus:move_to_screen(client.focus.screen.index + 1)
		end
	end, { description = "move to next screen", group = "client" }),
	-- }}}

	-- {{{ Layout manipulation
	-- Like i3's mod+s (stacking) -> use max layout
	awful.key({ modkey }, "s", function()
		awful.layout.set(awful.layout.suit.max)
	end, { description = "set max layout (stacking)", group = "layout" }),

	-- Like i3's mod+w (tabbed) -> use max layout
	awful.key({ modkey }, "w", function()
		awful.layout.set(awful.layout.suit.max)
	end, { description = "set max layout (tabbed)", group = "layout" }),

	-- Like i3's mod+e (toggle split)
	awful.key({ modkey }, "e", function()
		awful.layout.inc(1)
	end, { description = "next layout", group = "layout" }),

	-- Master width factor (like i3 resize)
	awful.key({ modkey, "Control" }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width", group = "layout" }),

	awful.key({ modkey, "Control" }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width", group = "layout" }),

	-- Number of master/column clients
	awful.key({ modkey, "Control" }, "k", function()
		awful.tag.incnmaster(1, nil, true)
		local tag = awful.screen.focused().selected_tag
		if tag then
			naughty.notify({ text = "Master +1 → " .. tag.master_count, timeout = 1 })
		end
	end, { description = "increase master clients", group = "layout" }),

	awful.key({ modkey, "Control" }, "j", function()
		awful.tag.incnmaster(-1, nil, true)
		local tag = awful.screen.focused().selected_tag
		if tag then
			naughty.notify({ text = "Master -1 → " .. tag.master_count, timeout = 1 })
		end
	end, { description = "decrease master clients", group = "layout" }),
	-- }}}

	-- {{{ Launchers
	-- Terminal (mod+Return)
	awful.key({ modkey }, "Return", function()
		awful.spawn("alacritty")
	end, { description = "open terminal", group = "launcher" }),

	-- Rofi (mod+d)
	awful.key({ modkey }, "d", function()
		awful.spawn("rofi -show drun")
	end, { description = "rofi launcher", group = "launcher" }),

	-- Chrome (mod+c)
	awful.key({ modkey }, "c", function()
		awful.spawn("google-chrome-stable")
	end, { description = "open chrome", group = "launcher" }),

	-- Screenshot with flameshot (F1)
	awful.key({}, "F1", function()
		awful.spawn("flameshot gui")
	end, { description = "screenshot", group = "launcher" }),
	-- }}}

	-- {{{ Scratchpads
	awful.key({ modkey }, "t", function()
		scratchpad.toggle("translate")
	end, { description = "toggle translate scratchpad", group = "scratchpad" }),

	awful.key({ modkey }, "g", function()
		scratchpad.toggle("claude")
	end, { description = "toggle claude AI assistant", group = "scratchpad" }),

	awful.key({ modkey }, "o", function()
		scratchpad.toggle("notes")
	end, { description = "toggle notes scratchpad", group = "scratchpad" }),

	awful.key({ modkey }, "/", function()
		claude.query()
	end, { description = "query selected text with Claude", group = "scratchpad" }),
	-- }}}

	-- {{{ 窗口隐藏/恢复 (替代 i3 的 scratchpad hack)
	-- Mod+x: 最小化当前窗口
	awful.key({ modkey }, "x", function()
		if client.focus then
			client.focus.minimized = true
		end
	end, { description = "minimize/hide current window", group = "client" }),

	-- Mod+Shift+x: 智能恢复隐藏窗口
	-- 1个: 直接恢复 | 多个: rofi 选择
	awful.key({ modkey, "Shift" }, "x", function()
		local minimized_clients = {}
		local current_tag = awful.screen.focused().selected_tag

		-- 收集当前 tag 的最小化窗口
		for _, c in ipairs(client.get()) do
			if c.minimized then
				for _, t in ipairs(c:tags()) do
					if t == current_tag then
						table.insert(minimized_clients, c)
						break
					end
				end
			end
		end

		if #minimized_clients == 0 then
			naughty.notify({ text = "No hidden windows", timeout = 1 })
		elseif #minimized_clients == 1 then
			-- 只有 1 个，直接恢复
			minimized_clients[1].minimized = false
			minimized_clients[1]:emit_signal("request::activate", "key.unminimize", { raise = true })
		else
			-- 多个，用 rofi 选择
			local rofi_input = ""
			local client_map = {}
			for i, c in ipairs(minimized_clients) do
				local name = c.name or c.class or "Unknown"
				-- 截断过长的名称
				if #name > 50 then
					name = name:sub(1, 47) .. "..."
				end
				local entry = string.format("%d: [%s] %s", i, c.class or "?", name)
				rofi_input = rofi_input .. entry .. "\n"
				client_map[entry] = c
			end

			awful.spawn.easy_async_with_shell(
				string.format(
					"echo -n '%s' | rofi -dmenu -i -p 'Restore window' -format 's'",
					rofi_input:gsub("'", "\\'")
				),
				function(stdout)
					local selected = stdout:gsub("\n", "")
					if selected and client_map[selected] then
						local c = client_map[selected]
						c.minimized = false
						c:emit_signal("request::activate", "key.unminimize", { raise = true })
					end
				end
			)
		end
	end, { description = "smart restore hidden windows (rofi)", group = "client" }),

	-- Mod+Ctrl+x: 恢复所有隐藏窗口（不询问）
	awful.key({ modkey, "Control" }, "x", function()
		local count = 0
		local current_tag = awful.screen.focused().selected_tag
		for _, c in ipairs(client.get()) do
			if c.minimized then
				for _, t in ipairs(c:tags()) do
					if t == current_tag then
						c.minimized = false
						count = count + 1
						break
					end
				end
			end
		end
		if count > 0 then
			naughty.notify({ text = "Restored " .. count .. " windows", timeout = 1 })
		else
			naughty.notify({ text = "No hidden windows", timeout = 1 })
		end
	end, { description = "restore ALL hidden windows in current tag", group = "client" }),

	-- Mod+space: 在 tiled 和 floating 窗口之间切换焦点
	awful.key({ modkey }, "space", function()
		local current = client.focus
		if not current then
			return
		end

		local s = awful.screen.focused()
		local current_tag = s.selected_tag
		if not current_tag then
			return
		end

		-- 收集当前 tag 的可见窗口，分为 tiled 和 floating
		local tiled_clients = {}
		local floating_clients = {}

		for _, c in ipairs(current_tag:clients()) do
			if not c.minimized and c:isvisible() then
				if c.floating then
					table.insert(floating_clients, c)
				else
					table.insert(tiled_clients, c)
				end
			end
		end

		-- 当前窗口是浮动的，切换到 tiled 窗口
		if current.floating then
			if #tiled_clients > 0 then
				tiled_clients[1]:emit_signal("request::activate", "client.focus.bytype", { raise = true })
			end
		else
			-- 当前窗口是 tiled，切换到浮动窗口
			if #floating_clients > 0 then
				floating_clients[1]:emit_signal("request::activate", "client.focus.bytype", { raise = true })
			end
		end
	end, { description = "toggle focus between tiled and floating", group = "client" }),
	-- }}}

	-- {{{ Volume control (media keys)
	awful.key({}, "XF86AudioRaiseVolume", function()
		volume_control("up")
	end, { description = "volume up", group = "media" }),

	awful.key({}, "XF86AudioLowerVolume", function()
		volume_control("down")
	end, { description = "volume down", group = "media" }),

	awful.key({}, "XF86AudioMute", function()
		volume_control("mute")
	end, { description = "volume mute", group = "media" }),
	-- }}}

	-- {{{ Brightness control
	awful.key({}, "XF86MonBrightnessUp", function()
		brightness_control("up")
	end, { description = "brightness up", group = "media" }),

	awful.key({}, "XF86MonBrightnessDown", function()
		brightness_control("down")
	end, { description = "brightness down", group = "media" }),
	-- }}}

	-- {{{ Awesome control
	awful.key({ modkey, "Shift" }, "c", awesome.restart, { description = "reload awesome", group = "awesome" }),

	awful.key({ modkey, "Shift" }, "r", awesome.restart, { description = "restart awesome", group = "awesome" }),

	awful.key({ modkey, "Shift" }, "e", awesome.quit, { description = "quit awesome", group = "awesome" }),

	-- Lock screen (mod+Escape)
	awful.key({ modkey }, "Escape", function()
		awful.spawn.with_shell("~/.config/i3/lock.sh")
	end, { description = "lock screen", group = "awesome" }),

	-- Restart dunst (mod+shift+d)
	awful.key({ modkey, "Shift" }, "d", function()
		awful.spawn.with_shell("killall -q dunst; notify-send -u low 'restart dunst'")
	end, { description = "restart dunst", group = "awesome" }),
	-- }}}

	-- {{{ Gaps control (i3-gaps style with mode)
	-- Mod+Shift+g: 进入 gaps 模式
	awful.key({ modkey, "Shift" }, "g", function()
		local gaps_notification = naughty.notify({
			title = "Gaps Mode",
			text = "k/+   increase gap\nj/-   decrease gap\n0     remove gaps\nd     default gaps\nEsc   exit",
			timeout = 0,
		})

		local grabber
		grabber = awful.keygrabber.run(function(mod, key, event)
			if event == "release" then
				return
			end

			local tag = awful.screen.focused().selected_tag
			if not tag then
				return
			end

			-- 调试：显示按下的键名
			-- naughty.notify({ text = "Key: " .. key, timeout = 1 })

			if key == "k" or key == "+" or key == "=" or key == "plus" or key == "equal" or key == "KP_Add" then
				tag.gap = tag.gap + 2
				naughty.notify({ text = "Gap: " .. tag.gap, timeout = 1 })
			elseif key == "j" or key == "-" or key == "minus" or key == "KP_Subtract" then
				tag.gap = math.max(0, tag.gap - 2)
				naughty.notify({ text = "Gap: " .. tag.gap, timeout = 1 })
			elseif key == "0" or key == "KP_0" then
				tag.gap = 0
				naughty.notify({ text = "Gap: 0", timeout = 1 })
			elseif key == "d" then
				tag.gap = beautiful.useless_gap or 8
				naughty.notify({ text = "Gap: default (" .. tag.gap .. ")", timeout = 1 })
			elseif key == "Escape" or key == "Return" or key == "q" then
				awful.keygrabber.stop(grabber)
				naughty.destroy(gaps_notification)
				naughty.notify({ text = "Exited gaps mode", timeout = 1 })
			end
		end)
	end, { description = "enter gaps mode", group = "gaps" }),
	-- }}}

	-- {{{ Volume control mode (like i3's $mod+v)
	awful.key({ modkey }, "v", function()
		local widgets = require("modules.widgets")
		local vol_notification = naughty.notify({
			title = "Volume Mode",
			text = "k/+   volume up\nj/-   volume down\nm/0   mute toggle\nEsc   exit",
			timeout = 0,
		})

		local grabber
		grabber = awful.keygrabber.run(function(mod, key, event)
			if event == "release" then
				return
			end

			if key == "k" or key == "+" or key == "=" or key == "plus" or key == "equal" or key == "KP_Add" then
				volume_control("up")
				widgets.update_volume()
			elseif key == "j" or key == "-" or key == "minus" or key == "KP_Subtract" then
				volume_control("down")
				widgets.update_volume()
			elseif key == "m" or key == "0" or key == "KP_0" then
				volume_control("mute")
				widgets.update_volume()
			elseif key == "Escape" or key == "Return" or key == "q" then
				awful.keygrabber.stop(grabber)
				naughty.destroy(vol_notification)
				naughty.notify({ text = "Exited volume mode", timeout = 1 })
			end
		end)
	end, { description = "enter volume mode", group = "media" })
	-- }}}
)

-- {{{ Tag keybindings (workspaces 1-10)
for i = 1, 10 do
	local key = i == 10 and "0" or tostring(i)
	M.globalkeys = gears.table.join(
		M.globalkeys,
		-- View tag
		awful.key({ modkey }, key, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, { description = "view tag " .. i, group = "tag" }),

		-- Toggle tag
		awful.key({ modkey, "Control" }, key, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, { description = "toggle tag " .. i, group = "tag" }),

		-- Move client to tag
		awful.key({ modkey, "Shift" }, key, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, { description = "move client to tag " .. i, group = "tag" }),

		-- Toggle client on tag
		awful.key({ modkey, "Control", "Shift" }, key, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, { description = "toggle client on tag " .. i, group = "tag" })
	)
end
-- }}}

-- {{{ Client keybindings
M.clientkeys = gears.table.join(
	-- Fullscreen (mod+f)
	awful.key({ modkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }),

	-- Kill client (mod+shift+q)
	awful.key({ modkey, "Shift" }, "q", function(c)
		c:kill()
	end, { description = "close", group = "client" }),

	-- Toggle floating (mod+shift+space)
	awful.key(
		{ modkey, "Shift" },
		"space",
		awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }
	),

	-- Move to master (mod+ctrl+return)
	awful.key({ modkey, "Control" }, "Return", function(c)
		c:swap(awful.client.getmaster())
	end, { description = "move to master", group = "client" }),

	-- Focus parent container (mod+a) - in awesome we cycle through clients
	awful.key({ modkey }, "a", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous client", group = "client" }),

	-- Focus child (mod+i)
	awful.key({ modkey }, "i", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next client", group = "client" }),

	-- Minimize
	awful.key({ modkey }, "m", function(c)
		c.minimized = true
	end, { description = "minimize", group = "client" }),

	-- Maximize
	awful.key({ modkey, "Control" }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = "toggle maximize", group = "client" }),

	-- Sticky (keep on all tags)
	awful.key({ modkey, "Control" }, "s", function(c)
		c.sticky = not c.sticky
	end, { description = "toggle sticky", group = "client" }),

	-- On top
	awful.key({ modkey, "Control" }, "t", function(c)
		c.ontop = not c.ontop
	end, { description = "toggle keep on top", group = "client" })
)
-- }}}

-- {{{ Client mouse bindings
M.clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)
-- }}}

return M
