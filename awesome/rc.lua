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
local env = require("envws.detect")
local keys = require("modules.keys")
local rules = require("modules.rules")
local scratchpad = require("modules.scratchpad")
local autostart = require("modules.autostart")
local widgets = require("modules.widgets")
local tag_persist = require("modules.tag_persist")

-- {{{ Error handling
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Startup Error",
		text = awesome.startup_errors,
	})
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		if in_error then
			return
		end
		in_error = true
		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Error",
			text = tostring(err),
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
	timeout = 3,
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
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
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
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
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
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
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
	local tags = env.get_tags(current_env, s, screen.count())
	local default_layout = env.get_default_layout(current_env, s)

	awful.tag(tags, s, default_layout)

	-- Create a promptbox
	s.mypromptbox = awful.widget.prompt()

	-- Create layoutbox with rounded background
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))

	-- Wrap layoutbox in rounded container (size based on screen)
	local layoutbox_margin = s == screen.primary and dpi(2) or dpi(1)
	local layoutbox_container = wibox.widget({
		{
			s.mylayoutbox,
			margins = layoutbox_margin,
			widget = wibox.container.margin,
		},
		bg = "#44475A80",
		shape = function(cr, w, h)
			gears.shape.rounded_rect(cr, w, h, dpi(4))
		end,
		widget = wibox.container.background,
	})

	-- Create taglist widget with pill style (smaller for non-primary)
	local taglist_lr_margin = s == screen.primary and dpi(8) or dpi(5)
	local taglist_outer_margin = s == screen.primary and dpi(1) or dpi(0)
	local taglist_spacing = s == screen.primary and dpi(3) or dpi(2)

	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
		widget_template = {
			{
				{
					{
						id = "text_role",
						widget = wibox.widget.textbox,
					},
					left = taglist_lr_margin,
					right = taglist_lr_margin,
					widget = wibox.container.margin,
				},
				id = "background_role",
				widget = wibox.container.background,
			},
			margins = taglist_outer_margin,
			widget = wibox.container.margin,
		},
		layout = {
			spacing = taglist_spacing,
			layout = wibox.layout.fixed.horizontal,
		},
	})

	-- Create tasklist widget with modern style
	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
		widget_template = {
			{
				{
					{
						id = "icon_role",
						widget = wibox.widget.imagebox,
					},
					margins = dpi(4),
					widget = wibox.container.margin,
				},
				{
					id = "text_role",
					widget = wibox.widget.textbox,
				},
				layout = wibox.layout.fixed.horizontal,
			},
			left = dpi(8),
			right = dpi(8),
			widget = wibox.container.margin,
			id = "background_role_container",
			create_callback = function(self, c, index, objects)
				self:get_children_by_id("background_role_container")[1].bg = c == client.focus
						and "#44475A"
					or "transparent"
			end,
			update_callback = function(self, c, index, objects)
				-- This is handled by background_role
			end,
		},
		layout = {
			spacing = dpi(4),
			layout = wibox.layout.flex.horizontal,
		},
	})

	-- Create floating wibar
	local wibar_height = dpi(28)
	local wibar_margin_top = dpi(4)
	if s ~= screen.primary then
		wibar_height = dpi(22)
		wibar_margin_top = dpi(3)
	end

	s.mywibox = awful.wibar({
		position = "top",
		screen = s,
		height = wibar_height,
		bg = "#00000000", -- Fully transparent
		margins = {
			top = wibar_margin_top,
			left = dpi(6),
			right = dpi(6),
		},
	})

	-- Right widgets (systray only on primary screen)
	local right_widgets

	if s == screen.primary then
		-- Systray with background
		local systray = wibox.widget({
			{
				{
					wibox.widget.systray(),
					margins = dpi(2),
					widget = wibox.container.margin,
				},
				bg = "#44475A80",
				shape = function(cr, w, h)
					gears.shape.rounded_rect(cr, w, h, dpi(4))
				end,
				widget = wibox.container.background,
			},
			layout = wibox.layout.fixed.horizontal,
		})

		right_widgets = {
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(6),
			widgets.network,
			widgets.cpu,
			widgets.memory,
			widgets.temperature,
			systray,
			widgets.clock,
			layoutbox_container,
		}
	else
		-- Secondary screens: compact clock + layoutbox
		local simple_clock = wibox.widget({
			{
				{
					text = "",
					font = "JetBrainsMono Nerd Font 9",
					widget = wibox.widget.textbox,
				},
				wibox.widget.textclock("%H:%M", 60),
				spacing = dpi(4),
				layout = wibox.layout.fixed.horizontal,
			},
			left = dpi(5),
			right = dpi(5),
			top = dpi(1),
			bottom = dpi(1),
			widget = wibox.container.margin,
		})

		local simple_clock_container = wibox.widget({
			simple_clock,
			bg = "#44475A80",
			shape = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, dpi(3))
			end,
			widget = wibox.container.background,
		})

		right_widgets = {
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(4),
			simple_clock_container,
			layoutbox_container,
		}
	end

	-- Setup wibar with rounded inner container
	local inner_margin = s == screen.primary and dpi(8) or dpi(4)
	local inner_padding = s == screen.primary and dpi(2) or dpi(1)
	local corner_radius = s == screen.primary and dpi(8) or dpi(6)

	s.mywibox:setup({
		{
			{
				layout = wibox.layout.align.horizontal,
				{ -- Left widgets
					layout = wibox.layout.fixed.horizontal,
					spacing = s == screen.primary and dpi(8) or dpi(4),
					s.mytaglist,
					s.mypromptbox,
				},
				{ -- Middle widget (tasklist)
					s.mytasklist,
					left = s == screen.primary and dpi(16) or dpi(8),
					right = s == screen.primary and dpi(16) or dpi(8),
					widget = wibox.container.margin,
				},
				right_widgets,
			},
			left = inner_margin,
			right = inner_margin,
			top = inner_padding,
			bottom = inner_padding,
			widget = wibox.container.margin,
		},
		bg = "#282A36E8",
		shape = function(cr, w, h)
			gears.shape.rounded_rect(cr, w, h, corner_radius)
		end,
		widget = wibox.container.background,
	})
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(awful.button({}, 4, awful.tag.viewnext), awful.button({}, 5, awful.tag.viewprev)))
-- }}}

-- {{{ Key bindings
root.keys(keys.globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = rules.get(current_env)
-- }}}

-- {{{ Signals
client.connect_signal("manage", function(c)
	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
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
		timeout = 5,
	})
	-- Re-detect environment
	current_env = env.detect()
	local tags = env.get_tags(current_env, s, screen.count())
	awful.tag(tags, s, awful.layout.suit.tile)
end)

screen.connect_signal("removed", function(s)
	naughty.notify({
		title = "Screen Removed",
		text = "Screen disconnected",
		timeout = 5,
	})
end)
-- }}}

-- Initialize scratchpads
scratchpad.init()

-- Initialize widgets (网络、CPU、内存、温度)
widgets.init()

-- Restore dynamic tags
tag_persist.restore()

-- Run autostart applications
autostart.run()
