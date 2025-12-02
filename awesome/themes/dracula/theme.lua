--[[
    Dracula Theme for AwesomeWM
    Modern minimalist style with rounded corners
--]]

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local gfs = require("gears.filesystem")

local theme = {}

-- Dracula color palette
local colors = {
	bg = "#282A36",
	fg = "#F8F8F2",
	selection = "#44475A",
	comment = "#6272A4",
	current_line = "#44475A",
	cyan = "#8BE9FD",
	green = "#50FA7B",
	orange = "#FFB86C",
	pink = "#FF79C6",
	purple = "#BD93F9",
	red = "#FF5555",
	yellow = "#F1FA8C",
	minimized_bg = "#3B3D4A",
	minimized_fg = "#9AABCE",
}

-- Export colors for other modules
theme.colors = colors

-- Font
theme.font = "JetBrains Mono 10"
theme.font_bold = "JetBrains Mono Bold 10"

-- Background
theme.bg_normal = colors.bg
theme.bg_focus = colors.selection
theme.bg_urgent = colors.red
theme.bg_minimize = colors.comment
theme.bg_systray = colors.bg

-- Foreground
theme.fg_normal = colors.fg
theme.fg_focus = colors.fg
theme.fg_urgent = colors.fg
theme.fg_minimize = colors.comment

-- Gaps
theme.useless_gap = dpi(8)
theme.gap_single_client = false

-- Borders
theme.border_width = dpi(3)
theme.border_normal = colors.selection
theme.border_focus = "#F999F8"
theme.border_marked = colors.orange

-- Rounded corners
theme.border_radius = dpi(12)

-- Titlebars
theme.titlebar_bg_focus = colors.selection
theme.titlebar_bg_normal = colors.bg
theme.titlebar_fg_focus = colors.fg
theme.titlebar_fg_normal = colors.comment

-- Wibar (modern floating style)
theme.wibar_height = dpi(28)
theme.wibar_bg = colors.bg .. "00" -- transparent for floating effect
theme.wibar_fg = colors.fg
theme.wibar_inner_bg = colors.bg .. "E8" -- semi-transparent inner
theme.wibar_margin = dpi(8)

-- Taglist (pill style)
theme.taglist_bg_focus = colors.purple
theme.taglist_bg_urgent = colors.red
theme.taglist_bg_occupied = colors.selection
theme.taglist_bg_empty = "transparent"
theme.taglist_bg_volatile = colors.orange

theme.taglist_fg_focus = colors.bg
theme.taglist_fg_urgent = colors.fg
theme.taglist_fg_occupied = colors.fg
theme.taglist_fg_empty = colors.comment
theme.taglist_fg_volatile = colors.bg

theme.taglist_spacing = dpi(6)
theme.taglist_shape = gears.shape.rounded_bar

-- Remove squares, using pill shape instead
theme.taglist_squares_sel = nil
theme.taglist_squares_unsel = nil

-- Tasklist (modern style)
theme.tasklist_bg_focus = colors.selection
theme.tasklist_bg_normal = "transparent"
theme.tasklist_bg_urgent = colors.red .. "80"
theme.tasklist_bg_minimize = colors.minimized_bg
theme.tasklist_fg_focus = colors.fg
theme.tasklist_fg_normal = colors.comment
theme.tasklist_fg_urgent = colors.fg
theme.tasklist_fg_minimize = colors.minimized_fg

theme.tasklist_disable_icon = false
theme.tasklist_plain_task_name = true
theme.tasklist_disable_task_name = false
theme.tasklist_shape = function(cr, w, h)
	gears.shape.rounded_rect(cr, w, h, dpi(8))
end
theme.tasklist_spacing = dpi(4)

-- Notifications (card style)
theme.notification_font = "JetBrains Mono 11"
theme.notification_bg = colors.bg
theme.notification_fg = colors.fg
theme.notification_border_width = dpi(0)
theme.notification_border_color = colors.purple
theme.notification_opacity = 0.95
theme.notification_margin = dpi(16)
theme.notification_width = dpi(400)
theme.notification_max_width = dpi(500)
theme.notification_max_height = dpi(200)
theme.notification_icon_size = dpi(48)
theme.notification_shape = function(cr, w, h)
	gears.shape.rounded_rect(cr, w, h, dpi(12))
end

-- Menu
theme.menu_submenu_icon = nil
theme.menu_height = dpi(28)
theme.menu_width = dpi(200)
theme.menu_bg_normal = colors.bg
theme.menu_bg_focus = colors.selection
theme.menu_fg_normal = colors.fg
theme.menu_fg_focus = colors.fg
theme.menu_border_width = dpi(0)
theme.menu_border_color = colors.selection
theme.menu_shape = function(cr, w, h)
	gears.shape.rounded_rect(cr, w, h, dpi(8))
end

-- Hotkeys popup
theme.hotkeys_bg = colors.bg .. "F0"
theme.hotkeys_fg = colors.fg
theme.hotkeys_border_width = dpi(0)
theme.hotkeys_border_color = colors.purple
theme.hotkeys_modifiers_fg = colors.comment
theme.hotkeys_label_bg = colors.purple
theme.hotkeys_label_fg = colors.bg
theme.hotkeys_font = "JetBrains Mono 11"
theme.hotkeys_description_font = "JetBrains Mono 10"
theme.hotkeys_group_margin = dpi(20)
theme.hotkeys_shape = function(cr, w, h)
	gears.shape.rounded_rect(cr, w, h, dpi(12))
end

-- Tooltips
theme.tooltip_bg = colors.bg
theme.tooltip_fg = colors.fg
theme.tooltip_border_width = dpi(0)
theme.tooltip_border_color = colors.selection
theme.tooltip_shape = function(cr, w, h)
	gears.shape.rounded_rect(cr, w, h, dpi(8))
end

-- Prompt
theme.prompt_bg = colors.selection
theme.prompt_fg = colors.fg
theme.prompt_bg_cursor = colors.fg
theme.prompt_fg_cursor = colors.bg

-- Layout icons directory
local layout_icon_path = gfs.get_themes_dir() .. "default/layouts/"
theme.layout_fairh = layout_icon_path .. "fairhw.png"
theme.layout_fairv = layout_icon_path .. "fairvw.png"
theme.layout_floating = layout_icon_path .. "floatingw.png"
theme.layout_magnifier = layout_icon_path .. "magnifierw.png"
theme.layout_max = layout_icon_path .. "maxw.png"
theme.layout_fullscreen = layout_icon_path .. "fullscreenw.png"
theme.layout_tilebottom = layout_icon_path .. "tilebottomw.png"
theme.layout_tileleft = layout_icon_path .. "tileleftw.png"
theme.layout_tile = layout_icon_path .. "tilew.png"
theme.layout_tiletop = layout_icon_path .. "tiletopw.png"
theme.layout_spiral = layout_icon_path .. "spiralw.png"
theme.layout_dwindle = layout_icon_path .. "dwindlew.png"
theme.layout_cornernw = layout_icon_path .. "cornernww.png"
theme.layout_cornerne = layout_icon_path .. "cornernew.png"
theme.layout_cornersw = layout_icon_path .. "cornersww.png"
theme.layout_cornerse = layout_icon_path .. "cornersew.png"

-- Generate Awesome icon
theme.awesome_icon = theme_assets.awesome_icon(dpi(24), colors.purple, colors.bg)

-- Snap edge distance
theme.snap_bg = colors.purple
theme.snap_border_width = dpi(4)
theme.snap_shape = function(cr, w, h)
	gears.shape.rounded_rect(cr, w, h, dpi(8))
end

-- Icon theme
theme.icon_theme = "Papirus-Dark"

-- Systray
theme.systray_icon_spacing = dpi(4)
theme.bg_systray = colors.bg

return theme
