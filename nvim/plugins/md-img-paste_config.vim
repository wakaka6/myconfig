" there are some defaults for image directory and image name, you can change them
let g:mdip_imgdir = '.img'
" let g:mdip_imgname = 'image'

function! g:MyMarkdownPasteImage(relpath)
        execute "normal! i<div align=center> <img src=\"" . a:relpath . "\" width = 80%/> </div>\n"
        let ipos = getcurpos()
        execute "normal! a<center>" . g:mdip_tmpname[0:] . "</center>"
        call setpos('.', ipos)
        execute "normal! f>lvt<\<C-g>"
endfunction

autocmd FileType markdown let g:PasteImageFunction = 'g:MyMarkdownPasteImage'
