
" let g:indent_blankline_enabled = v:false
let g:indent_blankline_char_list = ['│', '|', '¦', '┆']
lua << EOF
vim.g.indent_blankline_filetype_exclude = { 
    'lsp', 
    'packer', 
    'vim-plug', 
    'checkhealth', 
    'text' , 
    'dashboard', 
    'coc-explorer',
    'man',
    'help',
}

vim.g.indent_blankline_buftype_exclude = {
    'terminal', 
    'nofile', 
    'quickfix', 
    'prompt',
}

vim.g.indent_blankline_bufname_exclude = { '_.*', 'NERD_tree.*'}

vim.opt.list = true
-- vim.opt.listchars:append "eol:↴"
-- vim.opt.listchars:append "space:⋅"

require("indent_blankline").setup {
    -- space_char_blankline = " ",
    show_end_of_line = true,
    show_current_context = true,
    show_current_context_start = true,
}
EOF
