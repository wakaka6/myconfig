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
		},
	},
}
