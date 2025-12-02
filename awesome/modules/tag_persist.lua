--[[
    Tag Persistence Module
    保存和恢复动态创建的 tags
--]]

local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local M = {}

-- 持久化文件路径
local cache_dir = gears.filesystem.get_cache_dir()
local persist_file = cache_dir .. "dynamic_tags.json"

-- 获取屏幕输出名称
local function get_screen_output(s)
    if s.outputs then
        for name, _ in pairs(s.outputs) do
            return name
        end
    end
    return tostring(s.index)
end

-- 保存动态 tags 到文件
function M.save()
    local data = {}

    for s in screen do
        local output = get_screen_output(s)
        data[output] = {}

        for _, t in ipairs(s.tags) do
            -- 标记为动态创建的 tag
            if t.dynamic then
                table.insert(data[output], {
                    name = t.name,
                    layout = awful.layout.getname(t.layout),
                    index = t.index,
                })
            end
        end
    end

    -- 写入文件
    local file = io.open(persist_file, "w")
    if file then
        -- 简单的 JSON 序列化
        local json = "{\n"
        local first_screen = true
        for output, tags in pairs(data) do
            if #tags > 0 then
                if not first_screen then json = json .. ",\n" end
                first_screen = false
                json = json .. string.format('  "%s": [', output)
                for i, t in ipairs(tags) do
                    if i > 1 then json = json .. ", " end
                    json = json .. string.format('{"name": "%s", "index": %d}', t.name, t.index)
                end
                json = json .. "]"
            end
        end
        json = json .. "\n}"
        file:write(json)
        file:close()
    end
end

-- 从文件恢复动态 tags
function M.restore()
    local file = io.open(persist_file, "r")
    if not file then
        return
    end

    local content = file:read("*all")
    file:close()

    if not content or content == "" then
        return
    end

    -- 简单的 JSON 解析
    for output, tags_json in content:gmatch('"([^"]+)":%s*%[(.-)%]') do
        -- 找到对应屏幕
        local target_screen = nil
        for s in screen do
            if get_screen_output(s) == output then
                target_screen = s
                break
            end
        end

        if target_screen then
            -- 解析每个 tag
            for name, index in tags_json:gmatch('{"name":%s*"([^"]+)",%s*"index":%s*(%d+)}') do
                -- 检查是否已存在
                local exists = false
                for _, t in ipairs(target_screen.tags) do
                    if t.name == name then
                        exists = true
                        break
                    end
                end

                if not exists then
                    local t = awful.tag.add(name, {
                        screen = target_screen,
                        layout = awful.layout.suit.tile,
                    })
                    t.dynamic = true  -- 标记为动态

                    -- 尝试移动到正确位置
                    local target_index = tonumber(index)
                    if target_index and target_index <= #target_screen.tags then
                        t.index = target_index
                    end
                end
            end
        end
    end
end

-- 创建动态 tag（带持久化标记）
function M.create_tag(name, s)
    local t = awful.tag.add(name, {
        screen = s or awful.screen.focused(),
        layout = awful.layout.suit.tile,
    })
    t.dynamic = true  -- 标记为动态创建
    t:view_only()
    M.save()  -- 保存
    return t
end

-- 删除 tag（并更新持久化）
function M.delete_tag(t)
    if t then
        t:delete()
        M.save()  -- 保存
    end
end

-- 重命名 tag（并更新持久化）
function M.rename_tag(t, new_name)
    if t and new_name then
        t.name = new_name
        M.save()  -- 保存
    end
end

return M
