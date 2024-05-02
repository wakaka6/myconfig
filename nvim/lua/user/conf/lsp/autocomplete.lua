local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	print(line, col)
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local limitStr = function(str)
	if #str > 25 then
		str = string.sub(str, 1, 22) .. "..."
	end
	return str
end

local bufIsBig = function(bufnr)
	local max_filesize = 100 * 1024 -- 100 KB
	local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
	if ok and stats and stats.size > max_filesize then
		return true
	else
		return false
	end
end

local t = function(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local M = {}
M.config = {
	"hrsh7th/nvim-cmp",
	after = {
		"SirVer/ultisnips",
	},
	dependencies = {
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-nvim-lua",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/cmp-calc",
		-- "andersevenrud/cmp-tmux",
		{
			"onsails/lspkind.nvim", -- vscode like icons
			lazy = false,
			config = function()
				require("lspkind").init()
			end,
		},
		{
			"quangnguyen30192/cmp-nvim-ultisnips",
			config = function()
				-- optional call to setup (see customization section)
				require("cmp_nvim_ultisnips").setup({})
			end,
		},
		-- "L3MON4D3/LuaSnip",
	},
	config = function()
		local cmp = require("cmp")
		local lspkind = require("lspkind")
		cmp.setup({
			snippet = {
				expand = function(args)
					vim.fn["UltiSnips#Anon"](args.body)
				end,
			},
			mapping = {
				["<C-t>"] = cmp.mapping({
					i = function(fallback)
						if cmp.visible() then
							cmp.abort()
						else
							cmp.complete()
						end
					end,
				}),
				["<Tab>"] = cmp.mapping({
					i = function(fallback)
						if cmp.visible() then
							cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
						elseif vim.fn["UltiSnips#CanJumpForwards"]() == 1 then
							vim.api.nvim_feedkeys(t("<Plug>(ultisnips_jump_forward)"), "m", true)
						elseif not has_words_before() then
							fallback()
						else
							fallback()
						end
					end,
					s = function(fallback)
						if vim.fn["UltiSnips#CanJumpForwards"]() == 1 then
							vim.api.nvim_feedkeys(t("<Plug>(ultisnips_jump_forward)"), "m", true)
						else
							fallback()
						end
					end,
				}),
				["<S-Tab>"] = cmp.mapping({
					i = function(fallback)
						if cmp.visible() then
							cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
						elseif vim.fn["UltiSnips#CanJumpBackwards"]() == 1 then
							return vim.api.nvim_feedkeys(t("<Plug>(ultisnips_jump_backward)"), "m", true)
						else
							fallback()
						end
					end,
					s = function(fallback)
						if vim.fn["UltiSnips#CanJumpBackwards"]() == 1 then
							return vim.api.nvim_feedkeys(t("<Plug>(ultisnips_jump_backward)"), "m", true)
						else
							fallback()
						end
					end,
				}),
				["<CR>"] = cmp.mapping({
					i = function(fallback)
						if cmp.visible() and cmp.get_active_entry() then
							cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
						else
							fallback()
						end
					end,
				}),
				["<Down>"] = cmp.mapping(
					cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
					{ "i" }
				),
				["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), { "i" }),

				["<C-d>"] = cmp.mapping.scroll_docs(-4),
				["<C-e>"] = cmp.mapping.scroll_docs(4),

				["<C-n>"] = cmp.mapping({
					i = function(fallback)
						if cmp.visible() then
							cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
						else
							fallback()
						end
					end,
				}),
				["<C-p>"] = cmp.mapping({
					i = function(fallback)
						if cmp.visible() then
							cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
						else
							fallback()
						end
					end,
				}),
			},
			window = {
				completion = {
					-- winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
					col_offset = -3,
					side_padding = 0,
				},
				documentation = cmp.config.window.bordered(),
			},
			formatting = {
				format = function(entry, vim_item)
					local kind = lspkind.cmp_format({
						mode = "symbol_text",
						symbol_map = { Codeium = "" },
					})(entry, vim_item)
					-- local strings = vim.split(kind.kind, "%s", { trimempty = true })
					-- kind.kind = " " .. (strings[1] or "") .. " "
					kind.menu = limitStr(entry:get_completion_item().detail or "")
					return kind
				end,
			},
		})
		-- Use buffer source for `/`.
		cmp.setup.cmdline("/", {
			completion = { autocomplete = false },
			sources = {
				-- { name = 'buffer' }
				{ name = "buffer", opts = { keyword_pattern = [=[[^[:blank:]].*]=] } },
			},
		})

		-- Use cmdline & path source for ':'.
		cmp.setup.cmdline(":", {
			completion = { autocomplete = false },
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline" },
			}),
		})
		local default_cmp_sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "ultisnips" },
			{ name = "buffer" },
			{ name = "path" },
			{ name = "nvim_lua" },
			{ name = "cmdline" },
			{ name = "calc" },
		})
		-- If a file is too large, I don't want to add to it's cmp sources treesitter, see:
		-- https://github.com/hrsh7th/nvim-cmp/issues/1522
		vim.api.nvim_create_autocmd("BufReadPre", {
			callback = function(tt)
				local sources = default_cmp_sources
				if not bufIsBig(tt.buf) then
					sources[#sources + 1] = { name = "treesitter", group_index = 2 }
				end
				cmp.setup.buffer({
					sources = sources,
				})
			end,
		})
	end,
}

return M
