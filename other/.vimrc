set nocompatible              " Be iMproved, required
set background=dark
set t_ut=                     " Disable Background Color Erase for normal background under Tmux
" set shell=bash              " This makes RVM to work (no idea why) OR move /etc/zshenv to /etc/zshrc instead!
syntax on
filetype off                  " required

" Set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
" Color schemes
Plugin 'morhetz/gruvbox'
" Working with Git inside Vim
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
" File tree
Plugin 'scrooloose/nerdtree'
" Fuzzy file, buffer, etc search
Plugin 'kien/ctrlp.vim'
" Autotaging with ctags
Plugin 'craigemery/vim-autotag'
" Change/add/remove surrounding (, {, [, quotes and tags
Plugin 'tpope/vim-surround'
" Syntax checking
Plugin 'scrooloose/syntastic'
" Code comments
Plugin 'tpope/vim-commentary'
" Cool status line
Plugin 'bling/vim-airline'
" Tab FTW!
Plugin 'Valloric/YouCompleteMe'
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
" File syncing
" Plugin 'eshion/vim-sync'

" All of your Plugins must be added before the following line
call vundle#end()             " required
filetype plugin indent on     " required

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
let g:gruvbox_bold=0
colorscheme gruvbox
nnoremap * :let @/ = ""<CR>:call gruvbox#hls_show()<CR>*
nnoremap / :let @/ = ""<CR>:call gruvbox#hls_show()<CR>/
nnoremap ? :let @/ = ""<CR>:call gruvbox#hls_show()<CR>?

" Abbreviations
iabbrev ls@ leonid@svyatov.ru

" Leader key
let mapleader=","
let localleader="\\"

" Remapings
" Fast vimrc editing and sourcing
nnoremap <leader>ve :e $MYVIMRC<CR>
nnoremap <leader>vs :so $MYVIMRC<CR>
" Fast jump to tag
nnoremap <leader>f <C-]>
" Use ,F to jump to tag in a vertical split
nnoremap <leader>F :let word=expand("<cword>")<CR>:vsp<CR>:wincmd w<CR>:exec("tag ". word)<CR>
" Paste from system clipboard on the next line
nnoremap <leader>p :pu +<CR>
" Paste from system clipboard on the previous line
nnoremap <leader>P :pu! +<CR>
" Copy selection to the system clipboard
vnoremap <leader>y "+y
" Close buffer
noremap <leader>q :bd<CR>
" Emacs-like beginning and end of line
inoremap <C-e> <End>
inoremap <C-a> <Home>
" Ctrl-C the same as ESC in insert mode
inoremap <C-c> <Esc>
" w!! to write a file as sudo
cnoremap w!! w !sudo tee % >/dev/null
inoremap <C-w> <Esc>:w<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader><Space> i<Space><Esc>
" Index ctags from any project, including those outside Rails
noremap <leader>ct :!ctags -R --exclude=.git --exclude=logs --exclude=doc .<CR>
" Space to toggle folds.
nnoremap <Space> za
vnoremap <Space> za
" 'Refocus' folds
nnoremap ,z zMzvzz
" Make zO recursively open whatever top level fold we're in, no matter where the cursor happens to be.
nnoremap zO zCzO
" Front and center
" Use :sus for the rare times I want to actually background Vim.
nnoremap <C-z> zvzz
vnoremap <C-z> <Esc>zv`<ztgv
" Select entire buffer
nnoremap vaa ggvGg_
nnoremap Vaa ggVG
" Keep the cursor in place while joining lines
nnoremap J mzJ`z
" Split line (sister to [J]oin lines)
" The normal use of S is covered by cc, so don't worry about shadowing it.
nnoremap S i<CR><Esc>^mwgk:silent! s/\v +$//<CR>:noh<CR>`w
" Marks and Quotes
noremap ' `
noremap ` <C-^>
" Select (charwise) the contents of the current line, excluding indentation.
nnoremap vv ^vg_
" Toggle [i]nvisible characters
nnoremap <leader>i :set list!<CR>
" Clear highlights
noremap <silent> <leader>h :let @/ = ""<CR>:call clearmatches()<CR>
" Don't move on *
nnoremap * *<C-o>
" Keep search matches in the middle of the window.
nnoremap n nzzzv
nnoremap N Nzzzv
" Same when jumping around
nnoremap g; g;zz
nnoremap g, g,zz
nnoremap <C-o> <C-o>zz
" Easier to type, and I never use the default behavior.
noremap H ^
noremap L $
vnoremap L g_
" Workaround wrapped lines
noremap j gj
noremap k gk
noremap gj j
noremap gk k
" List navigation
nnoremap <left>  :cprev<cr>zvzz
nnoremap <right> :cnext<cr>zvzz
nnoremap <up>    :lprev<cr>zvzz
nnoremap <down>  :lnext<cr>zvzz

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
set numberwidth=5       " number of culumns for line numbers
set textwidth=140
set nowrap              " Do not wrap words (view)
set showcmd             " Show (partial) command in status line.
set showmatch           " Show matching brackets.
set ruler               " line and column number of the cursor position
set wildmenu            " enhanced command completion
set wildmode=list:longest
set visualbell          " use visual bell instead of beeping
set laststatus=2        " always show the status line
set showtabline=2       " always show the tabs line
set lazyredraw
autocmd WinLeave,InsertEnter * set nocursorline
autocmd WinEnter,InsertLeave * set cursorline

" Folding
set foldlevelstart=1
set foldmethod=syntax
set nofoldenable
function! MyFoldText() " {{{
    let line = getline(v:foldstart)
    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let foldedlinecount = v:foldend - v:foldstart
    " expand tabs into spaces
    let onetab = strpart('          ', 0, &tabstop)
    let line = substitute(line, '\t', onetab, 'g')
    let line = strpart(line, 0, windowwidth - 2 - len(foldedlinecount))
    let fillcharcount = windowwidth - len(line) - len(foldedlinecount)
    return line . '…' . repeat(" ",fillcharcount) . foldedlinecount . '…' . ' '
endfunction " }}}
set foldtext=MyFoldText()

" Special chars
set nolist
set listchars=tab:▸\ ,eol:¬,trail:·,extends:»,precedes:«

" Behavior
" Ignore these files when completing names and in explorer
set wildignore+=.svn,CVS,.git,.hg,*.o,*.a,*.class,*.mo,*.la,*.so,*.obj,*.swp,*.jpg,*.png,*.xpm,*.gif,vendor/**,coverage/**,tmp/**,rdoc/**
set autowriteall        " automatically save before commands like :next and :make
set hidden              " enable multiple modified buffers
set history=1000
set autoread            " automatically read file that has been changed on disk and doesn't have changes in vim
set backspace=indent,eol,start
set complete=.,w,b,u,t
set completeopt=longest,menuone,preview
set modelines=5         " number of lines to check for vim: directives at the start/end of file
set autoindent          " automatically indent new line
set ts=4                " number of spaces in a tab
set sw=4                " number of spaces for indent
set et                  " expand tabs into spaces
set splitbelow          " split window below
set splitright
set noequalalways       " don't change windows sizes when open/close windows
" set notimeout         " time out on key codes but not mappings
set timeoutlen=500
set ttimeoutlen=50      " ,ake Esc work faster
set synmaxcol=800       " don't try to highlight lines longer than 800 characters
set tags+=./tags

" Backups
set backup              " write backup files
set noswapfile          " do not write .swp files
set undofile
set undoreload=10000
set undodir=~/.vim/tmp/undo//     " undo files
set backupdir=~/.vim/tmp/backup// " backups

" Make those folders automatically if they don't already exist.
if !isdirectory(expand(&undodir))
    call mkdir(expand(&undodir), "p")
endif
if !isdirectory(expand(&backupdir))
    call mkdir(expand(&backupdir), "p")
endif

" Normally, Vim messes with iskeyword when you open a shell file. This can
" leak out, polluting other file types even after a 'set ft=' change. This
" variable prevents the iskeyword change so it can't hurt anyone.
let g:sh_noisk=1
let g:is_bash=1

" Scroll paddings
set scrolloff=5
set sidescrolloff=10
set sidescroll=1

" Search settings
set incsearch           " Incremental search
set hlsearch            " Highlight search match
set ignorecase          " Do case insensitive matching
set smartcase           " do not ignore if search pattern has CAPS


" Autocmds
autocmd BufEnter .server_aliases,.server_admin_aliases setlocal ft=sh
" Format XML files
autocmd FileType xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null
" Tabs and spaces corrections for different file types
autocmd Filetype ruby,yaml,slim,coffee setlocal ts=2 sts=2 sw=2
" CoffeeScript
autocmd BufNewFile,BufReadPost *.coffee setlocal foldmethod=indent
" Jump to last cursor position unless it's invalid or in an event handler
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
" Remove trailing whitespaces on save
autocmd FileType php,ruby,js,coffee,scss,css,j2,ini,vim autocmd BufWritePre <buffer> :%s/\s\+$//e


" Functions
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
noremap <leader>n :call RenameFile()<CR>


" Plugins mappings and settings
" NERDTree
let NERDTreeMinimalUI  = 1
let NERDTreeDirArrows  = 1
let NERDTreeShowHidden = 1
let NERDTreeWinSize    = 35
let NERDTreeIgnore     = ['^\.DS_Store$', '^\.rake_tasks$', '^tags$', '\~$', '.bundle[[dir]]', '.idea[[dir]]', '.capistrano[[dir]]', '.vagrant[[dir]]', '.git[[dir]]']
let NERDTreeHighlightCursorline = 1
nnoremap <silent><F3> :NERDTreeToggle<CR>
inoremap <silent><F3> <Esc>:NERDTreeToggle<CR>

" CtrlP
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor
  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s --files-with-matches --hidden -g ""'
  let g:ctrlp_use_caching = 0
endif
let g:ctrlp_by_filename = 1
nnoremap <silent><leader><leader> :CtrlPBuffer<CR>
nnoremap <silent><leader>. :CtrlPTag<CR>

" Surround
nnoremap <silent><leader>ds cs"'
nnoremap <silent><leader>sd cs'"

" Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
nnoremap <leader>1 <Plug>AirlineSelectTab1
nnoremap <leader>2 <Plug>AirlineSelectTab2
nnoremap <leader>3 <Plug>AirlineSelectTab3
nnoremap <leader>4 <Plug>AirlineSelectTab4
nnoremap <leader>5 <Plug>AirlineSelectTab5
nnoremap <leader>6 <Plug>AirlineSelectTab6
nnoremap <leader>7 <Plug>AirlineSelectTab7
nnoremap <leader>8 <Plug>AirlineSelectTab8
nnoremap <leader>9 <Plug>AirlineSelectTab9

" Tabularize
noremap <silent><leader>b= :Tabularize /=<CR>
noremap <silent><leader>b: :Tabularize /:\zs<CR>

" RSpec mappings
let g:rspec_command = 'call Send_to_Tmux("bin/rspec --no-profile --format progress {spec}\n")'
noremap <leader>sc :call RunCurrentSpecFile()<CR>
noremap <leader>sn :call RunNearestSpec()<CR>
noremap <leader>sl :call RunLastSpec()<CR>
noremap <leader>sa :call RunAllSpecs()<CR>

" Rails
noremap <leader>a :A<CR>
noremap <leader>r :R<CR>

" Rubocop
noremap <localleader>r :call Send_to_Tmux("rubocop\n")<CR>
noremap <localleader>ra :call Send_to_Tmux("rubocop -a\n")<CR>

" Git
noremap <leader>gs :Gstatus<CR>
noremap <leader>gd :Gdiff<CR>
