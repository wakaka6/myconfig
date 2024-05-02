return {
	"lervag/vimtex",
	lazy = false, -- we don't want to lazy load VimTeX
	ft = "tex", -- load only for TeX files
	tag = "v2.15", -- uncomment to pin to a specific release
	init = function()
		if vim.bo.filetype == "tex" then
			-- Define a custom shortcut to trigger VimtexView
			vim.api.nvim_set_keymap("n", "<localleader>v", "<plug>(vimtex-view)", { noremap = true, silent = true })
			-- Use `<localleader>vc` to trigger continuous compilation...
			vim.api.nvim_set_keymap("n", "<C-p>", "<Plug>(vimtex-compile)", { noremap = true, silent = true })
			-- Use `dsm` to delete surrounding math (replacing the default shorcut `ds$`)
			vim.api.nvim_set_keymap("n", "dsm", "<Plug>(vimtex-env-delete-math)", { noremap = true, silent = true })
			-- Use `tsm` to toggle surrounding math (replacing the default shorcut `ts$`)
			vim.api.nvim_set_keymap("n", "tsm", "<Plug>(vimtex-env-toggle-math)", { noremap = true, silent = true })
		end
		-- Viewer method
		vim.g.vimtex_view_method = "zathura"

		-- Or with a generic interface
		vim.g.vimtex_view_general_viewer = "okular"
		vim.g.vimtex_view_general_options = "--unique file:@pdf\\#src:@line@tex"
		vim.g.vimtex_compiler_method = "latexmk"

		vim.g.vimtex_compiler_latexmk = {
			build_dir = "vimtex_tmp",
			callback = 1,
			continuous = 1,
			executable = "latexmk",
			hooks = {},
			options = {
				"-verbose",
				"-file-line-error",
				"-halt-on-error",
				"-synctex=1",
				"-interaction=nonstopmode",
			},
		}

		-- Enable/disable functions
		vim.g.vimtex_quickfix_open_on_warning = false

		-- Turn off VimTeX indentation (if needed, uncomment the next line)
		-- vim.g.vimtex_indent_enabled = false

		-- Disable insert mode mappings
		vim.g.vimtex_imaps_enabled = false

		-- Turn off completion
		vim.g.vimtex_complete_enabled = false

		-- Syntax conceal
		vim.g.vimtex_syntax_enabled = true
		vim.g.vimtex_syntax_conceal = {
			accents = 1,
			cites = 1,
			fancy = 1,
			greek = 1,
			math_bounds = 1,
			math_delimiters = 1,
			math_fracs = 1,
			math_super_sub = 1,
			math_symbols = 1,
			sections = 0,
			styles = 1,
		}

		-- Set conceal level and tex conceal characters
		vim.opt.conceallevel = 2
		vim.g.tex_conceal = "abdmg"
	end,
}
