return {
	require("user.conf.lsp.mason"),
	require("user.conf.lsp.treesitter"),
	require("user.conf.lsp.lspconfig"),

	require("user.conf.lsp.snippets"),
	require("user.conf.lsp.autocomplete").config,
	require("user.conf.lsp.lint"),
	require("user.conf.lsp.formatting"),

	require("user.conf.lsp.go"),
}
