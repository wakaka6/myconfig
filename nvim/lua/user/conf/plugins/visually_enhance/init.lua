return {
    -- awesome ui improve the default vim.ui
    { "stevearc/dressing.nvim", event = "VeryLazy", },  

	-- Highlight the symbol and its references when holding the cursor.
    require("user.conf.plugins.visually_enhance.vim-illuminate"),

    -- show color #ffffff
    require("user.conf.plugins.visually_enhance.nvim-colorizer"),

    require("user.conf.plugins.visually_enhance.nvim-scrollbar"),
    require("user.conf.plugins.visually_enhance.nvim-hlslens"),
    { "lukas-reineke/virt-column.nvim", opts = {} },

    require("user.conf.plugins.visually_enhance.wilder"),

    require("user.conf.plugins.visually_enhance.indent_blankline"),

}
