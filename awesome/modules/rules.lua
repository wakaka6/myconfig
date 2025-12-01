--[[
    Window Rules Module
    Migrated from i3wm for_window rules
--]]

local awful = require("awful")
local beautiful = require("beautiful")
local keys = require("modules.keys")

local M = {}

function M.get(env)
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
    if env == "office" then
        -- Office: 3 screens
        table.insert(rules, {
            rule = { class = "Google-chrome" },
            properties = { screen = 2, tag = "web" }
        })
        table.insert(rules, {
            rule = { class = "Slack" },
            properties = { screen = 2, tag = "chat" }
        })
        table.insert(rules, {
            rule = { class = "discord" },
            properties = { screen = 2, tag = "chat" }
        })
        table.insert(rules, {
            rule_any = { class = { "Spotify", "spotify" } },
            properties = { screen = 3, tag = "media" }
        })
        table.insert(rules, {
            rule = { class = "obs" },
            properties = { screen = 3, tag = "media" }
        })
    elseif env == "home" then
        -- Home: 2 screens
        table.insert(rules, {
            rule = { class = "Google-chrome" },
            properties = { screen = 1, tag = "web" }
        })
        table.insert(rules, {
            rule = { class = "Slack" },
            properties = { screen = 2, tag = "chat" }
        })
        table.insert(rules, {
            rule = { class = "discord" },
            properties = { screen = 2, tag = "chat" }
        })
        table.insert(rules, {
            rule_any = { class = { "Spotify", "spotify" } },
            properties = { screen = 2, tag = "media" }
        })
    else
        -- Single screen
        table.insert(rules, {
            rule = { class = "Google-chrome" },
            properties = { tag = "3" }
        })
    end

    return rules
end

return M
