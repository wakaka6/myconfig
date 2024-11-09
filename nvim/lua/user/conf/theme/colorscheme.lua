local M = {}

M.custom = {
	"wakaka6/dracula.nvim",
	branch = "custom",
	lazy = false,
	priority = 1100,
	config = function()
		local dracula = require("dracula")
		dracula.setup({
			-- show the '~' characters after the end of buffers
			show_end_of_buffer = true, -- default false
			-- use transparent background
			transparent_bg = true,
			italic_comment = true, -- default false
		})
		vim.cmd("colorscheme dracula")
	end,
}

M.dracula = {
	"Mofiqul/dracula.nvim",
	lazy = false,
	priority = 1100,
	config = function()
		vim.cmd("colorscheme dracula")
	end,
}

return M
