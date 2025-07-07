-- Snippet engine configuration
local snippet_config = require("user.conf.lsp.config")
local SNIPPET_ENGINE = snippet_config.snippet_config.SNIPPET_ENGINE

local M = {}

-- UltiSnips configuration
M.ultisnips = {
	"SirVer/ultisnips",
	dependencies = { "honza/vim-snippets" },
	config = function()
		vim.g.UltiSnipsSnippetDirectories = { "~/.config/nvim/mysnippets", "UltiSnips" }
		vim.g.UltiSnipsEditSplit = "vertical"
	end,
}

-- LuaSnip configuration (main plugin definition with full setup)
M.luasnip = {
	"L3MON4D3/LuaSnip",
	version = "v2.*",
	build = "make install_jsregexp",
	dependencies = {
		"rafamadriz/friendly-snippets", -- useful snippets
	},
	config = function()
		local ls = require("luasnip")
		
		-- LuaSnip configuration
		ls.config.set_config({
			history = true,
			updateevents = "TextChanged,TextChangedI",
			enable_autosnippets = true,
			ext_opts = {
				[require("luasnip.util.types").choiceNode] = {
					active = {
						virt_text = { { "●", "Orange" } }
					}
				}
			}
		})
		
		-- Load snippets from various sources
		require("luasnip.loaders.from_vscode").lazy_load() -- friendly-snippets
		require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/luasnippets"}) -- custom snippets
		
		-- Key mappings for snippet navigation (UltiSnips compatible)
		vim.keymap.set({"i", "s"}, "<C-j>", function()
			if ls.expand_or_jumpable() then
				ls.expand_or_jump()
			end
		end, {silent = true})

		vim.keymap.set({"i", "s"}, "<C-k>", function()
			if ls.jumpable(-1) then
				ls.jump(-1)
			end
		end, {silent = true})

		vim.keymap.set("i", "<C-l>", function()
			if ls.choice_active() then
				ls.change_choice(1)
			end
		end)

		-- Reload snippets (useful for development)
		vim.keymap.set("n", "<leader><leader>s", function()
			require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/luasnippets"})
			print("LuaSnip snippets reloaded!")
		end, { desc = "Reload LuaSnip snippets" })
	end,
}

-- Return the selected snippet engine
if SNIPPET_ENGINE == "luasnip" then
	return { M.luasnip }
else
	return { M.ultisnips }
end
