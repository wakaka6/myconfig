return {
	"voldikss/vim-translator",
	keys = {
		{ "<leader>ct", "<cmd>TranslateW<CR>", mode = "n", noremap = true, silent = true, desc = "translate" },
		{ "<leader>ct", "<cmd>TranslateW<CR>", mode = "v", noremap = true, silent = true, desc = "translate" },
	},
	init = function()
		-- vim.g.translator_proxy_url = 'socks5://127.0.0.1:1080',
	end,
}
