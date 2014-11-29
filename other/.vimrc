set nocompatible              " Be iMproved, required
syntax on
filetype off                  " required

" Set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
" Color schemes
Plugin 'nanotech/jellybeans.vim'
Plugin 'chriskempson/vim-tomorrow-theme'
Plugin 'morhetz/gruvbox'
Plugin 'Valloric/vim-operator-highlight'
" Working with Git inside Vim
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
" File tree
Plugin 'scrooloose/nerdtree'
" Fuzzy file, buffer, etc search
Plugin 'kien/ctrlp.vim'
" Change/add/remove surrounding (, {, [, quotes and tags
Plugin 'tpope/vim-surround'
" Syntax checking
Plugin 'scrooloose/syntastic'
" Code comments
Plugin 'tpope/vim-commentary'
" Cool status line
Plugin 'bling/vim-airline'
" Tab FTW!
Plugin 'ervandew/supertab'
" Handy brackets mappings
Plugin 'tpope/vim-unimpaired'
" Code alignment
Plugin 'godlygeek/tabular'
" User defined text objects (needed for Ruby block matching)
Plugin 'kana/vim-textobj-user'
Plugin 'matchit.zip'
Plugin 'nelstrom/vim-textobj-rubyblock'
" Abbreviation, renaming and coercion (see docs)
Plugin 'tpope/vim-abolish'
" Repeat maps
Plugin 'tpope/vim-repeat'
" Wise endings
Plugin 'tpope/vim-endwise'
" Ruby support
Plugin 'vim-ruby/vim-ruby'
" Rake support
Plugin 'tpope/vim-rake'
" Bundler support
Plugin 'tpope/vim-bundler'
" Rails support
Plugin 'tpope/vim-rails'
" RSpec support
Plugin 'thoughtbot/vim-rspec'
" Slim templates support
Plugin 'slim-template/vim-slim'
" Javascript support
Plugin 'pangloss/vim-javascript'
" CoffeeScript support
Plugin 'kchmck/vim-coffee-script'
" Markdown support
Plugin 'tpope/vim-markdown'
" Jade templates support
Plugin 'digitaltoad/vim-jade'
" JSON support
Plugin 'elzr/vim-json'
" SCSS support
Plugin 'cakebaker/scss-syntax.vim'
" Nginx configs support
Plugin 'nginx.vim'
" Tmux config support
Plugin 'tsaleh/vim-tmux'
" Tmux navigation support
Plugin 'christoomey/vim-tmux-navigator'
" Send commands to tmux
Plugin 'jgdavey/tslime.vim'
" Time tracking service
Plugin 'wakatime/vim-wakatime'

" All of your Plugins must be added before the following line
call vundle#end()             " required
filetype plugin indent on     " required
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" Gruvbox scheme
if !has("gui_running")
  let g:gruvbox_italic=0
endif
nnoremap <silent> [oh :call gruvbox#hls_show()<CR>
nnoremap <silent> ]oh :call gruvbox#hls_hide()<CR>
nnoremap <silent> coh :call gruvbox#hls_toggle()<CR>
nnoremap * :let @/ = ""<CR>:call gruvbox#hls_show()<CR>*
nnoremap / :let @/ = ""<CR>:call gruvbox#hls_show()<CR>/
nnoremap ? :let @/ = ""<CR>:call gruvbox#hls_show()<CR>?
nnoremap <silent><C-l> :let @/ = ""<CR>:call gruvbox#hls_hide()<CR><C-l>
colorscheme gruvbox
" Vim operator highlight
let g:ophigh_color = 67
set background=dark
set t_ut=                     " Disable Background Color Erase for normal background under Tmux
set shell=bash                " This makes RVM to work (no idea why)

" Leader key
let mapleader=","

" Remapings
nnoremap <silent><leader>f <C-]>
" Use ,F to jump to tag in a vertical split
nnoremap <silent><leader>F :let word=expand("<cword>")<CR>:vsp<CR>:wincmd w<cr>:exec("tag ". word)<CR>
" Paste from system clipboard on the next line
nmap <leader>p :pu +<CR>
" Paste from system clipboard on the previous line
nmap <leader>P :pu! +<CR>
" Copy selection to the system clipboard
vmap <leader>c "+y
" Close buffer
nmap <leader>q :bd<CR>
" Emacs-like beginning and end of line
imap <C-e> <C-o>$
imap <C-a> <C-o>^
" Bind K to grep word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>
" Ctrl-C the same as ESC in insert mode
imap <C-c> <esc>
" w!! to write a file as sudo
cmap w!! w !sudo tee % >/dev/null
" Fast vimrc editing and sourcing
nmap <leader>sv :so $MYVIMRC<CR>
nmap <leader>ev :e $MYVIMRC<CR>

" Plugins mappings and settings
" NERDTree
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let g:NERDTreeWinSize = 30
nmap <silent><F3> :NERDTreeToggle<CR>
imap <silent><F3> <ESC>:NERDTreeToggle<CR>
" CtrlP
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor
  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s --files-with-matches --hidden -g ""'
  let g:ctrlp_use_caching = 0
endif
let g:ctrlp_by_filename = 1
nmap <silent><leader>b :CtrlPBuffer<CR>
nmap <silent><leader>. :CtrlPTag<CR>
" Surround
nmap <silent><leader>ds cs"'
nmap <silent><leader>sd cs'"
" Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9
" Tabularize
map <silent><leader>a= :Tabularize /=<CR>
map <silent><leader>a: :Tabularize /:\zs<CR>
" RSpec mappings
let g:rspec_command = 'call Send_to_Tmux("bundle exec rspec --no-profile {spec}\n")'
map <leader>t :call RunCurrentSpecFile()<CR>
map <leader>s :call RunNearestSpec()<CR>
map <leader>l :call RunLastSpec()<CR>
map <leader>a :call RunAllSpecs()<CR>
" Rails
map <leader>r :R<CR>

" Line numbers
set number
autocmd InsertEnter * silent! :set norelativenumber
autocmd InsertLeave,BufNewFile,VimEnter * silent! :set relativenumber

" Fix commands misspelled
command! Q q
command! W w
command! Wq wq

" Encodings and file format
scriptencoding utf-8
set encoding=utf-8
set termencoding=utf8
set fileencodings=utf8,cp1251
set ffs=unix,mac,dos
set fileformat=unix

" Presentation
set numberwidth=3       " number of culumns for line numbers
set textwidth=0         " Do not wrap words (insert)
set nowrap              " Do not wrap words (view)
set showcmd             " Show (partial) command in status line.
set showmatch           " Show matching brackets.
set ruler               " line and column number of the cursor position
set wildmenu            " enhanced command completion
set visualbell          " use visual bell instead of beeping
set laststatus=2        " always show the status line
set showtabline=2       " always show the tabs line

" Special chars
set nolist
set listchars=tab:▸\ ,eol:¬,trail:·,extends:»,precedes:«

" Behavior
" Ignore these files when completing names and in explorer
set wildignore+=.svn,CVS,.git,.hg,*.o,*.a,*.class,*.mo,*.la,*.so,*.obj,*.swp,*.jpg,*.png,*.xpm,*.gif,vendor/**,coverage/**,tmp/**,rdoc/**
set autowriteall        " Automatically save before commands like :next and :make
set hidden              " enable multiple modified buffers
set history=1000
set autoread            " automatically read file that has been changed on disk and doesn't have changes in vim
set backspace=indent,eol,start
set completeopt=menuone,preview
set modelines=5         " number of lines to check for vim: directives at the start/end of file
set autoindent          " automatically indent new line
set ts=4                " number of spaces in a tab
set sw=4                " number of spaces for indent
set et                  " expand tabs into spaces
set nobackup            " do not write backup files
set noswapfile          " do not write .swp files
set splitbelow          " split window below
set noequalalways       " don't change windows sizes when open/close windows
set timeoutlen=1200     " A little bit more time for macros
set ttimeoutlen=50      " Make Esc work faster
set tags=./tags;/

" Normally, Vim messes with iskeyword when you open a shell file. This can
" leak out, polluting other file types even after a 'set ft=' change. This
" variable prevents the iskeyword change so it can't hurt anyone.
let g:sh_noisk=1

" Scroll paddings
set scrolloff=5
set sidescrolloff=10
set sidescroll=1

" Search settings
set incsearch           " Incremental search
set hlsearch            " Highlight search match
set ignorecase          " Do case insensitive matching
set smartcase           " do not ignore if search pattern has CAPS

autocmd BufEnter .server_aliases,.server_admin_aliases let b:is_bash=1
autocmd BufEnter .server_aliases,.server_admin_aliases setlocal ft=sh

" Format XML files
autocmd FileType xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null

" Tabs and spaces corrections for different file types
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2

" Jump to last cursor position unless it's invalid or in an event handler
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

" Remove trailing whitespaces on save
autocmd FileType php,rb,js,coffee,scss,css,j2,ini,vim autocmd BufWritePre <buffer> :%s/\s\+$//e

" Generate tags on save
autocmd BufWritePost *.rb,*.js,*.html,*.haml,*.css,*.sass,*.coffee silent! !ctags -R 2> /dev/null &
