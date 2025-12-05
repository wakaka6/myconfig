local M = {}

local rules = require("modules.rules")
local scratchpad = require("modules.scratchpad")

function M.get_client_by_pid(pid)
	for _, c in ipairs(client.get()) do
		if c.pid == pid then
			return c
		end
	end
	return nil
end

function M.get_ppid(pid)
	local f = io.open("/proc/" .. pid .. "/stat", "r")
	if not f then
		return nil
	end
	local stat = f:read("*all")
	f:close()
	local ppid = stat:match("^%d+%s+%b()%s+%S+%s+(%d+)")
	return tonumber(ppid)
end

function M.find_parent_client(pid, max_depth)
	max_depth = max_depth or 10
	local current_pid = pid
	for _ = 1, max_depth do
		if not current_pid or current_pid <= 1 then
			return nil
		end
		local parent_client = M.get_client_by_pid(current_pid)
		if parent_client then
			if parent_client.instance and scratchpad.INSTANCES[parent_client.instance] then
				current_pid = M.get_ppid(current_pid)
			else
				return parent_client
			end
		else
			current_pid = M.get_ppid(current_pid)
		end
	end
	return nil
end

function M.get_parent_screen(c)
	if not c.pid then
		return nil
	end
	local ppid = M.get_ppid(c.pid)
	if not ppid then
		return nil
	end
	local parent_client = M.find_parent_client(ppid)
	if parent_client and parent_client.screen then
		return parent_client.screen
	end
	return nil
end

function M.is_app_rule_matched(c)
	if not c.class then
		return false
	end
	for _, rule in ipairs(rules.APP_RULES) do
		for _, class in ipairs(rule.class) do
			if c.class == class then
				return true
			end
		end
	end
	return false
end

return M
