
" viewer method:
let g:vimtex_view_method = 'zathura'

" Or with a generic interface:
let g:vimtex_view_general_viewer = 'okular'
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
let g:vimtex_compiler_method = 'latexmk'

let g:vimtex_compiler_latexmk = {
            \ 'build_dir' : 'vimtex_tmp',
            \ 'callback' : 1,
            \ 'continuous' : 1,
            \ 'executable' : 'latexmk',
            \ 'hooks' : [],
            \ 'options' : [
                \   '-verbose',
                \   '-file-line-error',
                \   '-synctex=1',
                \   '-interaction=nonstopmode',
                \ ],
                \}



" ===
" === enable/disable function
" ===

" Don't open QuickFix for warning messages if no errors are present
let g:vimtex_quickfix_open_on_warning = 0

" turn off VimTeX indentation
" let g:vimtex_indent_enabled   = 0 

" disable insert mode mappings (e.g. if you use UltiSnips)
let g:vimtex_imaps_enabled = 0      

" turn off completion
let g:vimtex_complete_enabled = 0  

" syntax conceal
let g:vimtex_syntax_enabled   = 1      
let g:vimtex_syntax_conceal = {
            \ 'accents': 1,
            \ 'cites': 1,
            \ 'fancy': 1,
            \ 'greek': 1,
            \ 'math_bounds': 1,
            \ 'math_delimiters': 1,
            \ 'math_fracs': 1,
            \ 'math_super_sub': 1,
            \ 'math_symbols': 1,
            \ 'sections': 0,
            \ 'styles': 1,
            \}
set conceallevel=2
let g:tex_conceal='abdmg'

