return {
	require("user.conf.lsp.treesitter"),
	require("user.conf.lsp.mason"),
	require("user.conf.lsp.lspconfig"),

	-- require("user.conf.lsp.snippets"),
	require("user.conf.lsp.autocomplete").lua_config,
	require("user.conf.lsp.lint").null_ls,
	require("user.conf.lsp.formatting"),
	require("user.conf.lsp.fold"),

	require("user.conf.lsp.go"),
}
