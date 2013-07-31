" Настройки Vundle
" ================
" Git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
" -------------------------------------------------------------------
filetype off
filetype plugin indent on

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Позволяем Vundle заботиться самому о себе
Bundle 'gmarik/vundle'
Bundle 'vim-ruby/vim-ruby'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-repeat'
Bundle 'kchmck/vim-coffee-script'
Bundle 'ervandew/supertab'
Bundle 'scrooloose/nerdtree'
Bundle 'scrooloose/syntastic'
Bundle 'tomtom/tcomment_vim'
Bundle 'wincent/Command-T'
Bundle 'bling/vim-airline'
Bundle 't9md/vim-ruby-xmpfilter'

" Тема
Bundle "tomasr/molokai"
color molokai
let g:airline_theme = 'simple'

" Основные настройки
" ==================
"
" Отключение совместимости настроек с Vi
set nocompatible

" Отключить перерисовку экрана во время выполнения макросов и других рутинных операций 
" set lazyredraw

" Опции сессий
set sessionoptions=curdir,buffers,tabpages

" Работа с несколькими буферами одновременно
set hidden

" Не делать резервные копии файлов
set nobackup

" Не создавать свап файл
set noswapfile

" Всегда отображать статусную строку для каждого окна
set laststatus=2

" Разбивать окно горизонтально снизу
set splitbelow

" Разбивать окно вертикально слева
set nosplitright

" Не изменять размеры окон при открытии/закрытии новго окна
set noequalalways

" Всегда отображать табы
" set showtabline=2

" Кодировки
set encoding=utf8
set termencoding=utf8
set fileencodings=utf8,cp1251
set ffs=unix,mac,dos
set fileformat=unix

" Орфография и русский язык
set spelllang=ru_yo,en_us
"set keymap=russian-jcukenwin
set helplang=ru
set iskeyword=@,48-57,_,192-255

" Включаем подсветку синтаксиса
syntax on

" Отображение спецсимволов
set nolist
set listchars=tab:▸\ ,eol:¬,trail:·,extends:»,precedes:«
nmap <leader>l :set list!<CR>

" Хранить больше истории команд и правок
set history=128
set undolevels=2048

" Сохранение undo после закрытия файла
set undofile
set undodir=~/.vim/undo/

" Табы и отступы 
set tabstop=2
set shiftwidth=2
set softtabstop=2
set smarttab
set expandtab
set shiftround

" Автоотступы для новых строк
set autoindent
set nosmartindent

" Fixing problem with autoindent while pasting something
set pastetoggle=

" Show line numbers
set number

" Get rid of the delay when hitting esc!
set noesckeys

" Всегда показывать положение курсора
set ruler

" Показывать режим работы
set showmode

" Показывать команды
set showcmd

" И нет детей Уганды
set shortmess+=I

" По умолчанию латинская раскладка
set iminsert=0

" По умолчанию латинская раскладка при поиске
set imsearch=0

" Отслеживать изменения файлов
set autoread

" Поиск и подсветка результатов 
set hlsearch
set incsearch
set ignorecase
set smartcase

" Отступы при скролинге
set scrolloff=3
set sidescrolloff=7
set sidescroll=1

" Враппинг  
set nowrap
set textwidth=0

set gdefault " assume the /g flag on :s substitutions to replace all matches in a line

" Установка 'leader key'
let mapleader=","

" Включение меню
set wildmenu
set wildmode=list:longest,full
set wcm=<tab>

" Настройки автозавершение
set completeopt=menu,menuone,longest,preview

set complete=""
set complete+=.
set complete+=t
set complete+=k
set complete+=b

" Включение автодополнения
au FileType ruby,eruby set omnifunc=rubycomplete#Complete
au FileType python set omnifunc=pythoncomplete#Complete
au FileType php set omnifunc=phpcomplete#CompletePHP
au FileType html set omnifunc=htmlcomplete#CompleteTag
au FileType xml set omnifunc=xmlcomplete#CompleteTag
au FileType javascript set omnifunc=javascriptcomplete#CompleteJ
au FileType css set omnifunc=csscomplete#CompleteC

autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1

"improve autocomplete menu color
highlight Pmenu ctermbg=238 gui=bold

set wildignore+=*.png,*.PNG,*.JPG,*.jpg,*.GIF,*.gif,vendor/**,coverage/**,tmp/**,rdoc/**

" Разное
" ======
command! Q q " Bind :Q to :q
command! W w " Bind :W to :w
command! Wq wq " Bind :Wq to :wq

" Xmpfilter plugin bindings
nmap <buffer> <F5> <Plug>(xmpfilter-run)
xmap <buffer> <F5> <Plug>(xmpfilter-run)
imap <buffer> <F5> <Plug>(xmpfilter-run)
nmap <buffer> <F4> <Plug>(xmpfilter-mark)
xmap <buffer> <F4> <Plug>(xmpfilter-mark)
imap <buffer> <F4> <Plug>(xmpfilter-mark)

" Change working directory to currently open file (useful for Command-T)
map <leader>cd lcd %:p:h

" Tabs
map <c-t> :tabnew<cr>
map <c-x> :tabclose<cr>
map <c-n> :tabnext<cr>
map <c-p> :tabprev<cr>

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Emacs-like beginning and end of line.
imap <c-e> <c-o>$
imap <c-a> <c-o>^

" Выделить все
nmap <c-a> ggVG

" Копировать в системный буфер
vmap <c-c> "+y

" Вставить из системного буфера (конфликтует с вертикальным выделением)
" nmap <C-v> "+P
" imap <C-v> <esc>"+P$a

" Мапим быструю правку конфига vim'а
nmap <leader>vs :source $MYVIMRC<cr>
nmap <leader>ve :e $MYVIMRC<cr>

" Выход из редактора по двойному Esc
" map <esc><esc> <esc>:q!<cr>

" Сохранение файла
map <c-s> <esc>:w<cr>
imap <c-s> <esc>:w<cr>

" При отступах не снимать выделение
vnoremap < <gv
vnoremap > >gv

" Открыть NERDTree
map  <F3> :NERDTreeToggle<cr>
vmap <F3> <esc>:NERDTreeToggle<cr>v
imap <F3> <esc>:NERDTreeToggle<cr>i

" Устанавливаем 256 цветов 
set t_Co=256

" Меняем курсор для режима вставки 
" if exists('$TMUX')
"     let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
"     let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
" else
"     let &t_SI = "\<Esc>]50;CursorShape=1\x7"
"     let &t_EI = "\<Esc>]50;CursorShape=0\x7"
" endif
autocmd InsertEnter,InsertLeave * set cul!

" NERDTree
let g:NERDTreeShowHidden=1

" RENAME CURRENT FILE (thanks Gary Bernhardt)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
map <leader>n :call RenameFile()<cr>


" Автоопределение типов файлов 
augroup filetypedetect
    au BufNewFile,BufRead */etc/apache{,2}/*.conf setf apache
    au BufNewFile,BufRead */etc/mysql/*.cnf setf dosini
    au BufNewFile,BufRead */nginx/* setf nginx
    au BufNewFile,BufRead */sites-{available,enabled}/* setf apache
    au BufNewFile,BufRead */aliases setf zsh
augroup END

" Маппим русские буквы для выполнения команд без переключения раскладки
" =====================================================================
map ё `
map й q
map ц w
map у e
map к r
map е t
map н y
map г u
map ш i
map щ o
map з p
map х [
map ъ ]
map ф a
map ы s
map в d
map а f
map п g
map р h
map о j
map л k
map д l
map ж ;
map э '
map я z
map ч x
map с c
map м v
map и b
map т n
map ь m
map б ,
map ю .
map Ё ~
map Й Q
map Ц W
map У E
map К R
map Е T
map Н Y
map Г U
map Ш I
map Щ O
map З P
map Х {
map Ъ }
map Ф A
map Ы S
map В D
map А F
map П G
map Р H
map О J
map Л K
map Д L
map Ж :
map Э "
map Я Z
map Ч X
map С C
map М V
map И B
map Т N
map Ь M
map Б <
map Ю >

