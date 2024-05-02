return {
	"machakann/vim-sandwich",
	config = function()
		vim.cmd([[
            " Make vim-sandwich use vim-surround keymappings
            runtime macros/sandwich/keymap/surround.vim

            " disable latex recipes because already has vimtex shutkey
            " let g:sandwich_no_tex_ftplugin = 1
        ]])
	end,
}
