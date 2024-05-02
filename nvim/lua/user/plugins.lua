local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	require("user.conf.theme"),
	require("user.conf.plugins.fzf"),
	require("user.conf.plugins.visually_enhance"),
	require("user.conf.plugins.editor_enhance"),
	require("user.conf.plugins.debugger"),
	require("user.conf.lsp"),
	require("user.conf.plugins.telescope"),
	require("user.conf.plugins.convenient"),

	require("user.conf.plugins.markdown"),
	require("user.conf.plugins.tex"),

	require("user.conf.plugins.fun"),
	require("user.conf.plugins.which_key"),
})
