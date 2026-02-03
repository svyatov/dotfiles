" Restore terminal cursor on exit
au VimLeave * set guicursor=a:hor20

" =============================================================================
" SYNTAX & FILETYPE
" =============================================================================
syntax enable               " Enable syntax highlighting
filetype plugin indent on   " Enable filetype detection, plugins, and indent

" =============================================================================
" DISPLAY
" =============================================================================
set number                  " Show line numbers
set relativenumber          " Relative line numbers (hybrid with number)
set cursorline              " Highlight current line
set signcolumn=yes          " Always show sign column
set scrolloff=8             " Keep 8 lines above/below cursor
set sidescrolloff=8         " Keep 8 columns left/right of cursor
set termguicolors           " Enable 24-bit RGB colors
try
  colorscheme wildcharm    " Color scheme
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
endtry

" =============================================================================
" INDENTATION
" =============================================================================
set expandtab               " Use spaces instead of tabs
set tabstop=2               " Tab width
set shiftwidth=2            " Indent width
set softtabstop=2           " Soft tab width
set smartindent             " Smart auto-indenting
set autoindent              " Copy indent from current line

" =============================================================================
" SEARCH
" =============================================================================
set ignorecase              " Case-insensitive search
set smartcase               " Unless uppercase is used
set incsearch               " Incremental search
set hlsearch                " Highlight search results

" =============================================================================
" EDITING
" =============================================================================
" clipboard: use explicit mappings instead of unnamedplus (preserves linewise yank)
set mouse=a                 " Enable mouse in all modes
set undofile                " Persistent undo history
set noswapfile              " Disable swap files
set nobackup                " Disable backup files
set updatetime=250          " Faster update time (default 4000ms)
set timeoutlen=300          " Faster key sequence timeout
set autoread                " Auto-reload files changed outside Neovim

" =============================================================================
" SPLITS
" =============================================================================
set splitbelow              " Horizontal splits below
set splitright              " Vertical splits to the right

" =============================================================================
" RESTORE CURSOR POSITION
" =============================================================================
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

" =============================================================================
" LEADER KEY
" =============================================================================
let mapleader = " "         " Set leader to Space (press Space then the key)

" =============================================================================
" KEYMAPS
" =============================================================================
" Open Claude Code in a vertical split
nnoremap <leader>cc :vsplit<CR>:terminal claude<CR>i
nnoremap <leader>ccr :vsplit<CR>:terminal claude --resume<CR>i

" Easier window navigation (Ctrl + h/j/k/l instead of Ctrl+w then h/j/k/l)
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Close current window with Space+q
nnoremap <leader>q :q<CR>
tnoremap <C-q> <C-\><C-n>:q<CR>

" Exit insert mode in the terminal
tnoremap <C-[> <C-\><C-n>

" Terminal: auto-enter insert mode when switching to terminal buffer
autocmd BufEnter term://* startinsert

" Clear search highlight
nnoremap <leader>h :nohlsearch<CR>

" Move lines up/down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Save file
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a

" Select all
nnoremap <C-a> ggVG

" System clipboard: Space+y to copy, Space+p to paste
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>Y "+Y
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p

" Config: open and reload
nnoremap <leader>ve :e $MYVIMRC<CR>
nnoremap <leader>vs :source $MYVIMRC<CR>:echo "Config reloaded!"<CR>

" =============================================================================
" COMMENT FORMATTING (space after comment symbol)
" =============================================================================
autocmd FileType javascript,typescript,typescriptreact,javascriptreact,c,cpp,java,go,rust setlocal commentstring=//\ %s
autocmd FileType python,ruby,bash,sh,zsh,yaml setlocal commentstring=#\ %s
autocmd FileType lua setlocal commentstring=--\ %s
autocmd FileType vim setlocal commentstring=\"\ %s
autocmd FileType html,xml setlocal commentstring=<!--\ %s\ -->
autocmd FileType css,scss setlocal commentstring=/*\ %s\ */
autocmd FileType sql setlocal commentstring=--\ %s

" =============================================================================
" AUTO-RELOAD FILES
" =============================================================================
" Check for external changes when switching buffers/windows or after inactivity
autocmd FocusGained,BufEnter,CursorHold * checktime

" =============================================================================
" CHEATSHEET
" =============================================================================
"
" CUSTOM KEYMAPS (this config)
" ---------------------------
" Space cc      Open Claude Code in split
" Space ccr     Open Claude Code (resume last session)
" Ctrl+h/j/k/l  Navigate between splits
" Space q       Close current window
" Ctrl+q        Close terminal (from terminal mode)
" Ctrl+[        Exit terminal insert mode
" Space h       Clear search highlight
" Alt+j/k       Move line(s) up/down
" Ctrl+s        Save file
" Ctrl+a        Select all
" Space y/Y     Yank to system clipboard
" Space p/P     Paste from system clipboard
" Space ve      Edit config (vimrc)
" Space vs      Source/reload config
" gcc           Toggle comment (built-in)
" gc{motion}    Comment with motion (e.g., gcip)
"
" NAVIGATION
" ----------
" w / b         Jump forward/back by word
" e             Jump to end of word
" 0 / $         Start/end of line
" ^             First non-blank character
" gg / G        Top/bottom of file
" { / }         Jump by paragraph/block
" %             Jump to matching bracket
" f{char}       Jump to {char} on line (then ; to repeat)
" Ctrl+d/u      Half-page down/up
" zz            Center line on screen
" Ctrl+o/i      Jump back/forward in history
"
" EDITING (Verb + Noun)
" ---------------------
" Verbs: d=delete, c=change, y=yank, v=visual
" Nouns: iw=inner word, i"=inner quotes, ip=inner paragraph
"        aw=around word, a"=around quotes, it=inner tag
"
" Examples:
"   ciw         Change inner word
"   ci" ci( ci{ Change inside quotes/parens/braces
"   diw dip     Delete inner word/paragraph
"   yiw yap     Yank inner word / around paragraph
"   vip         Visual select paragraph
"   da"         Delete around quotes (incl. quotes)
"
" OTHER USEFUL
" ------------
" yyp           Duplicate line below
" dd            Delete line
" >> / <<       Indent/unindent
" ==            Auto-indent line
" J             Join line below
" u / Ctrl+r    Undo/redo
" .             Repeat last change
" *             Search word under cursor
" n / N         Next/prev search result
" :s/old/new/g  Replace on current line
" :%s/old/new/g Replace in entire file
"
" VISUAL MODE
" -----------
" v             Character-wise
" V             Line-wise
" Ctrl+v        Block (column) mode
" Then: d, y, c, >, <, = to act on selection
