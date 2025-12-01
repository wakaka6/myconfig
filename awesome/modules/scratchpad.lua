--[[
    Scratchpad Module
    Implements dropdown/scratchpad windows like i3
    Based on your i3 config: translate, AItrans, ChatGPT
--]]

local awful = require("awful")
local beautiful = require("beautiful")

local M = {}

-- Scratchpad definitions
local scratchpads = {
    translate = {
        command = "st -n translate -e proxychains -q trans -shell -t zh -4 -sp",
        instance = "translate",
        width = 850,
        height = 600,
        sticky = true,
    },
    -- 在这里添加更多 scratchpad
    -- example = {
    --     command = "alacritty --class example",
    --     instance = "example",
    --     width = 1200,
    --     height = 800,
    --     sticky = true,
    -- },
}

-- Track scratchpad clients
local scratchpad_clients = {}

-- Find client by instance
local function find_client(instance)
    for _, c in ipairs(client.get()) do
        if c.instance == instance then
            return c
        end
    end
    return nil
end

-- Center and resize scratchpad
local function setup_scratchpad(c, config)
    c.floating = true
    c.sticky = config.sticky or false
    c.ontop = true
    c.skip_taskbar = true

    -- Get focused screen geometry
    local screen_geo = awful.screen.focused().geometry

    -- Calculate size (max 90% of screen)
    local width = math.min(config.width, screen_geo.width * 0.9)
    local height = math.min(config.height, screen_geo.height * 0.9)

    -- Center on screen
    local x = screen_geo.x + (screen_geo.width - width) / 2
    local y = screen_geo.y + (screen_geo.height - height) / 2

    c:geometry({
        x = x,
        y = y,
        width = width,
        height = height,
    })

    -- Set border
    c.border_width = beautiful.border_width or 2
    c.border_color = beautiful.border_focus
end

-- Toggle scratchpad visibility
function M.toggle(name)
    local config = scratchpads[name]
    if not config then
        return
    end

    local c = find_client(config.instance)

    if c then
        -- Client exists
        if c.hidden then
            -- Show it
            c.hidden = false
            c:move_to_screen(awful.screen.focused())
            setup_scratchpad(c, config)
            c:emit_signal("request::activate", "scratchpad", { raise = true })
        elseif c == client.focus then
            -- Currently focused, hide it
            c.hidden = true
        else
            -- Exists but not focused, bring to focus
            c:move_to_screen(awful.screen.focused())
            setup_scratchpad(c, config)
            c:emit_signal("request::activate", "scratchpad", { raise = true })
        end
    else
        -- Client doesn't exist, spawn it
        awful.spawn(config.command, {
            floating = true,
            sticky = config.sticky,
            ontop = true,
        })
    end
end

-- Initialize scratchpad rules
function M.init()
    -- Add rules for each scratchpad
    for name, config in pairs(scratchpads) do
        -- Connect signal for when client is created
        client.connect_signal("manage", function(c)
            if c.instance == config.instance then
                setup_scratchpad(c, config)
                scratchpad_clients[name] = c

                -- Hide on unfocus (optional, comment out if you don't want this)
                -- c:connect_signal("unfocus", function()
                --     c.hidden = true
                -- end)
            end
        end)
    end
end

-- Spawn all scratchpads at startup (hidden)
function M.spawn_all()
    for name, config in pairs(scratchpads) do
        if not find_client(config.instance) then
            awful.spawn(config.command, {
                callback = function(c)
                    if c then
                        setup_scratchpad(c, config)
                        c.hidden = true
                    end
                end
            })
        end
    end
end

return M
