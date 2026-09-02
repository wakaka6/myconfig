--[[
    Center Master Layout
    Three-column layout with master in the center
    [Left 1/3 | Center Master 1/3 | Right 1/3]
--]]

local gears = require("gears")
local wibox = require("wibox")

local center_master = {}
center_master.name = "center_master"

function center_master.arrange(p)
    local area = p.workarea
    local t = p.tag or screen[p.screen].selected_tag
    local clients = p.clients

    if #clients == 0 then
        return
    end

    -- Get layout parameters
    -- AwesomeWM defaults master_width_factor to 0.5, but center_master needs 1/3 for equal columns
    local raw_mwf = t.master_width_factor
    local master_width_factor = (raw_mwf and raw_mwf ~= 0.5) and raw_mwf or (1 / 3)

    -- Calculate widths
    local master_width = area.width * master_width_factor
    local slave_width = (area.width - master_width) / 2

    if #clients == 1 then
        -- Only one window: fullscreen
        local g = {
            x = area.x,
            y = area.y,
            width = area.width,
            height = area.height,
        }
        p.geometries[clients[1]] = g
    elseif #clients == 2 then
        -- Two windows: split evenly left and right
        local half_width = area.width / 2
        local g_left = {
            x = area.x,
            y = area.y,
            width = half_width,
            height = area.height,
        }
        local g_right = {
            x = area.x + half_width,
            y = area.y,
            width = half_width,
            height = area.height,
        }
        p.geometries[clients[1]] = g_left
        p.geometries[clients[2]] = g_right
    else
        -- Three or more windows: master in center, slaves on left and right
        local g_master = {
            x = area.x + slave_width,
            y = area.y,
            width = master_width,
            height = area.height,
        }
        p.geometries[clients[1]] = g_master

        -- Left side slaves
        local left_clients = math.ceil((#clients - 1) / 2)
        local left_height = math.floor(area.height / left_clients)
        for i = 2, left_clients + 1 do
            local is_last = (i == left_clients + 1)
            local height = is_last and (area.height - (i - 2) * left_height) or left_height
            local g = {
                x = area.x,
                y = area.y + (i - 2) * left_height,
                width = slave_width,
                height = height,
            }
            p.geometries[clients[i]] = g
        end

        -- Right side slaves
        local right_clients = #clients - left_clients - 1
        if right_clients > 0 then
            local right_height = math.floor(area.height / right_clients)
            for i = left_clients + 2, #clients do
                local idx = i - left_clients - 1
                local is_last = (i == #clients)
                local height = is_last and (area.height - (idx - 1) * right_height) or right_height
                local g = {
                    x = area.x + slave_width + master_width,
                    y = area.y + (idx - 1) * right_height,
                    width = slave_width,
                    height = height,
                }
                p.geometries[clients[i]] = g
            end
        end
    end
end

-- Icon for the layout (optional)
center_master.icon = nil

return center_master
