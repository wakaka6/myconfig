--[[
    AwesomeWM Configuration
    Migrated from i3wm - Adapted for multi-monitor environments
    Author: wakaka6
--]]

-- Standard awesome libraries
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

-- Custom modules
local env = require("env.detect")
local keys = require("modules.keys")
local rules = require("modules.rules")
local scratchpad = require("modules.scratchpad")
local autostart = require("modules.autostart")
local widgets = require("modules.widgets")

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Startup Error",
        text = awesome.startup_errors
    })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then return end
        in_error = true
        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Error",
            text = tostring(err)
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/dracula/theme.lua")

terminal = "alacritty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"

-- Detect environment (office/home)
local current_env = env.detect()
naughty.notify({
    title = "AwesomeWM",
    text = "Environment: " .. current_env .. " (" .. screen.count() .. " screens)",
    timeout = 3
})
-- }}}

-- {{{ Layouts
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair,
    awful.layout.suit.max,
    awful.layout.suit.floating,
}
-- }}}

-- {{{ Wibar
local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal("request::activate", "tasklist", { raise = true })
        end
    end),
    awful.button({}, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({}, 4, function() awful.client.focus.byidx(1) end),
    awful.button({}, 5, function() awful.client.focus.byidx(-1) end)
)

-- Wallpaper function
local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

screen.connect_signal("property::geometry", set_wallpaper)

-- Setup each screen
awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    -- Get tags for this screen based on environment
    local tags = env.get_tags(current_env, s.index, screen.count())
    local default_layout = env.get_default_layout(current_env, s.index)

    awful.tag(tags, s, default_layout)

    -- Create a promptbox
    s.mypromptbox = awful.widget.prompt()

    -- Create layoutbox
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end),
        awful.button({}, 4, function() awful.layout.inc(1) end),
        awful.button({}, 5, function() awful.layout.inc(-1) end)
    ))

    -- Create taglist widget
    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create systray (only on primary screen)
    local systray = nil
    if s == screen.primary then
        systray = wibox.widget.systray()
    end

    -- Create wibar (only on primary screen)
    if s == screen.primary then
        s.mywibox = awful.wibar({
            position = "top",
            screen = s,
            height = beautiful.wibar_height or 28
        })

        s.mywibox:setup {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                s.mytaglist,
                s.mypromptbox,
            },
            s.mytasklist, -- Middle widget
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                widgets.network,
                widgets.separator,
                widgets.cpu,
                widgets.separator,
                widgets.memory,
                widgets.separator,
                widgets.temperature,
                widgets.separator,
                systray,
                wibox.widget.textclock(" %Y-%m-%d %H:%M "),
                s.mylayoutbox,
            },
        }
    end
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
root.keys(keys.globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = rules.get(current_env)
-- }}}

-- {{{ Signals
client.connect_signal("manage", function(c)
    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)

-- Focus follows mouse
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)
-- }}}

-- {{{ Screen handling (hot-plug support)
screen.connect_signal("added", function(s)
    naughty.notify({
        title = "Screen Added",
        text = "New screen detected: " .. s.index,
        timeout = 5
    })
    -- Re-detect environment
    current_env = env.detect()
    local tags = env.get_tags(current_env, s.index, screen.count())
    awful.tag(tags, s, awful.layout.suit.tile)
end)

screen.connect_signal("removed", function(s)
    naughty.notify({
        title = "Screen Removed",
        text = "Screen disconnected",
        timeout = 5
    })
end)
-- }}}

-- Initialize scratchpads
scratchpad.init()

-- Initialize widgets (网络、CPU、内存、温度)
widgets.init()

-- Run autostart applications
autostart.run()
