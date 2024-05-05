local M = {}
M.offical = {
	"github/copilot.vim",
	config = function()
		vim.g.copilot_enabled = true
		vim.g.copilot_no_tab_map = true
		-- vim.g.copilot_proxy = 'socks5://127.0.0.1:1088'
		vim.api.nvim_set_keymap("n", "<leader>co", ":Copilot<CR>", { silent = true })
		vim.api.nvim_set_keymap("n", "<leader>ce", ":Copilot enable<CR>", { silent = true })
		vim.api.nvim_set_keymap("n", "<leader>cx", ":Copilot disable<CR>", { silent = true })
		vim.cmd('imap <silent><script><expr> <C-l> copilot#Accept("")')
		vim.cmd([[
            let g:copilot_filetypes = { 'TelescopePrompt': v:false, }
        ]])
	end,
}

M.lua = {
	{
		"zbirenbaum/copilot.lua",
		build = ":Copilot auth",
		config = function()
			require("copilot").setup({
				suggestion = { enabled = false },
				panel = { enabled = false },
				filetypes = {
					-- markdown = true,
					-- help = true,
					["*"] = true,
				},
			})
			vim.api.nvim_set_keymap("n", "<leader>co", "<cmd>Copilot<CR>", { silent = true })
			vim.api.nvim_set_keymap("n", "<leader>ce", "<cmd>Copilot enable<CR>", { silent = true })
			vim.api.nvim_set_keymap("n", "<leader>cx", "<cmd>Copilot disable<CR>", { silent = true })
		end,
	},
	{
		"zbirenbaum/copilot-cmp",
		dependencies = { "zbirenbaum/copilot.lua" },
		config = function()
			require("copilot_cmp").setup()
		end,
	},
	{
		"AndreM222/copilot-lualine",
		dependencies = { "zbirenbaum/copilot.lua" },
	},
}

return M
