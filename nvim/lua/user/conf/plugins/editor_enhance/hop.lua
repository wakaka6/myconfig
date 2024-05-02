return {
    'phaazon/hop.nvim',
    branch = 'v2',
    config = function()
        require('hop').setup {
            case_insensitive = false,
            multi_windows = true,
        }
    end,
}
