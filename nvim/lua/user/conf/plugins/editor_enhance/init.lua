return {
	require("user.conf.plugins.editor_enhance.Comment"),
	require("user.conf.plugins.editor_enhance.copilot").avante,

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},

	-- 可以查看文件的历史修改树
	require("user.conf.plugins.editor_enhance.undo"),

	-- Eazy Motion Everywhere
	require("user.conf.plugins.editor_enhance.hop"),

	"gcmt/wildfire.vim",

	-- 更改包裹的内容
	require("user.conf.plugins.editor_enhance.vim-sandwich"),
}
