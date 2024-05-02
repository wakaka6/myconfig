return {

	-- do stuff like :sudowrite
	"lambdalisue/suda.vim",

	require("user.conf.plugins.convenient.toggleterm"),

	-- Plug 'rcarriga/nvim-notify' " notify
	-- Plugin startup speed test
	{
		"dstein64/vim-startuptime",
		-- lazy-load on a command
		cmd = "StartupTime",
		-- init is called during startup. Configuration for vim plugins typically should be set in an init function
		init = function()
			vim.g.startuptime_tries = 10
		end,
	},

	-- Rearrange your windows with ease.
	require("user.conf.plugins.convenient.winshift"),

	require("user.conf.plugins.convenient.table-mode"),

	-- file explorer
	require("user.conf.plugins.convenient.nvim-tree"),

	require("user.conf.plugins.convenient.todo-comments"),
	require("user.conf.plugins.convenient.trouble"),
	require("user.conf.plugins.convenient.auto-session"),
}
