function _G.set_terminal_keymaps()
    local opts = {noremap = true}
    -- vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', '<C-q>', [[<C-\><C-n>]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', '<C-w>', [[<C-\><C-n><C-W><C-W>]], opts)
    -- vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
    -- vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
    -- vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
    -- vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

return {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
        local status_ok, toggleterm = pcall(require, "toggleterm")
        if not status_ok then
            return
        end

        toggleterm.setup({
            size = function(term)
                if term.direction == "horizontal" then
                    return 10
                elseif term.direction == "vertical" then
                    return vim.o.columns * 0.4
                else
                    return 20
                end
            end,
            open_mapping = [[<c-\>]],
            hide_numbers = true,
            shade_filetypes = {},
            shade_terminals = true,
            shading_factor = 2,
            start_in_insert = true,
            insert_mappings = true, -- whether or not the open mapping applies in insert mode
            persist_size = true,
            direction = "float", --  'vertical' | 'horizontal' | 'tab' | 'float'
            close_on_exit = true,
            shell = vim.o.shell,
            float_opts = {
                border = "curved", -- 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
                winblend = 0,
                highlights = {
                    border = "Normal",
                    background = "Normal",
                },
            },
        })

        local Terminal = require("toggleterm.terminal").Terminal

        -- lazygit toggle with "tg"
        local lazygit = Terminal:new({ 
            cmd = "lazygit", 
            hidden = true,
            on_open = function(term)
                vim.api.nvim_buf_del_keymap(term.bufnr, "t", "<C-w>")
                vim.api.nvim_buf_del_keymap(term.bufnr, "t", "<C-q>")
            end,
        })
        function _LAZYGIT_TOGGLE()
            lazygit:toggle()
        end
        vim.api.nvim_set_keymap("n", "tg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", {noremap = true, silent = true})

        -- python toggle with "tp"
        local python = Terminal:new({ cmd = "ipython", hidden = true, direction = "horizontal", })
        function _PYTHON_TOGGLE()
            python:toggle()
        end
        vim.api.nvim_set_keymap("n", "tp", "<cmd>lua _PYTHON_TOGGLE()<CR>", {noremap = true, silent = true})

        -- Translate English to Chinese with "te" to toggle
        local transEN = Terminal:new({ cmd = "trans -t zh -shell", hidden = true, direction = "horizontal" })
        function _TRANSLATE_EN_TOGGLE()
            transEN:toggle()
        end
        vim.api.nvim_set_keymap("n", "te", "<cmd>lua _TRANSLATE_EN_TOGGLE()<CR>", {noremap = true, silent = true})

        -- Translate Chinese to English with "tc" to toggle
        local transZH = Terminal:new({ cmd = "trans -t en -shell", hidden = true, direction = "horizontal" })
        function _TRANSLATE_ZH_TOGGLE()
            transZH:toggle()
        end
        vim.api.nvim_set_keymap("n", "tc", "<cmd>lua _TRANSLATE_ZH_TOGGLE()<CR>", {noremap = true, silent = true})
    end
}
