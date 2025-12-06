local M = {}

local agents_dir = debug.getinfo(1, "S").source:match("@(.*/)")
local loaded = {}

local function load_agent(name)
	local path = agents_dir .. name .. ".lua"
	local f = loadfile(path)
	if f then
		local ok, agent = pcall(f)
		if ok and agent and agent.id then
			return agent
		end
	end
	return nil
end

local agent_files = { "save_notes", "ask_notes" }

for _, name in ipairs(agent_files) do
	local agent = load_agent(name)
	if agent then
		loaded[agent.id] = agent
	end
end

function M.get(id)
	return loaded[id]
end

function M.all()
	return loaded
end

function M.list()
	local result = {}
	for _, agent in pairs(loaded) do
		table.insert(result, {
			id = agent.id,
			icon = agent.icon,
			label = agent.label,
		})
	end
	return result
end

return M
