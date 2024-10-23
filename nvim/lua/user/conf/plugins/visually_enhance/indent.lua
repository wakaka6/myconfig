local M = {}
M.indent_blankline = {
	"lukas-reineke/indent-blankline.nvim",
	config = function()
		vim.opt.list = true
		vim.opt.listchars:append("eol:↴")
		-- vim.opt.listchars:append "space:⋅"

		local highlight = {
			"RainbowRed",
			"RainbowYellow",
			"RainbowBlue",
			"RainbowOrange",
			"RainbowGreen",
			"RainbowViolet",
			"RainbowCyan",
		}

		local hooks = require("ibl.hooks")
		-- create the highlight groups in the highlight setup hook, so they are reset
		-- every time the colorscheme changes
		hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
			vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
			vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
			vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
			vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
			vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
			vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
			vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
		end)

		require("ibl").setup({
			indent = {
				highlight = highlight,
				char = { "│", "|", "¦", "┆" },
				tab_char = { "" },
			},
			exclude = {
				filetypes = {
					"lsp",
					"packer",
					"vim-plug",
					"checkhealth",
					"text",
					"dashboard",
					"coc-explorer",
					"man",
					"help",
					"translator",
				},
				buftypes = { "terminal", "nofile", "quickfix", "prompt" },
			},
			whitespace = {
				highlight = highlight,
				remove_blankline_trail = false,
			},
			scope = {
				highlight = highlight,
				enabled = true,
			},
		})
	end,
}

M.hlchunk = {
	"shellRaining/hlchunk.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	event = "VeryLazy",
	config = function()
		local cb = function()
			return "#F1FA8C"
		end
		-- vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, { pattern = "*", command = "EnableHL" })

		-- exclude some filetypes
		local default_exclude_ft = require("hlchunk.utils.filetype").exclude_filetypes
		local exclude_ft = {
			translator = true,
			dashboard = true,
		}
		for k, v in pairs(default_exclude_ft) do
			exclude_ft[k] = v
		end

		require("hlchunk").setup({
			chunk = {
				enable = true,
				use_treesitter = true,
				style = {
					{ fg = cb },
				},
			},
			indent = {
				chars = { "│", "¦", "┆", "┊" },
				use_treesitter = false,
				style = {
					{ fg = "#6272a4" },
				},
				exclude_filetype = exclude_ft,
			},
			blank = {
				enable = false,
			},
			line_num = {
				use_treesitter = true,
				style = {
					{ fg = cb },
				},
			},
		})
	end,
}

return M
