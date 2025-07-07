local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
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

-- Import snippet engine configuration
local snippet_config = require("user.conf.lsp.config")
local SNIPPET_ENGINE = snippet_config.snippet_config.SNIPPET_ENGINE

local M = {}

-- Get snippet-specific dependencies
local function get_snippet_dependencies()
	if SNIPPET_ENGINE == "luasnip" then
		return {
			"L3MON4D3/LuaSnip", -- Reference to LuaSnip plugin (configured in snippets.lua)
			"saadparwaiz1/cmp_luasnip", -- LuaSnip completion source
		}
	else
		return {
			"SirVer/ultisnips",
			{
				"quangnguyen30192/cmp-nvim-ultisnips",
				config = function()
					require("cmp_nvim_ultisnips").setup({})
				end,
			},
		}
	end
end

M.config = {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = vim.list_extend({
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
	}, get_snippet_dependencies()),
	config = function()
		local cmp = require("cmp")
		local lspkind = require("lspkind")

		-- Snippet configuration based on engine
		local snippet_setup = {}
		if SNIPPET_ENGINE == "luasnip" then
			snippet_setup = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			}
		else
			snippet_setup = {
				expand = function(args)
					vim.fn["UltiSnips#Anon"](args.body)
				end,
			}
		end

		-- Get snippet source based on engine
		local snippet_source = SNIPPET_ENGINE == "luasnip" and { name = "luasnip" } or { name = "ultisnips" }
		
		local default_cmp_sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			snippet_source,
			{ name = "buffer" },
			{ name = "path" },
			{ name = "nvim_lua" },
			{ name = "cmdline" },
			{ name = "calc" },
		})

		cmp.setup({
			snippet = snippet_setup,
			sources = default_cmp_sources,
			mapping = cmp.mapping.preset.insert({
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
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end,
				}),
				["<S-Tab>"] = cmp.mapping({
					i = function(fallback)
						if cmp.visible() then
							cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
						elseif SNIPPET_ENGINE == "luasnip" then
							local luasnip = require("luasnip")
							if luasnip.jumpable(-1) then
								luasnip.jump(-1)
							else
								fallback()
							end
						elseif vim.fn["UltiSnips#CanJumpBackwards"]() == 1 then
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
			}),
			window = {
				-- Completion window configuration
				-- Options: cmp.config.window.bordered() for borders, or custom table
				-- Border styles: "none", "single", "double", "rounded", "solid", "shadow"
				-- Example with border: cmp.config.window.bordered({ border = "rounded" })
				completion = {
					-- col_offset = 0,     -- Horizontal offset (negative = left, positive = right)
					-- side_padding = 1,   -- Padding on sides
					-- scrollbar = true,   -- Show scrollbar
					-- winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
				},
				-- Documentation window configuration  
				-- Same border options as completion window
				documentation = {
					-- border = "single",  -- Border style
					-- max_width = 80,     -- Maximum width
					-- max_height = 20,    -- Maximum height
				},
			},
			formatting = {
				format = function(entry, vim_item)
					local kind = lspkind.cmp_format({
						mode = "symbol_text",
						symbol_map = { Codeium = "", Copilot = "" },
					})(entry, vim_item)
					-- local strings = vim.split(kind.kind, "%s", { trimempty = true })
					-- kind.kind = " " .. (strings[1] or "") .. " "
					kind.menu = limitStr(entry:get_completion_item().detail or "")
					return kind
				end,
			},
		})
		
		-- If a file is too large, I don't want to add to it's cmp sources treesitter, see:
		-- https://github.com/hrsh7th/nvim-cmp/issues/1522
		vim.api.nvim_create_autocmd("BufReadPre", {
			callback = function(tt)
				local sources = vim.deepcopy(default_cmp_sources)
				if not bufIsBig(tt.buf) then
					table.insert(sources, { name = "treesitter", group_index = 2 })
				end
				cmp.setup.buffer({
					sources = sources,
				})
			end,
		})
	end,
}

return M
