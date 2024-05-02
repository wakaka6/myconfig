return {
    {
        'sirver/ultisnips',
        depencency = {'honza/vim-snippets'},
        config = function()
            vim.g.UltiSnipsExpandTrigger = "<tab>"
            vim.g.UltiSnipsJumpForwardTrigger = "<c-j>"
            vim.g.UltiSnipsJumpBackwardTrigger = "<c-k>"

            vim.cmd [[
                let g:UltiSnipsSnippetDirectories=[$HOME.'/.config/nvim/mysnippets/', 'UltiSnips']
                let g:UltiSnipsEditSplit="vertical"
            ]]
        end,
    }
}
