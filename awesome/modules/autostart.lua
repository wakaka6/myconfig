--[[
    Autostart Module
    Migrated from i3 exec/exec_always commands
--]]

local awful = require("awful")

local M = {}

-- Run command only once (check if already running)
local function run_once(cmd, match)
    match = match or cmd:match("^%S+")
    awful.spawn.easy_async_with_shell(
        string.format("pgrep -u $USER -x '%s' > /dev/null || (%s)", match, cmd),
        function() end
    )
end

-- Run command always (every restart)
local function run_always(cmd)
    awful.spawn.with_shell(cmd)
end

function M.run()
    -- === Run Once (exec) ===

    -- Lock screen manager
    run_once("xss-lock --transfer-sleep-lock -- ~/.config/i3/lock.sh")

    -- NetworkManager applet
    run_once("nm-applet")

    -- Notifications
    run_once("dunst")

    -- Wallpaper manager
    run_once("variety")

    -- GoldenDict
    run_once("goldendict")

    -- === Run Always (exec_always) ===

    -- Compositor
    run_always("killall -q picom; sleep 0.5; picom -b --inactive-dim 0.02")

    -- Input method
    run_always("fcitx5 -d")

    -- Numlock
    run_always("numlockx on")

    -- Optimus manager (if you use hybrid graphics)
    run_once("optimus-manager-qt")

    -- === Scratchpad applications ===
    -- 这些程序会在需要时由 scratchpad 模块启动
    -- 如果想在启动时预加载，取消下面的注释

    -- run_once("st -n translate -e proxychains -q trans -shell -t zh -4 -sp", "translate")
end

return M
