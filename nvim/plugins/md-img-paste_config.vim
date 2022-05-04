" there are some defaults for image directory and image name, you can change them

let g:mdip_imgdir = 'img'

if &filetype == 'tex'
    let g:mdip_imgdir = 'img'
endif

if &filetype == 'markdown'
    let g:mdip_imgdir = '.img'
endif

" let g:mdip_imgname = 'image'

function! g:MyMarkdownPasteImage(relpath)
        execute "normal! i<div align=center> <img src=\"" . a:relpath . "\" width = 80%/> </div>\n"
        let ipos = getcurpos()
        execute "normal! a<center>" . g:mdip_tmpname[0:] . "</center>"
        call setpos('.', ipos)
        execute "normal! f>lvt<\<C-g>"
endfunction

function! g:MyLatexPasteImage(relpath)
    execute "normal! i\\includegraphics[width=0.8\\textwidth]{" . a:relpath . "}\n\\caption{I"
    let ipos = getcurpos()
    execute "normal! a" . "mage}"
    call setpos('.', ipos)
    execute "normal! ve\<C-g>"
endfunction

autocmd FileType markdown let g:PasteImageFunction = 'g:MyMarkdownPasteImage'
autocmd FileType tex let g:PasteImageFunction = 'g:MyLatexPasteImage'
