set hidden " so you can switch buffers without saving
if isdirectory('/dev/shm')
	set directory=/dev/shm " in-memory swap files (more risky but nothing sticks around)
endif

" nvim python3 provider (UltiSnips + helpers). Convention:
"   python3 -m venv ~/.local/share/nvim/venv
"   ~/.local/share/nvim/venv/bin/pip install pynvim
" Falls back silently if the venv is not provisioned on this machine.
if has('nvim')
	let s:nvim_py = expand('~/.local/share/nvim/venv/bin/python3')
	if filereadable(s:nvim_py)
		let g:python3_host_prog = s:nvim_py
	endif
endif

filetype plugin indent on    " required
set t_Co=256 " Ignored by nvim

" set list " show whitespace chars
" set listchars is useful in combination with :set list (showing whitespace chars)
set listchars=eol:↲,tab:»\ ,trail:~,space:·
set showbreak=↪
" hi NonText ctermfg=16 guifg=#4a4a59
" hi SpecialKey ctermfg=16 guifg=#4a4a59

set whichwrap+=<,>,h,l,[,] " right-arrow goes to next line
set autochdir " change dir to current file's dir
set autowrite " useful for :bufdo
set laststatus=2 " Always display the statusline in all windows
set showtabline=2 " Always display the tabline, even if there is only one tab

set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
set encoding=utf-8

syntax on

set wildmenu                       
set wildmode=list:longest,full 

set mouse=a
set mousemodel=extend

if exists('g:gui_oni')
    filetype off                  " required
    set noswapfile
endif

if exists('g:gui_oni')
"   set smartcase
"   set noshowmode
"   set noruler
"    set laststatus=0
"    set noshowcmd
endif

if !has('nvim')
	set term=xterm-256color
endif

" Completion: nvim-cmp handles it (see lua-lsp.vim); keep completeopt sane.
set completeopt=menu,menuone,noselect
autocmd CompleteDone * silent! pclose!

if has('nvim')
	autocmd BufEnter * if &buftype == "terminal" | startinsert | endif
	tnoremap <Esc> <C-\><C-n>
	command Tsplit split term://$SHELL
	command Tvsplit vsplit term://$SHELL
	command Ttabedit tabedit term://$SHELL
	"let $NVIM_TUI_ENABLE_TRUE_COLOR=1
	"let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
	"let &t_AB="\e[48;5;%dm"
	"let &t_AF="\e[38;5;%dm""	
	" This is for vim-tmux-navigator in OSX
	nnoremap <silent> <BS> :TmuxNavigateLeft<cr>
endif

set termencoding=utf-8
"set guifont=Source\ Code\ Pro\ ExtraLight:h18
"set guifont=Ubuntu\ Mono\ derivative\ Powerline:h18
set guifont=GoMono\ Nerd\ Font\ Book:h18
"set completeopt-=preview



set number
set hlsearch
set incsearch
"set gdefault " treat :s// as :s//g (and vice versa)
"set smartcase " treat all-lower as case-insensitive while searching
set title

"set clipboard^=unnamed
set clipboard+=unnamedplus

" Put plugins and dictionaries in this dir (also on Windows)
let vimDir = '$HOME/.vim'
let &runtimepath.=','.vimDir

" Keep undo history across sessions by storing it in a file
if has('persistent_undo')
	let myUndoDir = expand(vimDir . '/undodir')
	" Create dirs
	call system('mkdir -p ' . myUndoDir)
	let &undodir = myUndoDir
	set undofile
endif

set backspace=indent,eol,start

" restore cursor _except_ for commit messages
autocmd BufReadPost * if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif 

let g:place_single_character_mode = 0
let g:calendar_google_calendar = 1
let g:calendar_google_task = 1

" Lightline fallback for stock vim (nvim uses lualine, see lua-setup.vim).
if !has('nvim')
  let g:lightline = {
        \ 'colorscheme': 'onedark',
        \ 'separator': { 'left': '', 'right': '' },
        \ 'subseparator': { 'left': '', 'right': '' }
        \ }
endif

" ^set autowrite

let g:WMGraphviz_output = "svg"
let g:WMGraphviz_viewer = "google-chrome"
