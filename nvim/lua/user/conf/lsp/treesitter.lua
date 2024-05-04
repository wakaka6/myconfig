return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		local status_ok, nt = pcall(require, "nvim-treesitter.configs")
		if not status_ok then
			return
		end

		nt.setup({
			ensure_installed = {
				"c",
				"cpp",
				"go",
				"python",
				"lua",
				"markdown",
			},

			autotag = {
				enable = true,
			},

			sync_install = false,

			auto_install = false,

			ignore_install = { "all" },

			highlight = {
				-- `false` will disable the whole extension
				enable = true,

				-- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
				-- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
				-- the name of the parser)
				-- list of language that will be disabled
				disable = function(lang, buf)
					local max_filesize = 100 * 1024 -- 100 KB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					if vim.api.nvim_buf_get_option(buf, "filetype") == "vim" then
						return true
					end
					if ok and stats and stats.size > max_filesize then
						return true
					end
				end,

				additional_vim_regex_highlighting = { "markdown" },
			},
		})

		-- Config curl proxy to download parsers
		-- require("nvim-treesitter.install").command_extra_args = {
		--     curl = { "--proxy", "<proxy url>" },
		-- }
	end,
}
