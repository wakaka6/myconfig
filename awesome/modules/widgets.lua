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
-- Initialize timers
-- ============================================
function M.init()
	update_cpu()
	update_memory()
	update_temperature()
	update_network()
	update_volume()

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
