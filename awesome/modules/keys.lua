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
	if not tag then return false end
	return tag.layout == awful.layout.suit.max or
	       tag.layout == awful.layout.suit.max.fullscreen
end

-- Helper: 聚焦目标屏幕上的窗口
local function focus_client_on_screen(new_screen, dir)
	-- 优先聚焦全屏窗口
	for _, c in ipairs(new_screen.clients) do
		if c.fullscreen and not c.minimized then
			c:emit_signal("request::activate", "focus_direction", { raise = true })
			return
		end
	end

	-- 其次恢复到该屏幕上次聚焦的窗口
	local last_client = last_focused_client[new_screen.index]

	if last_client and last_client.valid and not last_client.minimized
	   and last_client.screen == new_screen then
		last_client:emit_signal("request::activate", "focus_direction", { raise = true })
		return
	end

	-- 回退：在该屏幕的可见窗口中选择一个
	local clients = new_screen.clients
	if #clients == 0 then return end

	local target = nil

	if is_max_layout(new_screen) then
		-- max 布局：选第一个非最小化窗口
		for _, c in ipairs(clients) do
			if not c.minimized then
				target = c
				break
			end
		end
	else
		-- tiling 布局：按方向选择
		if dir == "left" then
			for _, c in ipairs(clients) do
				if not c.minimized and (target == nil or c:geometry().x > target:geometry().x) then
					target = c
				end
			end
		elseif dir == "right" then
			for _, c in ipairs(clients) do
				if not c.minimized and (target == nil or c:geometry().x < target:geometry().x) then
					target = c
				end
			end
		elseif dir == "up" then
			for _, c in ipairs(clients) do
				if not c.minimized and (target == nil or c:geometry().y > target:geometry().y) then
					target = c
				end
			end
		elseif dir == "down" then
			for _, c in ipairs(clients) do
				if not c.minimized and (target == nil or c:geometry().y < target:geometry().y) then
					target = c
				end
			end
		end
	end

	if target then
		target:emit_signal("request::activate", "focus_direction", { raise = true })
	end
end

-- Helper: 按物理方向查找相邻屏幕
local function get_screen_in_direction(s, dir)
	if not s then return nil end
	local geo = s.geometry
	local target = nil
	local best_distance = math.huge

	for other_screen in screen do
		if other_screen ~= s then
			local other_geo = other_screen.geometry
			local dominated = false
			local distance = 0

			if dir == "left" then
				-- 目标屏幕的右边缘 <= 当前屏幕的左边缘
				if other_geo.x + other_geo.width <= geo.x then
					-- 垂直方向有重叠
					local overlap = math.min(geo.y + geo.height, other_geo.y + other_geo.height) -
					                math.max(geo.y, other_geo.y)
					if overlap > 0 then
						distance = geo.x - (other_geo.x + other_geo.width)
						dominated = true
					end
				end
			elseif dir == "right" then
				-- 目标屏幕的左边缘 >= 当前屏幕的右边缘
				if other_geo.x >= geo.x + geo.width then
					local overlap = math.min(geo.y + geo.height, other_geo.y + other_geo.height) -
					                math.max(geo.y, other_geo.y)
					if overlap > 0 then
						distance = other_geo.x - (geo.x + geo.width)
						dominated = true
					end
				end
			elseif dir == "up" then
				-- 目标屏幕的下边缘 <= 当前屏幕的上边缘
				if other_geo.y + other_geo.height <= geo.y then
					local overlap = math.min(geo.x + geo.width, other_geo.x + other_geo.width) -
					                math.max(geo.x, other_geo.x)
					if overlap > 0 then
						distance = geo.y - (other_geo.y + other_geo.height)
						dominated = true
					end
				end
			elseif dir == "down" then
				-- 目标屏幕的上边缘 >= 当前屏幕的下边缘
				if other_geo.y >= geo.y + geo.height then
					local overlap = math.min(geo.x + geo.width, other_geo.x + other_geo.width) -
					                math.max(geo.x, other_geo.x)
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

	return target
end

-- Helper: 智能跨屏幕焦点切换
-- 如果当前方向没有窗口，则切换到相邻屏幕（按物理位置）
local function focus_global_direction(dir)
	local old_client = client.focus
	local old_screen = awful.screen.focused()

	-- 检查当前窗口是否全屏
	local is_fullscreen = old_client and old_client.fullscreen

	-- max 布局或全屏窗口下，hjkl 按物理方向跨屏
	if is_max_layout(old_screen) or is_fullscreen then
		local target_screen = get_screen_in_direction(old_screen, dir)
		if target_screen then
			awful.screen.focus(target_screen)
			focus_client_on_screen(target_screen, dir)
		end
		-- 如果该方向没有屏幕，什么都不做（保持原位）
	else
		-- tiling 布局：先尝试同屏方向切换
		awful.client.focus.bydirection(dir)

		-- 如果焦点没变化或切到其他屏幕失败，尝试手动切换屏幕
		local new_client = client.focus
		local still_same_screen = (new_client == old_client) or
		                          (new_client == nil) or
		                          (new_client and new_client.screen == old_screen)

		if still_same_screen and (new_client == old_client or new_client == nil) then
			local target_screen = get_screen_in_direction(old_screen, dir)
			if target_screen then
				awful.screen.focus(target_screen)
				focus_client_on_screen(target_screen, dir)
			end
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

	-- {{{ Tag navigation (like i3 workspaces)
	awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous tag", group = "tag" }),
	awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next tag", group = "tag" }),
	awful.key({ modkey }, "Tab", awful.tag.history.restore, { description = "go back", group = "tag" }),
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

	-- Arrow key alternatives
	awful.key({ modkey }, "Left", function()
		focus_global_direction("left")
	end, { description = "focus left (cross-screen)", group = "client" }),

	awful.key({ modkey }, "Down", function()
		focus_global_direction("down")
	end, { description = "focus down (cross-screen)", group = "client" }),

	awful.key({ modkey }, "Up", function()
		focus_global_direction("up")
	end, { description = "focus up (cross-screen)", group = "client" }),

	awful.key({ modkey }, "Right", function()
		focus_global_direction("right")
	end, { description = "focus right (cross-screen)", group = "client" }),

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
		if not c then return end
		if c.floating or awful.layout.get(c.screen) == awful.layout.suit.floating then
			c:relative_move(-50, 0, 0, 0)
		else
			awful.client.swap.bydirection("left")
		end
	end, { description = "swap/move left", group = "client" }),

	awful.key({ modkey, "Shift" }, "j", function()
		local c = client.focus
		if not c then return end
		if c.floating or awful.layout.get(c.screen) == awful.layout.suit.floating then
			c:relative_move(0, 50, 0, 0)
		else
			awful.client.swap.bydirection("down")
		end
	end, { description = "swap/move down", group = "client" }),

	awful.key({ modkey, "Shift" }, "k", function()
		local c = client.focus
		if not c then return end
		if c.floating or awful.layout.get(c.screen) == awful.layout.suit.floating then
			c:relative_move(0, -50, 0, 0)
		else
			awful.client.swap.bydirection("up")
		end
	end, { description = "swap/move up", group = "client" }),

	awful.key({ modkey, "Shift" }, "l", function()
		local c = client.focus
		if not c then return end
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
	end, { description = "increase master clients", group = "layout" }),

	awful.key({ modkey, "Control" }, "j", function()
		awful.tag.incnmaster(-1, nil, true)
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
	-- Mod+g: 进入 gaps 模式
	awful.key({ modkey }, "g", function()
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
	end, { description = "enter gaps mode", group = "gaps" })
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
