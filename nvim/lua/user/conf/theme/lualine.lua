return {
	"nvim-lualine/lualine.nvim",
	lazy = false,
	priority = 900,
	config = function()
		-- +-------------------------------------------------+
		-- | A | B | C                             X | Y | Z |
		-- +-------------------------------------------------+

		local status_ok, line = pcall(require, "lualine")
		if not status_ok then
			return
		end

		local custom_fname = require("lualine.components.filename"):extend()
		local highlight = require("lualine.highlight")
		local default_status_colors = { saved = "#f8f8f2", modified = "#FF79C6" }

		function custom_fname:init(options)
			custom_fname.super.init(self, options)
			self.status_colors = {
				saved = highlight.create_component_highlight_group(
					{ fg = default_status_colors.saved },
					"filename_status_saved",
					self.options
				),
				modified = highlight.create_component_highlight_group(
					{ fg = default_status_colors.modified },
					"filename_status_modified",
					self.options
				),
			}
			if self.options.color == nil then
				self.options.color = ""
			end
		end

		function custom_fname:update_status()
			local data = custom_fname.super.update_status(self)
			data = highlight.component_format_highlight(
				vim.bo.modified and self.status_colors.modified or self.status_colors.saved
			) .. data
			return data
		end

		local ignore_focus = {
			"coc-explorer",
			"Mundo",
			"help",
			"vim-plug",
			"toggleterm",
			"codeql_panel",
			"codeql_explorer",
			"dapui_watches",
			"dapui_stacks",
			"dapui_breakpoints",
			"dapui_scopes",
			"dapui_console",
			"NvimTree",
		}

		function is_ignore()
			for i = 1, #ignore_focus do
				if vim.bo.filetype == ignore_focus[i] then
					return false
				end
			end
			return true
		end

		function mod_format(str)
			local map_mode = {
				["V-LINE"] = "V-L",
				["V-BLOCK"] = "V-B",
				["S-LINE"] = "S-L",
				["S-BLOCK"] = "S-B",
			}
			return map_mode[str] or str:sub(1, 1)
		end

		function mixed_indent()
			local space_pat = [[\v^ +]]
			local tab_pat = [[\v^\t+]]
			local space_indent = vim.fn.search(space_pat, "nwc")
			local tab_indent = vim.fn.search(tab_pat, "nwc")
			local mixed = (space_indent > 0 and tab_indent > 0)
			local mixed_same_line
			if not mixed then
				mixed_same_line = vim.fn.search([[\v^(\t+ | +\t)]], "nwc")
				mixed = mixed_same_line > 0
			end
			if not mixed then
				return ""
			end
			if mixed_same_line ~= nil and mixed_same_line > 0 then
				return " 󰌓"
			end
			local space_indent_cnt = vim.fn.searchcount({ pattern = space_pat, max_count = 1e3 }).total
			local tab_indent_cnt = vim.fn.searchcount({ pattern = tab_pat, max_count = 1e3 }).total
			if space_indent_cnt > tab_indent_cnt then
				return " 󰌒"
			else
				return ""
			end
		end

		line.setup({
			options = {
				icons_enabled = true,
				theme = "dracula-nvim",
				component_separators = { left = "", right = "" },
				-- section_separators = { left = '', right = ''},
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
				ignore_focus = ignore_focus,
				always_divide_middle = true,
				globalstatus = false,
				refresh = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
				},
			},
			sections = {
				lualine_a = {
					{
						"mode",
						separator = { left = "" },
						right_padding = 2,
						fmt = mod_format,
					},
				},
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { custom_fname, "copilot" },
				lualine_x = {
					"filetype",
					mixed_indent,
				},
				lualine_y = {
					{ "encoding", right_padding = 0 },
					{ "fileformat", left_padding = 0 },
				},
				lualine_z = {
					{
						function()
							return "%3p%%"
						end,
						right_padding = 0,
					},
					{
						function()
							return [[%l %2c]]
						end,
						separator = { right = "" },
						left_padding = 0,
					},
				},
			},
			inactive_sections = {
				lualine_a = { "filetype" },
				lualine_b = {},
				lualine_c = {},
				lualine_x = { "encoding", { "fileformat", separator = { left = "" } } },
				lualine_y = { { "filename", cond = is_ignore } },
				lualine_z = { {
					"%l",
					fmt = function(str)
						return "󰕱" .. str
					end,
				} },
			},
			tabline = {},
			winbar = {},
			inactive_winbar = {},
			extensions = {},
		})
	end,
}
