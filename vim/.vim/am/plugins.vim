call plug#begin('~/.vim/plugged')

" Git support
Plug 'tpope/vim-fugitive'          " :Git*
Plug 'tpope/vim-rhubarb'           " :GBrowse, hub
Plug 'jreybert/vimagit'            " Magit in vim
Plug 'idanarye/vim-merginal'       " view/switch branches
Plug 'will133/vim-dirdiff'

Plug 'junegunn/vim-peekaboo'       " show registers/buffers
Plug 'gioele/vim-autoswap'         " deal with swap files
Plug 'joereynolds/place.vim'       " insertions with ga (non-cursor)

""" Go
Plug 'fatih/vim-go', { 'tag': '*', 'do': ':GoUpdateBinaries' }
Plug 'buoto/gotests-vim'

""" Editing utilities
Plug 'FooSoft/vim-argwrap'         " Wrap a parameter list across lines
Plug 'majutsushi/tagbar'           " 'Outline' of current file

""" Other languages
Plug 'rust-lang/rust.vim'
Plug 'gabrielelana/vim-markdown'
Plug 'mzlogin/vim-markdown-toc'

""" Graphviz
Plug 'wannesm/wmgraphviz.vim'

Plug 'christianrondeau/vim-base64'

""" org-mode-ish
Plug 'dhruvasagar/vim-dotoo'

""" tmux
Plug 'christoomey/vim-tmux-navigator'
Plug 'benmills/vimux'
Plug 'benmills/vimux-golang'

""" tpope
Plug 'tpope/vim-surround'          " Operate on surrounding
Plug 'tpope/vim-speeddating'       " Increment dates
Plug 'tpope/vim-repeat'            " Repeat plugins
Plug 'tpope/vim-commentary'        " Comment out blocks
Plug 'tpope/vim-abolish'           " Flexible search
Plug 'tpope/vim-jdaddy'            " JSON text object
Plug 'tpope/vim-obsession'         " Continuously save buffer state
Plug 'tpope/vim-tbone'

""" Fuzzy / navigation
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'ryanoasis/vim-devicons'      " icons for NERDTree
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'pelodelfuego/vim-swoop'      " replace across files
Plug 'sunaku/vim-shortcut'         " searchable key mappings

""" text objects and editing
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-entire'
Plug 'vim-scripts/argtextobj.vim'
Plug 'michaeljsmith/vim-indent-object'
Plug 'bkad/CamelCaseMotion'
Plug 'glts/vim-textobj-comment'
Plug 'jeetsukumaran/vim-indentwise'

""" Appearance and layout
Plug 'ap/vim-buftabline'           " tabs across top
Plug 'joshdick/onedark.vim'        " theme (active)
Plug 'itchyny/vim-cursorword'      " underline word under cursor

" Rest console
Plug 'diepm/vim-rest-console'

" calendar
Plug 'itchyny/calendar.vim'

""" snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

call plug#end()

" Start NERDTree when no files specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd VimEnter * wincmd w
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" UltiSnips
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<C-tab>"
let g:UltiSnipsEditSplit="vertical"

let g:argwrap_tail_comma = 1
