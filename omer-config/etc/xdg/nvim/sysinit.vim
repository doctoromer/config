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

" Telescope.nvim
nnoremap <leader>f <cmd>Telescope find_files<cr>
nnoremap <leader>a <cmd>Telescope live_grep<cr>
nnoremap <leader>b <cmd>Telescope buffers<cr>
nnoremap <leader>h <cmd>Telescope help_tags<cr>

" Treesitter.nvim
lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = {"c", "cpp", "python", "bash", "html", "java", "json", "lua", "regex", "toml"},
  ignore_install = {},
  highlight = { enable = true },
}
EOF

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

" Semshi
let g:semshi#error_sign = v:false

" vim-pasta
let g:pasta_disabled_filetypes = []

" Argwrap
nnoremap <silent> gs :ArgWrap<CR>

" =============== LSP ===============

lua << EOF
local nvim_lsp = require('lspconfig')

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { noremap=true, silent=true }

  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', '<leade>gD', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', 'gx', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap("n", "<leader>gf", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

end

local servers = { "pyls", "clangd" }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup { on_attach = on_attach }
end
EOF

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
