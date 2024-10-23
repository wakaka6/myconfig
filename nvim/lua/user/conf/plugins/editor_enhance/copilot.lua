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

M.avante = {
	"yetone/avante.nvim",
	event = "VeryLazy",
	lazy = false,
	version = false, -- set this if you want to always pull the latest change
	opts = {
		---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
		provider = "copilot", -- Recommend using Claude
		auto_suggestions_provider = "copilot",
		vendors = {
			---@type AvanteProvider
			ollama = {
				["local"] = true,
				endpoint = "127.0.0.1:11434/v1",
				model = "openbuddy/openbuddy-llama3-8b-v21.1-8k",
				parse_curl_args = function(opts, code_opts)
					return {
						url = opts.endpoint .. "/chat/completions",
						headers = {
							["Accept"] = "application/json",
							["Content-Type"] = "application/json",
						},
						body = {
							model = opts.model,
							messages = require("avante.providers").copilot.parse_message(code_opts), -- you can make your own message, but this is very advanced
							max_tokens = 8000,
							stream = true,
						},
					}
				end,
				parse_response_data = function(data_stream, event_state, opts)
					require("avante.providers").openai.parse_response(data_stream, event_state, opts)
				end,
			},
		},
		behaviour = {
			auto_suggestions = false, -- Experimental stage
			auto_set_highlight_group = true,
			auto_set_keymaps = true,
			auto_apply_diff_after_generation = false,
			support_paste_from_clipboard = false,
		},
		mappings = {
			--- @class AvanteConflictMappings
			diff = {
				ours = "co",
				theirs = "ct",
				all_theirs = "ca",
				both = "cb",
				cursor = "cc",
				next = "]x",
				prev = "[x",
			},
			suggestion = {
				accept = "<C-l>",
				next = "<M-]>",
				prev = "<M-[>",
				dismiss = "<C-]>",
			},
			jump = {
				next = "]]",
				prev = "[[",
			},
			submit = {
				normal = "<CR>",
				insert = "<C-s>",
			},
			sidebar = {
				apply_all = "A",
				apply_cursor = "a",
				switch_windows = "<Tab>",
				reverse_switch_windows = "<S-Tab>",
			},
		},
		hints = { enabled = true },
		windows = {
			---@type "right" | "left" | "top" | "bottom"
			position = "right", -- the position of the sidebar
			wrap = true, -- similar to vim.o.wrap
			width = 30, -- default % based on available width
			sidebar_header = {
				enabled = true, -- true, false to enable/disable the header
				align = "center", -- left, center, right for title
				rounded = true,
			},
			input = {
				prefix = "󱍊 ",
			},
			edit = {
				border = "rounded",
				start_insert = true, -- Start insert mode when opening the edit window
			},
			ask = {
				floating = false, -- Open the 'AvanteAsk' prompt in a floating window
				start_insert = true, -- Start insert mode when opening the ask window, only effective if floating = true.
				border = "rounded",
			},
		},
		highlights = {
			---@type AvanteConflictHighlights
			diff = {
				current = "DiffText",
				incoming = "DiffAdd",
			},
		},
		--- @class AvanteConflictUserConfig
		diff = {
			autojump = true,
			---@type string | fun(): any
			list_opener = "copen",
		},
	},
	-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
	build = "make",
	-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- The below dependencies are optional,
		"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
		M.lua, -- for providers='copilot'
		{
			-- support for image pasting
			"HakonHarnes/img-clip.nvim",
			event = "VeryLazy",
		},
		{
			-- Make sure to set this up properly if you have lazy=true
			-- replace project "OXY2DEV/markview.nvim"
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
}

return M
