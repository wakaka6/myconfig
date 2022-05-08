" https://github.com/puremourning/vimspector#human-mode
let g:vimspector_enable_mappings = 'HUMAN'

let g:vimspector_sign_priority = {
  \    'vimspectorBP':         3,
  \    'vimspectorBPCond':     2,
  \    'vimspectorBPLog':      2,
  \    'vimspectorBPDisabled': 1,
  \    'vimspectorPC':         999,
  \ }

sign define vimspectorBP            text=\ ● texthl=WarningMsg
" sign define vimspectorBPCond        text=\ ◆ texthl=WarningMsg
" sign define vimspectorBPLog         text=\ ◆ texthl=SpellRare
sign define vimspectorBPDisabled    text=\ ● texthl=LineNr
sign define vimspectorPC            text=ﰲ texthl=MatchParen linehl=CursorLine
" sign define vimspectorPCBP          text=●▶  texthl=MatchParen linehl=CursorLine
" sign define vimspectorCurrentThread text=▶   texthl=MatchParen linehl=CursorLine
" sign define vimspectorCurrentFrame  text=▶   texthl=Special    linehl=CursorLine

nnoremenu WinBar.■\ Stop :call vimspector#Stop( { 'interactive': v:false } )<CR>
nnoremenu WinBar.▶\ Cont :call vimspector#Continue()<CR>
nnoremenu WinBar.▷\ Pause :call vimspector#Pause()<CR>
nnoremenu WinBar.↷\ Next :call vimspector#StepOver()<CR>
nnoremenu WinBar.→\ Step :call vimspector#StepInto()<CR>
nnoremenu WinBar.←\ Out :call vimspector#StepOut()<CR>
nnoremenu WinBar.⟲: :call vimspector#Restart()<CR>
nnoremenu WinBar.✕ :call vimspector#Reset( { 'interactive': v:false } )<CR>

" Set the basic sizes
let g:vimspector_sidebar_width = 43
let g:vimspector_bottombar_height = 5
let g:vimspector_code_minwidth = 85
let g:vimspector_terminal_minwidth = 75
let g:vimspector_terminal_maxwidth = 75

function! s:CustomiseUI()
  " Customise the basic UI...
  call win_gotoid( g:vimspector_session_windows.code )
  " Clear the existing WinBar created by Vimspector
  nunmenu WinBar
  " Cretae our own WinBar
  nnoremenu WinBar.Kill :call vimspector#Stop( { 'interactive': v:true } )<CR>
  nnoremenu WinBar.Continue :call vimspector#Continue()<CR>
  nnoremenu WinBar.Pause :call vimspector#Pause()<CR>
  nnoremenu WinBar.Step\ Over  :call vimspector#StepOver()<CR>
  nnoremenu WinBar.Step\ In :call vimspector#StepInto()<CR>
  nnoremenu WinBar.Step\ Out :call vimspector#StepOut()<CR>
  nnoremenu WinBar.Restart :call vimspector#Restart()<CR>
  nnoremenu WinBar.Exit :call vimspector#Reset()<CR> 

  " Close the output window expect golang
  if &filetype != 'go'
    call win_gotoid( g:vimspector_session_windows.output )
    q
  else " I don't know why golang not have temrinal window 
    call win_gotoid( g:vimspector_session_windows.output )
    set norelativenumber nonumber
    resize 10
  endif
endfunction

function s:SetUpTerminal()
  " Customise the terminal window size/position
  " For some reasons terminal buffers in Neovim have line numbers
  call win_gotoid( g:vimspector_session_windows.terminal )
  set norelativenumber nonumber
  resize 10
endfunction

augroup MyVimspectorUICustomistaion
  autocmd!
  autocmd User VimspectorUICreated call s:CustomiseUI()
  autocmd User VimspectorTerminalOpened call s:SetUpTerminal()
augroup END
