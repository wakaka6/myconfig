--[[
    Widgets Module
    网络状态、CPU、内存、温度监控
--]]

local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

local M = {}

-- Dracula 颜色
local colors = {
    fg = "#F8F8F2",
    comment = "#6272A4",
    cyan = "#8BE9FD",
    green = "#50FA7B",
    orange = "#FFB86C",
    pink = "#FF79C6",
    red = "#FF5555",
    yellow = "#F1FA8C",
}

-- 创建带颜色的文本
local function colored(text, color)
    return "<span foreground='" .. color .. "'>" .. text .. "</span>"
end

-- ============================================
-- CPU Widget
-- ============================================
local cpu_widget = wibox.widget.textbox()
local cpu_total_prev = 0
local cpu_idle_prev = 0

local function update_cpu()
    awful.spawn.easy_async_with_shell(
        "cat /proc/stat | head -1",
        function(stdout)
            local user, nice, system, idle, iowait, irq, softirq =
                stdout:match("cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")

            if not user then return end

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
            if usage > 80 then color = colors.red
            elseif usage > 50 then color = colors.orange
            end

            cpu_widget:set_markup(
                colored(" ", colors.cyan) .. colored(string.format("%2d%%", usage), color)
            )
        end
    )
end

-- ============================================
-- Memory Widget
-- ============================================
local mem_widget = wibox.widget.textbox()

local function update_memory()
    awful.spawn.easy_async_with_shell(
        "free | grep Mem",
        function(stdout)
            local total, used = stdout:match("Mem:%s+(%d+)%s+(%d+)")
            if not total then return end

            local usage = math.floor(100 * used / total)

            local color = colors.green
            if usage > 80 then color = colors.red
            elseif usage > 60 then color = colors.orange
            end

            mem_widget:set_markup(
                colored(" ", colors.pink) .. colored(string.format("%2d%%", usage), color)
            )
        end
    )
end

-- ============================================
-- Temperature Widget
-- ============================================
local temp_widget = wibox.widget.textbox()

local function update_temperature()
    awful.spawn.easy_async_with_shell(
        "cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -1",
        function(stdout)
            local temp = tonumber(stdout)
            if not temp then
                -- 尝试 sensors 命令
                awful.spawn.easy_async_with_shell(
                    "sensors 2>/dev/null | grep -oP 'Package.*?\\+\\K[0-9]+'| head -1",
                    function(out)
                        local t = tonumber(out)
                        if t then
                            local color = colors.green
                            if t > 80 then color = colors.red
                            elseif t > 60 then color = colors.orange
                            end
                            temp_widget:set_markup(
                                colored(" ", colors.orange) .. colored(t .. "°C", color)
                            )
                        end
                    end
                )
                return
            end

            temp = math.floor(temp / 1000)
            local color = colors.green
            if temp > 80 then color = colors.red
            elseif temp > 60 then color = colors.orange
            end

            temp_widget:set_markup(
                colored(" ", colors.orange) .. colored(temp .. "°C", color)
            )
        end
    )
end

-- ============================================
-- Network Widget (动态检测接口)
-- ============================================
local net_widget = wibox.widget.textbox()

-- 存储上次的接收字节数
local prev_rx = {}

local function format_speed(bytes_per_sec)
    if bytes_per_sec > 1024 * 1024 then
        return string.format("%.1fM", bytes_per_sec / 1024 / 1024)
    elseif bytes_per_sec > 1024 then
        return string.format("%.0fK", bytes_per_sec / 1024)
    else
        return string.format("%.0fB", bytes_per_sec)
    end
end

local function update_network()
    awful.spawn.easy_async_with_shell([[
        # 动态检测活跃的网络接口
        for iface in $(ls /sys/class/net/ | grep -v lo); do
            state=$(cat /sys/class/net/$iface/operstate 2>/dev/null)
            if [ "$state" = "up" ]; then
                rx=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null)
                # 判断接口类型: 无线接口通常在 /sys/class/net/xxx/wireless 存在
                if [ -d "/sys/class/net/$iface/wireless" ]; then
                    echo "wlan:$iface:$rx:"
                else
                    ip=$(ip -4 addr show $iface 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
                    echo "eth:$iface:$rx:$ip"
                fi
            fi
        done
    ]], function(stdout)
        local result = {}

        for line in stdout:gmatch("[^\n]+") do
            local iface_type, iface_name, rx, ip = line:match("(%w+):([%w_-]+):(%d+):(.*)")
            if iface_type then
                rx = tonumber(rx) or 0
                local speed = 0

                if prev_rx[iface_name] then
                    speed = (rx - prev_rx[iface_name]) / 2  -- 2秒更新间隔
                end
                prev_rx[iface_name] = rx

                if iface_type == "eth" and ip and ip ~= "" then
                    table.insert(result, colored("󰈀 ", colors.green) .. ip .. " " .. colored("", colors.cyan) .. format_speed(speed))
                elseif iface_type == "wlan" then
                    table.insert(result, colored("󰖩 ", colors.cyan) .. colored("", colors.cyan) .. format_speed(speed))
                end
            end
        end

        if #result > 0 then
            net_widget:set_markup(table.concat(result, "  "))
        else
            net_widget:set_markup(colored("󰖪 ", colors.comment) .. colored("offline", colors.comment))
        end
    end)
end

-- ============================================
-- 分隔符
-- ============================================
M.separator = wibox.widget.textbox()
M.separator:set_markup(colored(" │ ", colors.comment))

-- ============================================
-- 初始化和定时更新
-- ============================================
function M.init()
    -- 初始更新
    update_cpu()
    update_memory()
    update_temperature()
    update_network()

    -- 定时更新
    gears.timer {
        timeout = 2,
        autostart = true,
        call_now = false,
        callback = function()
            update_cpu()
            update_memory()
            update_network()
        end
    }

    -- 温度更新频率低一些
    gears.timer {
        timeout = 5,
        autostart = true,
        call_now = false,
        callback = update_temperature
    }
end

-- 导出 widgets
M.cpu = cpu_widget
M.memory = mem_widget
M.temperature = temp_widget
M.network = net_widget

return M
