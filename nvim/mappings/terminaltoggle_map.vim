if g:nvim_plugins_installation_completed == 1
lua << EOF
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

local Terminal = require("toggleterm.terminal").Terminal
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

local python = Terminal:new({ cmd = "ipython", hidden = true, direction = "horizontal", })
function _PYTHON_TOGGLE()
	python:toggle()
end
EOF
endif