return {
	{
		"SirVer/ultisnips",
		depencency = { "honza/vim-snippets" },
		config = function()
			-- vim.g.UltiSnipsExpandTrigger = "<tab>"
			-- vim.g.UltiSnipsJumpForwardTrigger = "<c-j>"
			-- vim.g.UltiSnipsJumpBackwardTrigger = "<c-k>"
			vim.g.UltiSnipsSnippetDirectories = { "~/.config/nvim/mysnippets", "UltiSnips" }
			vim.g.UltiSnipsEditSplit = "vertical"
		end,
	},
}
