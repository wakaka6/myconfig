--- @sync entry
local function entry(_, job)
	for _ = #cx.tabs, job.args[1] do
		ya.manager_emit("tab_create", { current = true })
	end
	ya.manager_emit("tab_switch", { job.args[1] })
end

return { entry = entry }
