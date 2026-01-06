--[[
    Widgets Module
    Modern minimalist style with progress bars
--]]

local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local tracker = require("modules.tracker")

local M = {}

-- Dracula colors
local colors = {
	bg = "#282A36",
	fg = "#F8F8F2",
	selection = "#44475A",
	comment = "#6272A4",
	cyan = "#8BE9FD",
	green = "#50FA7B",
	orange = "#FFB86C",
	pink = "#FF79C6",
	purple = "#BD93F9",
	red = "#FF5555",
	yellow = "#F1FA8C",
}

-- Create icon widget
local function create_icon(icon, color)
	return wibox.widget({
		markup = "<span foreground='" .. color .. "'>" .. icon .. "</span>",
		font = "JetBrainsMono Nerd Font 12",
		forced_width = dpi(14),
		widget = wibox.widget.textbox,
	})
end

-- Create progress bar
local function create_progressbar(color)
	return wibox.widget({
		max_value = 100,
		value = 0,
		forced_width = dpi(60),
		forced_height = dpi(6),
		shape = gears.shape.rounded_bar,
		bar_shape = gears.shape.rounded_bar,
		background_color = colors.selection,
		color = color,
		widget = wibox.widget.progressbar,
	})
end

-- Create value text
local function create_value_text()
	return wibox.widget({
		text = "0%",
		font = "JetBrainsMono Nerd Font 10",
		widget = wibox.widget.textbox,
	})
end

-- Wrap widget in rounded container
local function create_widget_container(icon_widget, bar_widget, value_widget)
	return wibox.widget({
		{
			{
				icon_widget,
				{
					bar_widget,
					value_widget,
					spacing = dpi(4),
					layout = wibox.layout.fixed.horizontal,
				},
				spacing = dpi(6),
				layout = wibox.layout.fixed.horizontal,
			},
			left = dpi(6),
			right = dpi(6),
			top = dpi(2),
			bottom = dpi(2),
			widget = wibox.container.margin,
		},
		bg = colors.selection .. "80",
		shape = function(cr, w, h)
			gears.shape.rounded_rect(cr, w, h, dpi(4))
		end,
		widget = wibox.container.background,
	})
end

-- ============================================
-- CPU Widget
-- ============================================
local cpu_icon = create_icon("󰻠", colors.cyan)
local cpu_bar = create_progressbar(colors.green)
local cpu_value = create_value_text()
local cpu_total_prev = 0
local cpu_idle_prev = 0

local function update_cpu()
	awful.spawn.easy_async_with_shell("cat /proc/stat | head -1", function(stdout)
		local user, nice, system, idle, iowait, irq, softirq =
			stdout:match("cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")

		if not user then
			return
		end

		local total = user + nice + system + idle + iowait + irq + softirq
		local diff_total = total - cpu_total_prev
		local diff_idle = idle - cpu_idle_prev

		local usage = 0
		if diff_total > 0 then
			usage = math.floor(100 * (diff_total - diff_idle) / diff_total)
		end

		cpu_total_prev = total
		cpu_idle_prev = idle

		local color = colors.green
		if usage > 80 then
			color = colors.red
		elseif usage > 50 then
			color = colors.orange
		end

		cpu_bar.color = color
		cpu_bar.value = usage
		cpu_value:set_markup("<span foreground='" .. color .. "'>" .. string.format("%2d%%", usage) .. "</span>")
	end)
end

M.cpu = create_widget_container(cpu_icon, cpu_bar, cpu_value)

-- ============================================
-- Memory Widget
-- ============================================
local mem_icon = create_icon("󰍛", colors.pink)
local mem_bar = create_progressbar(colors.green)
local mem_value = create_value_text()

local function update_memory()
	awful.spawn.easy_async_with_shell("free | grep Mem", function(stdout)
		local total, used = stdout:match("Mem:%s+(%d+)%s+(%d+)")
		if not total then
			return
		end

		local usage = math.floor(100 * used / total)

		local color = colors.green
		if usage > 80 then
			color = colors.red
		elseif usage > 60 then
			color = colors.orange
		end

		mem_bar.color = color
		mem_bar.value = usage
		mem_value:set_markup("<span foreground='" .. color .. "'>" .. string.format("%2d%%", usage) .. "</span>")
	end)
end

M.memory = create_widget_container(mem_icon, mem_bar, mem_value)

-- ============================================
-- Temperature Widget (simple text style)
-- ============================================
local temp_icon = create_icon("󰔏", colors.orange)
local temp_text = wibox.widget({
	text = "0°C",
	font = "JetBrainsMono Nerd Font 10",
	widget = wibox.widget.textbox,
})

local function update_temperature()
	awful.spawn.easy_async_with_shell(
		"cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -1",
		function(stdout)
			local temp = tonumber(stdout)
			if not temp then
				awful.spawn.easy_async_with_shell(
					"sensors 2>/dev/null | grep -oP 'Package.*?\\+\\K[0-9]+'| head -1",
					function(out)
						local t = tonumber(out)
						if t then
							local color = colors.green
							if t > 80 then
								color = colors.red
							elseif t > 60 then
								color = colors.orange
							end
							temp_text:set_markup("<span foreground='" .. color .. "'>" .. t .. "°C</span>")
						end
					end
				)
				return
			end

			temp = math.floor(temp / 1000)
			local color = colors.green
			if temp > 80 then
				color = colors.red
			elseif temp > 60 then
				color = colors.orange
			end

			temp_text:set_markup("<span foreground='" .. color .. "'>" .. temp .. "°C</span>")
		end
	)
end

M.temperature = wibox.widget({
	{
		{
			temp_icon,
			temp_text,
			spacing = dpi(4),
			layout = wibox.layout.fixed.horizontal,
		},
		left = dpi(6),
		right = dpi(6),
		top = dpi(2),
		bottom = dpi(2),
		widget = wibox.container.margin,
	},
	bg = colors.selection .. "80",
	shape = function(cr, w, h)
		gears.shape.rounded_rect(cr, w, h, dpi(4))
	end,
	widget = wibox.container.background,
})

-- ============================================
-- Network Widget
-- ============================================
local net_text = wibox.widget({
	markup = "<span foreground='" .. colors.comment .. "'>󰖪  offline</span>",
	font = "JetBrainsMono Nerd Font 10",
	widget = wibox.widget.textbox,
})

local prev_rx = {}
local prev_tx = {}

local function format_speed(bytes_per_sec)
	local str
	if bytes_per_sec > 1000 * 1000 then
		str = string.format("%.1fM", bytes_per_sec / 1024 / 1024)
	elseif bytes_per_sec > 1000 then
		str = string.format("%.0fK", bytes_per_sec / 1024)
	else
		str = string.format("%.0fB", bytes_per_sec)
	end
	return string.format("%-4s", str)
end

local function update_network()
	awful.spawn.easy_async_with_shell(
		[[
        for iface in $(ls /sys/class/net/ | grep -v lo); do
            case "$iface" in
                docker*|br-*|veth*|lxd*|lxc*|virbr*) continue ;;
            esac
            state=$(cat /sys/class/net/$iface/operstate 2>/dev/null)
            if [ "$state" = "up" ]; then
                rx=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null)
                tx=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null)
                if [ -d "/sys/class/net/$iface/wireless" ]; then
                    echo "wlan:$iface:$rx:$tx:"
                else
                    ip=$(ip -4 addr show $iface 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
                    echo "eth:$iface:$rx:$tx:$ip"
                fi
            fi
        done
    ]],
		function(stdout)
			local result = {}

			for line in stdout:gmatch("[^\n]+") do
				local iface_type, iface_name, rx, tx, ip = line:match("(%w+):([%w_-]+):(%d+):(%d+):(.*)")
				if iface_type then
					rx = tonumber(rx) or 0
					tx = tonumber(tx) or 0
					local rx_speed = 0
					local tx_speed = 0

					if prev_rx[iface_name] then
						rx_speed = (rx - prev_rx[iface_name]) / 2
					end
					if prev_tx[iface_name] then
						tx_speed = (tx - prev_tx[iface_name]) / 2
					end
					prev_rx[iface_name] = rx
					prev_tx[iface_name] = tx

					if iface_type == "eth" and ip and ip ~= "" then
						table.insert(
							result,
							"<span foreground='"
								.. colors.green
								.. "'>󰇚 </span>"
								.. format_speed(rx_speed)
								.. " <span foreground='"
								.. colors.yellow
								.. "'>󰕒 </span>"
								.. format_speed(tx_speed)
								.. " <span foreground='"
								.. colors.green
								.. "'>󰈀 </span>"
								.. ip
						)
					elseif iface_type == "wlan" then
						table.insert(
							result,
							"<span foreground='"
								.. colors.cyan
								.. "'>󰖩 </span><span foreground='"
								.. colors.green
								.. "'>󰇚 </span>"
								.. format_speed(rx_speed)
								.. " <span foreground='"
								.. colors.yellow
								.. "'>󰕒 </span>"
								.. format_speed(tx_speed)
						)
					end
				end
			end

			if #result > 0 then
				net_text:set_markup(table.concat(result, "  "))
			else
				net_text:set_markup("<span foreground='" .. colors.comment .. "'>󰖪  offline</span>")
			end
		end
	)
end

M.network = wibox.widget({
	{
		{
			net_text,
			left = dpi(6),
			right = dpi(6),
			top = dpi(2),
			bottom = dpi(2),
			widget = wibox.container.margin,
		},
		bg = colors.selection .. "80",
		shape = function(cr, w, h)
			gears.shape.rounded_rect(cr, w, h, dpi(4))
		end,
		widget = wibox.container.background,
	},
	layout = wibox.layout.fixed.horizontal,
})

-- ============================================
-- Volume Widget
-- ============================================
local vol_icon = create_icon("󰕾", colors.purple)
local vol_bar = create_progressbar(colors.green)
local vol_value = create_value_text()
local vol_muted = false

local function update_volume()
	awful.spawn.easy_async_with_shell(
		[[pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '\d+(?=%)' | head -1]],
		function(vol_stdout)
			awful.spawn.easy_async_with_shell(
				[[pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -oP '(?<=Mute: )\w+']],
				function(mute_stdout)
					local volume = tonumber(vol_stdout) or 0
					local muted = mute_stdout:match("yes") ~= nil
					vol_muted = muted

					local icon = muted and "󰝟" or (volume > 50 and "󰕾" or (volume > 0 and "󰖀" or "󰕿"))
					local color = muted and colors.red or colors.green

					vol_icon:set_markup("<span foreground='" .. colors.purple .. "'>" .. icon .. "</span>")
					vol_bar.color = color
					vol_bar.value = volume
					vol_value:set_markup(
						"<span foreground='" .. color .. "'>" .. string.format("%2d%%", volume) .. "</span>"
					)
				end
			)
		end
	)
end

M.volume = create_widget_container(vol_icon, vol_bar, vol_value)
M.volume:buttons(gears.table.join(
	awful.button({}, 1, function()
		awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
		gears.timer.start_new(0.1, function()
			update_volume()
			return false
		end)
	end),
	awful.button({}, 3, function()
		awful.spawn("pavucontrol")
	end),
	awful.button({}, 4, function()
		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
		gears.timer.start_new(0.1, function()
			update_volume()
			return false
		end)
	end),
	awful.button({}, 5, function()
		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
		gears.timer.start_new(0.1, function()
			update_volume()
			return false
		end)
	end)
))

M.update_volume = update_volume

-- ============================================
-- Clock Widget
-- ============================================
M.clock = wibox.widget({
	{
		{
			{
				markup = "<span foreground='" .. colors.purple .. "'></span>",
				font = "JetBrainsMono Nerd Font 11",
				widget = wibox.widget.textbox,
			},
			wibox.widget.textclock(" %Y-%m-%d %H:%M "),
			layout = wibox.layout.fixed.horizontal,
		},
		left = dpi(6),
		right = dpi(6),
		top = dpi(2),
		bottom = dpi(2),
		widget = wibox.container.margin,
	},
	bg = colors.selection .. "80",
	shape = function(cr, w, h)
		gears.shape.rounded_rect(cr, w, h, dpi(4))
	end,
	widget = wibox.container.background,
})

-- ============================================
-- Spacer
-- ============================================
M.spacer = wibox.widget({
	forced_width = dpi(8),
	widget = wibox.container.background,
})

-- ============================================
-- Agent Tracker Widget
-- ============================================
-- Running indicator (green)
local running_text = wibox.widget({
	markup = "<span foreground='" .. colors.comment .. "'>󰓕 0</span>",
	font = "JetBrainsMono Nerd Font 11",
	widget = wibox.widget.textbox,
})

-- Idle indicator (gray)
local idle_text = wibox.widget({
	markup = "<span foreground='" .. colors.comment .. "'>󰏤 0</span>",
	font = "JetBrainsMono Nerd Font 11",
	widget = wibox.widget.textbox,
})

-- Pending indicator (yellow)
local pending_text = wibox.widget({
	markup = "<span foreground='" .. colors.comment .. "'>󰌆 0</span>",
	font = "JetBrainsMono Nerd Font 11",
	widget = wibox.widget.textbox,
})

-- Session list container for popup
local session_list = wibox.widget({
	layout = wibox.layout.fixed.vertical,
	spacing = dpi(4),
})

-- Popup for showing all sessions
local agent_popup = awful.popup({
	widget = {
		{
			{
				markup = "<span foreground='" .. colors.purple .. "' font_weight='bold'>󰚩 Agent Sessions</span>",
				font = "JetBrainsMono Nerd Font 11",
				widget = wibox.widget.textbox,
			},
			{
				{
					forced_height = dpi(1),
					bg = colors.selection,
					widget = wibox.container.background,
				},
				top = dpi(6),
				bottom = dpi(6),
				widget = wibox.container.margin,
			},
			session_list,
			layout = wibox.layout.fixed.vertical,
		},
		margins = dpi(12),
		widget = wibox.container.margin,
	},
	bg = colors.bg .. "F0",
	border_color = colors.selection,
	border_width = dpi(1),
	shape = function(cr, w, h)
		gears.shape.rounded_rect(cr, w, h, dpi(8))
	end,
	visible = false,
	ontop = true,
	minimum_width = dpi(520),
})

-- 根据 window_id 获取窗口所在的 tag 名称
local function get_window_tag(window_id)
	if not window_id then
		return nil
	end
	for _, c in ipairs(client.get()) do
		if c.window == window_id then
			local tag = c.first_tag
			return tag and tag.name or nil
		end
	end
	return nil
end

-- 根据 window_id 获取窗口标题
local function get_window_title(window_id)
	if not window_id then
		return nil
	end
	for _, c in ipairs(client.get()) do
		if c.window == window_id then
			return c.name
		end
	end
	return nil
end

-- 截断过长的文本
local function truncate_text(text, max_len)
	if not text then
		return ""
	end
	if #text <= max_len then
		return text
	end
	return text:sub(1, max_len - 3) .. "..."
end

-- 安全的 shell 引用（单引号内只需处理单引号本身）
local function shell_quote(s)
	if s == nil or s == "" then
		return "''"
	end
	return "'" .. s:gsub("'", "'\"'\"'") .. "'"
end

-- 编辑会话笔记 (使用 rofi 支持中文输入)
local function edit_session_note(session)
	agent_popup.visible = false
	local existing = session.notes or ""
	-- rofi dmenu 需要 stdin，-normal-window 防止失焦关闭
	local cmd = "echo '' | rofi -dmenu -normal-window -p '📝 笔记' -l 0 -filter " .. shell_quote(existing)
	-- 延迟执行避免焦点竞争
	gears.timer.start_new(0.05, function()
		awful.spawn.easy_async_with_shell(cmd, function(stdout)
			local input = stdout:gsub("^%s*(.-)%s*$", "%1")
			if input ~= "" then
				tracker.set_notes(session.pid, input)
			end
		end)
		return false
	end)
end

-- Update session list in popup (按 tag 分组)
local function update_session_list()
	session_list:reset()

	local sessions = tracker.get_active_sessions()

	if #sessions == 0 then
		session_list:add(wibox.widget({
			markup = "<span foreground='" .. colors.comment .. "'>No active sessions</span>",
			font = "JetBrainsMono Nerd Font 10",
			widget = wibox.widget.textbox,
		}))
		return
	end

	-- 按 tag 分组
	local groups = {}
	local group_order = {}
	for _, session in ipairs(sessions) do
		local tag_name = get_window_tag(session.window_id) or "unknown"
		if not groups[tag_name] then
			groups[tag_name] = {}
			table.insert(group_order, tag_name)
		end
		table.insert(groups[tag_name], session)
	end

	-- 按分组显示
	for _, tag_name in ipairs(group_order) do
		-- Tag 标题
		session_list:add(wibox.widget({
			{
				markup = "<span foreground='" .. colors.cyan .. "' font_weight='bold'>󰓹 " .. tag_name .. "</span>",
				font = "JetBrainsMono Nerd Font 10",
				widget = wibox.widget.textbox,
			},
			top = dpi(4),
			bottom = dpi(2),
			widget = wibox.container.margin,
		}))

		-- 该 tag 下的 sessions
		for _, session in ipairs(groups[tag_name]) do
			-- State icon and color
			local state_icon, state_color
			if session.state == "running" then
				state_icon = "󰓕"
				state_color = colors.green
			elseif session.state == "pending" then
				state_icon = "󰌆"
				state_color = colors.yellow
			else -- idle
				state_icon = "󰏤"
				state_color = colors.cyan
			end

			-- 优先使用 description，没有则使用窗口标题
			local title = session.description or get_window_title(session.window_id)
			local title_display = truncate_text(title, 50)

			-- 笔记显示内容
			local notes_display = session.notes and session.notes ~= ""
					and "<span foreground='" .. colors.fg .. "'>" .. truncate_text(session.notes, 30) .. "</span>"
				or "<span foreground='" .. colors.comment .. "' style='italic'>右键添加...</span>"

			local item = wibox.widget({
				{
					{
						-- 左侧：会话信息
						{
							{
								-- 第一行：状态、图标、项目、时长
								{
									-- State icon
									{
										markup = "<span foreground='"
											.. state_color
											.. "'>"
											.. state_icon
											.. "</span>",
										font = "JetBrainsMono Nerd Font 11",
										widget = wibox.widget.textbox,
									},
									-- Agent icon
									{
										markup = "<span foreground='"
											.. colors.purple
											.. "'>"
											.. session.agent_icon
											.. "</span>",
										font = "JetBrainsMono Nerd Font 11",
										widget = wibox.widget.textbox,
									},
									-- Project name
									{
										markup = "<span foreground='"
											.. colors.fg
											.. "'>"
											.. session.project
											.. "</span>",
										font = "JetBrainsMono Nerd Font 10",
										widget = wibox.widget.textbox,
									},
									-- Duration
									{
										markup = "<span foreground='"
											.. colors.comment
											.. "'>"
											.. session.duration_str
											.. "</span>",
										font = "JetBrainsMono Nerd Font 10",
										widget = wibox.widget.textbox,
									},
									layout = wibox.layout.fixed.horizontal,
									spacing = dpi(6),
								},
								-- 第二行：窗口标题
								{
									markup = "<span foreground='"
										.. colors.comment
										.. "'>  "
										.. title_display
										.. "</span>",
									font = "JetBrainsMono Nerd Font 9",
									widget = wibox.widget.textbox,
								},
								layout = wibox.layout.fixed.vertical,
								spacing = dpi(2),
							},
							forced_width = dpi(380),
							widget = wibox.container.constraint,
						},
						-- 分隔线
						{
							forced_width = dpi(1),
							bg = colors.selection,
							widget = wibox.container.background,
						},
						-- 右侧：笔记区域
						{
							{
								markup = notes_display,
								font = "JetBrainsMono Nerd Font 9",
								widget = wibox.widget.textbox,
							},
							left = dpi(8),
							right = dpi(4),
							widget = wibox.container.margin,
						},
						layout = wibox.layout.fixed.horizontal,
					},
					left = dpi(12),
					right = dpi(4),
					top = dpi(4),
					bottom = dpi(4),
					widget = wibox.container.margin,
				},
				bg = colors.selection .. "80",
				shape = function(cr, w, h)
					gears.shape.rounded_rect(cr, w, h, dpi(4))
				end,
				widget = wibox.container.background,
			})

			-- 左键聚焦窗口，右键编辑笔记
			item:buttons(gears.table.join(
				awful.button({}, 1, function()
					tracker.focus_session(session.pid)
					agent_popup.visible = false
				end),
				awful.button({}, 3, function()
					edit_session_note(session)
				end)
			))

			-- Hover effect
			item:connect_signal("mouse::enter", function()
				item.bg = colors.selection
			end)
			item:connect_signal("mouse::leave", function()
				item.bg = colors.selection .. "80"
			end)

			session_list:add(item)
		end
	end
end

-- Update tracker widget display
local function update_tracker_widget()
	local running = tracker.get_running_count()
	local idle = tracker.get_idle_count()
	local pending = tracker.get_pending_count()

	-- Running (green when active)
	local running_color = running > 0 and colors.green or colors.comment
	running_text:set_markup("<span foreground='" .. running_color .. "'>󰓕 " .. running .. "</span>")

	-- Idle (gray/cyan when active)
	local idle_color = idle > 0 and colors.cyan or colors.comment
	idle_text:set_markup("<span foreground='" .. idle_color .. "'>󰏤 " .. idle .. "</span>")

	-- Pending (yellow when active)
	local pending_color = pending > 0 and colors.yellow or colors.comment
	pending_text:set_markup("<span foreground='" .. pending_color .. "'>󰌆 " .. pending .. "</span>")

	-- Also update popup content if visible
	if agent_popup.visible then
		update_session_list()
	end
end

M.agent_tracker = wibox.widget({
	{
		{
			{
				running_text,
				idle_text,
				pending_text,
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(8),
			},
			left = dpi(6),
			right = dpi(6),
			top = dpi(2),
			bottom = dpi(2),
			widget = wibox.container.margin,
		},
		bg = colors.selection .. "80",
		shape = function(cr, w, h)
			gears.shape.rounded_rect(cr, w, h, dpi(4))
		end,
		widget = wibox.container.background,
	},
	widget = wibox.container.background,
})

-- Click to toggle popup
M.agent_tracker:buttons(gears.table.join(awful.button({}, 1, function()
	if agent_popup.visible then
		agent_popup.visible = false
	else
		update_session_list()
		-- 在 widget 下方显示 popup
		agent_popup.screen = awful.screen.focused()
		awful.placement.next_to(agent_popup, {
			preferred_positions = { "bottom" },
			preferred_anchors = { "middle" },
			geometry = mouse.current_widget_geometry,
			offset = { y = dpi(5) },
		})
		agent_popup.visible = true
	end
end)))

-- Hide popup when clicking outside
client.connect_signal("button::press", function()
	agent_popup.visible = false
end)

-- ============================================
-- Initialize timers
-- ============================================
function M.init()
	update_cpu()
	update_memory()
	update_temperature()
	update_network()
	update_volume()
	update_tracker_widget()

	-- Subscribe to tracker state changes
	tracker.subscribe(update_tracker_widget)

	gears.timer({
		timeout = 2,
		autostart = true,
		call_now = false,
		callback = function()
			update_cpu()
			update_memory()
			update_network()
			update_volume()
		end,
	})

	gears.timer({
		timeout = 5,
		autostart = true,
		call_now = false,
		callback = update_temperature,
	})
end

return M
