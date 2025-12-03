--[[
    Scratchpad Module
    Implements dropdown/scratchpad windows like i3
    Based on your i3 config: translate, AItrans, ChatGPT
--]]

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")

local M = {}

-- State file path
local state_file = gears.filesystem.get_cache_dir() .. "scratchpad_state"

-- Scratchpad definitions
local scratchpads = {
	translate = {
		command = "st -n translate -e proxychains -q trans -shell -t zh -4 -sp",
		instance = "translate",
		width = 850,
		height = 600,
		sticky = true,
	},
	claude = {
		command = "alacritty --class scratch_claude -e zsh -ic 'cd ~/Documents/scratchpad && claude'",
		instance = "scratch_claude",
		width = 1200,
		height = 800,
		sticky = false,
	},
	notes = {
		command = "alacritty --class scratch_notes -e bash -c 'cd ~/Documents/scratchpad && nvim $(date +%Y-%m-%d).md'",
		instance = "scratch_notes",
		width = 1200,
		height = 800,
		sticky = true,
	},
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

-- Save scratchpad visibility state
local function save_state()
	local state = {}
	for name, config in pairs(scratchpads) do
		local c = find_client(config.instance)
		if c then
			state[name] = not c.hidden
		end
	end
	local file = io.open(state_file, "w")
	if file then
		for name, visible in pairs(state) do
			file:write(name .. "=" .. tostring(visible) .. "\n")
		end
		file:close()
	end
end

-- Load scratchpad visibility state
local function load_state()
	local state = {}
	local file = io.open(state_file, "r")
	if file then
		for line in file:lines() do
			local name, visible = line:match("(.+)=(.+)")
			if name and visible then
				state[name] = visible == "true"
			end
		end
		file:close()
	end
	return state
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

-- Move client to current tag
local function move_to_current_tag(c)
	local current_tag = awful.screen.focused().selected_tag
	if current_tag then
		c:move_to_tag(current_tag)
	end
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
		local current_screen = awful.screen.focused()
		local current_tag = current_screen.selected_tag

		-- Check if client is on current tag
		local on_current_tag = false
		if current_tag then
			for _, t in ipairs(c:tags()) do
				if t == current_tag then
					on_current_tag = true
					break
				end
			end
		end

		if c.hidden then
			-- Show it
			c.hidden = false
			c:move_to_screen(current_screen)
			if not config.sticky then
				move_to_current_tag(c)
			end
			setup_scratchpad(c, config)
			c:emit_signal("request::activate", "scratchpad", { raise = true })
		elseif c == client.focus and on_current_tag then
			-- Currently focused on current tag, hide it
			c.hidden = true
		elseif not on_current_tag and not config.sticky then
			-- Exists on another tag, move to current tag
			c:move_to_screen(current_screen)
			move_to_current_tag(c)
			setup_scratchpad(c, config)
			c:emit_signal("request::activate", "scratchpad", { raise = true })
		else
			-- Exists on current tag but not focused, bring to focus
			c:move_to_screen(current_screen)
			setup_scratchpad(c, config)
			c:emit_signal("request::activate", "scratchpad", { raise = true })
		end
		save_state()
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
	local saved_state = load_state()

	-- Save state before restart
	awesome.connect_signal("exit", function()
		save_state()
	end)

	-- Add rules for each scratchpad
	for name, config in pairs(scratchpads) do
		-- Connect signal for when client is created
		client.connect_signal("manage", function(c)
			if c.instance == config.instance then
				setup_scratchpad(c, config)
				scratchpad_clients[name] = c

				-- On restart, restore previous state
				if awesome.startup then
					local was_visible = saved_state[name]
					c.hidden = not was_visible
				end
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
				end,
			})
		end
	end
end

return M
