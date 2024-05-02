return {
    {
        'wakaka6/dracula.nvim',
        branch = 'custom',
        lazy = false,
        priority = 1100,
        config = function()
            vim.cmd('colorscheme dracula')
            -- show the '~' characters after the end of buffers
            vim.g.dracula_show_end_of_buffer = true
            -- use transparent background
            vim.g.dracula_transparent_bg = false
            -- set custom lualine background color
            -- vim.g.dracula_lualine_bg_color = "#44475a"
            -- set italic comment
            vim.g.dracula_italic_comment = true
        end
    },
    'ryanoasis/vim-devicons',
    require("user.conf.theme.lualine"),
    require("user.conf.theme.bufferline"),
    require("user.conf.theme.dashboard"),
    -- {
    --     'Bekaboo/dropbar.nvim',
    --     -- optional, but required for fuzzy finder support
    --     dependencies = {
    --         'nvim-telescope/telescope-fzf-native.nvim'
    --     },
    -- },

}
