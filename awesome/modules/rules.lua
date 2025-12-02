--[[
    Window Rules Module
    Migrated from i3wm for_window rules
--]]

local awful = require("awful")
local beautiful = require("beautiful")
local keys = require("modules.keys")
local env = require("envws.detect")

local M = {}

local APP_RULES = {
	{
		tag = "web",
		class = { "Google-chrome", "Chromium", "firefox", "Firefox" },
	},
	{
		tag = "chat",
		class = {
			"Slack",
			"discord",
			"Discord",
			"TelegramDesktop",
			"WeChat",
			"wechat",
			"feishu",
			"Feishu",
			"bytedance-feishu",
			"Lark",
		},
	},
	{
		tag = "db",
		class = { "DBeaver", "jetbrains-datagrip", "DataGrip", "Navicat", "pgadmin4" },
	},
	{
		tag = "rdp",
		class = { "Remmina", "rdesktop", "xfreerdp", "Vncviewer", "virt-manager" },
	},
}

function M.get(current_env)
	local rules = {
		-- Default rule for all clients
		{
			rule = {},
			properties = {
				border_width = beautiful.border_width,
				border_color = beautiful.border_normal,
				focus = awful.client.focus.filter,
				raise = true,
				keys = keys.clientkeys,
				buttons = keys.clientbuttons,
				screen = awful.screen.preferred,
				placement = awful.placement.no_overlap + awful.placement.no_offscreen,
			},
		},

		-- Floating clients
		{
			rule_any = {
				instance = {
					"DTA",
					"copyq",
					"pinentry",
					"scratch_claude_query",
				},
				class = {
					"Arandr",
					"Blueman-manager",
					"Gpick",
					"Kruler",
					"MessageWin",
					"Sxiv",
					"Tor Browser",
					"Wpa_gui",
					"veromix",
					"xtightvncviewer",
					"flameshot",
					"Pavucontrol",
					"Nm-connection-editor",
				},
				name = {
					"Event Tester",
				},
				role = {
					"AlarmWindow",
					"ConfigManager",
					"pop-up",
					"bubble",
				},
			},
			properties = { floating = true, border_width = 0 },
		},

		-- Dialogs are always floating and centered
		{
			rule_any = { type = { "dialog" } },
			properties = {
				floating = true,
				placement = awful.placement.centered,
			},
		},

		-- GoldenDict floating
		{
			rule = { class = "GoldenDict" },
			properties = {
				floating = true,
				width = 800,
				height = 600,
			},
		},

		-- Picture-in-picture (always on top)
		{
			rule = { name = "Picture-in-Picture" },
			properties = {
				floating = true,
				ontop = true,
				sticky = true,
			},
		},
	}

	-- 根据 APP_RULES 自动生成规则，screen 由 tag 位置自动决定
	for _, app_rule in ipairs(APP_RULES) do
		local tag_name = app_rule.tag
		table.insert(rules, {
			rule_any = { class = app_rule.class },
			properties = {
				screen = function()
					return env.get_screen_by_tag(tag_name)
				end,
				tag = tag_name,
			},
		})
	end

	return rules
end

return M
