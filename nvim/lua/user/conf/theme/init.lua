if vim.g.vscode then
	return {}
end

return {
	require("user.conf.theme.colorscheme").custom,
	"ryanoasis/vim-devicons",
	require("user.conf.theme.lualine"),
	require("user.conf.theme.bufferline"),
	require("user.conf.theme.dashboard"),
	{
		"Bekaboo/dropbar.nvim",
		-- optional, but required for fuzzy finder support
		dependencies = {
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
		config = function()
			local dropbar_api = require("dropbar.api")
			vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
			vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
			vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
		end,
	},
}
