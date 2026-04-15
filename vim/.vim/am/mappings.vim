
" Leader
let mapleader=";"
let maplocalleader=","

" shortcut plugin needs to be included for some reason. Weird!
source ~/.vim/plugged/vim-shortcut/plugin/shortcut.vim

if exists('g:loaded_shortcut')
  Shortcut show shortcut menu and run chosen shortcut noremap <silent> <Leader><Leader> :Shortcuts<Return>
"  Shortcut fallback to shortcut menu on partial entry noremap <silent> <Leader> :Shortcuts<Return>
"  Shortcut fallback to shortcut menu on partial entry noremap <silent> <LocalLeader> :Shortcuts<Return>
endif

" fzf.vim (replaces ctrlp / CtrlSpace)
Shortcut Files          nnoremap <silent> <C-p> :Files<CR>
Shortcut Files (Leader) nnoremap <silent> <Leader>p :Files<CR>
Shortcut Buffers        nnoremap <silent> <Leader>ob :Buffers<CR>
Shortcut History        nnoremap <silent> <Leader>oh :History<CR>
Shortcut Ripgrep        nnoremap <silent> <Leader>e :Rg <c-r><c-w><CR>
Shortcut Ripgrep prompt nnoremap <silent> <Leader>E :Rg<CR>

Shortcut TagbarToggle nnoremap <Leader>. :TagbarToggle<CR>
nnoremap <Leader>d "_d
Shortcut NERDTreeToggle nnoremap <Leader>T :NERDTreeToggle<CR>
Shortcut NERDTreeFind nnoremap <Leader>t :NERDTreeFind<CR>

func IsNERDTreeOpen()
    return exists('t:NERDTreeBufName') && bufwinnr(t:NERDTreeBufName) != -1
endfunc

func NERDToggleOrFind()
	if IsNERDTreeOpen()
		:NERDTreeToggle<CR>
	else 
		:NERDTreeFind<CR>
	endif
endfunc

Shortcut Filename inoremap <Leader>fn <c-r>=expand("%:t")<cr>

Shortcut swoop 
 \ nmap <Leader>l :call Swoop()<CR>
Shortcut swoop selection 
 \ vmap <Leader>l :call SwoopSelection()<CR>
Shortcut swoop multi
 \ nmap <Leader>ml :call SwoopMulti()<CR>
Shortcut swoop multi selection 
 \ vmap <Leader>ml :call SwoopMultiSelection()<CR>


imap jk <Esc>
imap kj <Esc>

"sudo write current buffer:
command Sw w !sudo tee % > /dev/null

nmap ga <Plug>(place-insert)


" expert mode
"noremap <Up> <nop>
"noremap <Down> <nop>
"noremap <Left> <nop>
"noremap <Right> <nop>

" jump to next/prev vim-go error:
" nnoremap <C-j> :cn<CR>
" nnoremap <C-k> :cp<CR>

"au FileType dotoo inoremap <CR> <CR><C-R>=expand("%:t:r")
" au FileType dotoo nnoremap t ji<CR>*
" au FileType dotoo iabbrev ** • 
"
au FileType dotoo Shortcut new headline nnoremap <LocalLeader>b i*<Space>

nmap <CR> o<Esc>

au FileType rust nnoremap <LocalLeader>rf :%!rustfmt<CR>
au FileType rust nnoremap <LocalLeader>rr :CargoRun<CR>
