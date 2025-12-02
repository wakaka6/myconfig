--[[
    Window Rules Module
    Migrated from i3wm for_window rules
--]]

local awful = require("awful")
local beautiful = require("beautiful")
local keys = require("modules.keys")
local env = require("env.detect")

local M = {}

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
            }
        },

        -- Floating clients
        {
            rule_any = {
                instance = {
                    "DTA",
                    "copyq",
                    "pinentry",
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
                }
            },
            properties = { floating = true }
        },

        -- Dialogs are always floating and centered
        {
            rule_any = { type = { "dialog" } },
            properties = {
                floating = true,
                placement = awful.placement.centered,
            }
        },

        -- GoldenDict floating
        {
            rule = { class = "GoldenDict" },
            properties = {
                floating = true,
                width = 800,
                height = 600,
            }
        },

        -- Picture-in-picture (always on top)
        {
            rule = { name = "Picture-in-Picture" },
            properties = {
                floating = true,
                ontop = true,
                sticky = true,
            }
        },
    }

    -- Environment-specific rules
    if current_env == "office" then
        -- Office: 3 screens (根据角色匹配)
        -- primary: 开发主力
        -- secondary: 浏览器/聊天
        -- tertiary: debug/db/远程

        -- === secondary: 浏览器/聊天 ===
        table.insert(rules, {
            rule_any = { class = { "Google-chrome", "Chromium", "firefox", "Firefox" } },
            properties = {
                screen = function() return env.get_screen_by_role(env.ROLE_SECONDARY) end,
                tag = "web"
            }
        })
        table.insert(rules, {
            rule_any = { class = { "Slack", "discord", "Discord", "TelegramDesktop", "WeChat", "wechat", "feishu", "Feishu", "bytedance-feishu", "Lark" } },
            properties = {
                screen = function() return env.get_screen_by_role(env.ROLE_SECONDARY) end,
                tag = "chat"
            }
        })

        -- === tertiary: debug/数据库/远程 ===
        table.insert(rules, {
            rule_any = { class = { "DBeaver", "jetbrains-datagrip", "DataGrip", "Navicat", "pgadmin4" } },
            properties = {
                screen = function() return env.get_screen_by_role(env.ROLE_TERTIARY) end,
                tag = "db"
            }
        })
        table.insert(rules, {
            rule_any = { class = { "Remmina", "rdesktop", "xfreerdp", "Vncviewer", "virt-manager" } },
            properties = {
                screen = function() return env.get_screen_by_role(env.ROLE_TERTIARY) end,
                tag = "rdp"
            }
        })

        -- === primary: 开发主力 (自由使用，不设规则) ===

    elseif current_env == "home" then
        -- Home: 2 screens
        table.insert(rules, {
            rule_any = { class = { "Google-chrome", "Chromium", "firefox", "Firefox" } },
            properties = {
                screen = function() return env.get_screen_by_role(env.ROLE_SECONDARY) end,
                tag = "web"
            }
        })
        table.insert(rules, {
            rule_any = { class = { "Slack", "discord", "Discord" } },
            properties = {
                screen = function() return env.get_screen_by_role(env.ROLE_SECONDARY) end,
                tag = "chat"
            }
        })
    else
        -- Single screen
        table.insert(rules, {
            rule_any = { class = { "Google-chrome", "Chromium", "firefox", "Firefox" } },
            properties = { tag = "3" }
        })
    end

    return rules
end

return M
