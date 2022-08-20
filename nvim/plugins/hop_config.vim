lua<<EOF
local status_ok, hop = pcall(require, "hop")
if not status_ok then
	return
end

hop.setup({
    -- quit_key = '<SPC>',
    case_insensitive = false,
    multi_windows = true,

})

EOF
