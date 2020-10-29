set runtimepath^=~/.config/nvim
set rtp+=/usr/local/src/fzf
let &packpath = &runtimepath
set nocompatible

" =============== General ===============
set showcmd
set showmode
set showmatch
syntax on
set nrformats=bin,hex
set wildmenu
set ttimeoutlen=0
set nofoldenable
set lazyredraw
let mapleader=';'
set backspace=indent,eol,start
set clipboard=unnamed
set hidden

" =============== Window display ===============
set encoding=utf-8
set number
set ruler
set signcolumn=yes
set colorcolumn=81
set lazyredraw
set laststatus=2
set completeopt=menu
autocmd VimResized * wincmd =

" =============== Persistentcy ===============
set undofile
set noswapfile
set autoread
set autowrite
au FocusGained,BufEnter * :checktime

" =============== Indentation ===============
set autoindent
set smartindent
set smarttab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab

filetype plugin on
filetype indent on

set nowrap
set linebreak

" =============== Search ===============
set incsearch
set hlsearch

" =============== Windows ===============
set splitright
set splitbelow

" =============== Plugin ===============
execute pathogen#infect()
execute pathogen#helptags()

" =============== Plugins configurations ===============

" colorscheme
colorscheme monokai

" FZF
nmap <leader>f :Files<CR>
nmap <Leader>l :BLines<CR>
nmap <Leader>L :Lines<CR>
nmap <Leader>a :Ag<CR>
nmap <Leader>M :Maps<CR>
nmap <leader>w :Windows<CR>

" Easymotion
nmap <Space> <Plug>(easymotion-prefix)
vmap <Space> <Plug>(easymotion-prefix)

" IndentLine
let g:indentLine_char = '│'
let g:indentLine_enabled = 1
autocmd FileType help IndentLinesDisable
autocmd FileType json IndentLinesDisable

" better-whitespace
let g:better_whitespace_enabled = 1
let g:strip_whitespace_on_save = 0

" Highlighted-yank
let g:highlightedyank_highlight_duration = -1

" vim-tmux-navigator
let g:tmux_navigator_no_mappings = 1

if exists('$TMUX')
    nnoremap <silent> <M-h> :TmuxNavigateLeft<cr>
    nnoremap <silent> <M-j> :TmuxNavigateDown<cr>
    nnoremap <silent> <M-k> :TmuxNavigateUp<cr>
    nnoremap <silent> <M-l> :TmuxNavigateRight<cr>
endif

" deoplete
let g:deoplete#enable_at_startup = 1

" neosnippet
imap <C-Space> <Plug>(neosnippet_expand_or_jump)
smap <C-Space> <Plug>(neosnippet_expand_or_jump)
xmap <C-Space> <Plug>(neosnippet_expand_target)

" superTab
let g:SuperTabDefaultCompletionType = "<c-n>"

" LanguageClient
let g:LanguageClient_windowLogMessageLevel = "Log"
let g:LanguageClient_loggingLevel = "DEBUG"
let g:LanguageClient_useVirtualText = "No"

let g:LanguageClient_serverCommands = {
      \ 'python': ['pyls'],
      \ }

let commands = [
    \ ['clangd', ['clangd']],
    \ ['clangd-8', ['clangd-8']],
    \ ['clangd-6.0', ['clangd-6.0']],
    \ ['clangd-5.0', ['clangd-5.0']],
    \ ['clangd-4.0', ['clangd-4.0']],
    \ ['cquery', ['cquery', '--log-file=/tmp/cq.log']]
\ ]

for pair in commands
  if executable(pair[0])
    let g:LanguageClient_serverCommands.c = pair[1]
    break
  endif
endfor

let g:LanguageClient_loadSettings = 1
let g:LanguageClient_settingsPath = '/root/.config/nvim/settings.json'
set completefunc=LanguageClient#complete
set formatexpr=LanguageClient_textDocument_rangeFormatting()

nnoremap <silent> <F5> :call LanguageClient_contextMenu()<CR>
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> gr :call LanguageClient#textDocument_rename()<CR>
nnoremap <silent> gx :call LanguageClient#textDocument_references()<CR>
nnoremap <silent> gs :call LanguageClient#textDocument_documentSymbol()<CR>
nnoremap <silent> = :call LanguageClient#textDocument_formatting()<CR>

let g:LanguageClient_diagnosticsDisplay = {
\    1: {
\        "name": "Error",
\        "texthl": "ALEError",
\        "signText": "X",
\        "signTexthl": "ALEErrorSign",
\    },
\    2: {
\        "name": "Warning",
\        "texthl": "ALEWarning",
\        "signText": "!",
\        "signTexthl": "ALEWarningSign",
\    },
\    3: {
\        "name": "Information",
\        "texthl": "ALEInfo",
\        "signText": "?",
\        "signTexthl": "ALEInfoSign",
\    },
\    4: {
\        "name": "Hint",
\        "texthl": "ALEInfo",
\        "signText": "*",
\        "signTexthl": "ALEInfoSign",
\    },
\}
let g:LanguageClient_hoverPreview = "auto"

" =============== Mappings ===============

nnoremap ; <Nop>
nnoremap \ ;

" Stay in visual mode after indent or unindent
vmap > >gv
vmap < <gv

" Disable bad keys
noremap <Home> <Nop>
noremap <End> <Nop>
noremap <Del> <Nop>
noremap <Insert> <Nop>
noremap <Left> <Nop>
noremap <Down> <Nop>
noremap <Up> <Nop>
noremap <Right> <Nop>

" Tabs
noremap <silent> <Leader>tt :tabnew<CR>
noremap <silent> gb :tabprevious<CR>
noremap <silent> gf :-tabmove<CR>
noremap <silent> gh :+tabmove<CR>

" Horizontal scroll
noremap zl zL
noremap zh zH

" Save and quit convenience command mappings
command W w
command Wq wq
command WQ wq
command Q q

" Other
noremap Y y$
