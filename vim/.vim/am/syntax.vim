" True-color rendering for onedark (terminal must support it, e.g. iTerm2, kitty, alacritty).
if (has('termguicolors'))
  set termguicolors
endif

" onedark.vim options -- applied BEFORE :colorscheme so they take effect.
let g:onedark_terminal_italics = 1
let g:onedark_hide_endofbuffer  = 1
let g:onedark_style             = 'dark'

" Active theme: onedark. Alternatives remain installed; swap the line below.
set background=dark
try
  colorscheme onedark
catch /^Vim\%((\a\+)\)\=:E185/
  " onedark not yet installed -- fall back silently.
  colorscheme kalisi
endtry
let g:monochrome_italic_comments = 1

" Palette matching the tmux status bar (Writtic/.tmux adaptation):
"   #282c34  bg    #21252b  bg_d    #abb2bf  fg    #4b5263  muted
"   #98c379  green #61afef  blue    #e5c07b  yellow #d19a66  orange
" Keep onedark syntax colours intact; retint only a few UI surfaces so
" vim feels continuous with tmux.
augroup OneDarkUITune
  autocmd!
  autocmd ColorScheme onedark highlight Comment       cterm=italic gui=italic guifg=#5c6370
  autocmd ColorScheme onedark highlight LineNr        guifg=#4b5263 guibg=NONE
  autocmd ColorScheme onedark highlight CursorLineNr  guifg=#98c379 guibg=NONE cterm=bold gui=bold
  autocmd ColorScheme onedark highlight VertSplit     guifg=#21252b guibg=NONE
  autocmd ColorScheme onedark highlight SignColumn    guibg=NONE
  autocmd ColorScheme onedark highlight StatusLine    guifg=#abb2bf guibg=#21252b gui=NONE
  autocmd ColorScheme onedark highlight StatusLineNC  guifg=#4b5263 guibg=#21252b gui=NONE
  autocmd ColorScheme onedark highlight MatchParen    guifg=#98c379 guibg=NONE   cterm=bold gui=bold
  autocmd ColorScheme onedark highlight Search        guifg=#282c34 guibg=#e5c07b
  autocmd ColorScheme onedark highlight IncSearch     guifg=#282c34 guibg=#d19a66
augroup END
if get(g:, 'colors_name', '') ==# 'onedark'
  doautocmd OneDarkUITune ColorScheme onedark
endif

"autocmd ColorScheme * hi Comment gui=italic cterm=italic
"autocmd ColorScheme * hi LineNr guifg=#737373 ctermfg=249
"autocmd ColorScheme * hi MatchParen cterm=none ctermbg=none ctermfg=blue
"autocmd ColorScheme * hi String guifg=#2020F0 ctermfg=blue
"autocmd ColorScheme * hi Search guifg=White ctermfg=15 guibg=#2020F0 ctermbg=blue
"autocmd ColorScheme * hi Pmenu guifg=Black ctermfg=16 guibg=#2020F0 ctermbg=blue
"autocmd ColorScheme * hi PmenuSel guifg=#2020F0 ctermfg=blue guibg=Black ctermbg=16
"
" show syntax highlighting
map <M-i> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" fiddle with org mode syntax
autocmd BufEnter *.org syntax match stars /^\*\+ .*/
highlight stars ctermfg=red guifg=#ff0000 cterm=bold


"au InsertEnter * hi Normal ctermbg=230 guibg=#eeeeee
"au InsertLeave * hi Normal ctermbg=white guibg=#ffffff
"autocmd InsertEnter * highlight StatusLine guifg=white guibg=cyan ctermfg=white ctermbg=cyan
"autocmd InsertEnter * highlight LineNr guifg=white guibg=cyan ctermfg=white ctermbg=cyan
"autocmd InsertLeave * highlight StatusLine guifg=white guibg=darkblue ctermfg=white ctermbg=darkblue
"autocmd InsertLeave * highlight LineNr guifg=white guibg=darkblue ctermfg=white ctermbg=darkblue
"" Status stuff
""set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P


"set cursorline
