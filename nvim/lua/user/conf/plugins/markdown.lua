return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	build = function()
		vim.fn["mkdp#util#install"]()
	end,
	dependencies = {
		{
			"ferrine/md-img-paste.vim",
			init = function()
				vim.cmd([[
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
                ]])
			end,
		},
	},
	init = function()
		vim.g.mkdp_filetypes = { "markdown" }
		vim.cmd([[autocmd FileType markdown nmap <C-p> <Plug>MarkdownPreviewToggle]])
		vim.g.mkdp_auto_start = 0
		vim.g.mkdp_auto_close = 1
		vim.g.mkdp_refresh_slow = 0
		vim.g.mkdp_command_for_global = 0
		vim.g.mkdp_open_to_the_world = 0
		vim.g.mkdp_open_ip = ""
		vim.g.mkdp_browser = ""
		vim.g.mkdp_echo_preview_url = 0
		vim.g.mkdp_browserfunc = ""
		vim.g.mkdp_preview_options = {
			mkit = {},
			katex = {},
			uml = {},
			maid = {},
			disable_sync_scroll = 0,
			sync_scroll_type = "middle",
			hide_yaml_meta = 1,
			sequence_diagrams = {},
			flowchart_diagrams = {},
			content_editable = false,
			disable_filename = 0,
			toc = {},
		}
		vim.g.mkdp_highlight_css = ""
		vim.g.mkdp_port = ""
		vim.g.mkdp_page_title = "「${name}」"
		vim.g.mkdp_filetypes = { "markdown" }
		vim.g.mkdp_theme = "dark"
	end,
	ft = { "markdown", "md" },
}
