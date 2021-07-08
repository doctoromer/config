lua << EOF
vim.o.compatible = false
vim.o.showcmd = true
vim.o.showmode = true
vim.o.showmatch = true
vim.o.nrformats='bin,hex'
vim.o.wildmenu = true
vim.o.ttimeoutlen = 0
vim.o.foldenable = false
vim.o.lazyredraw = true
vim.o.backspace = 'indent,eol,start'
vim.o.clipboard = 'unnamed'
vim.o.hidden = true

-- =============== Window display ===============
vim.o.encoding = 'utf-8'
vim.o.number = true
vim.o.ruler = true
vim.o.signcolumn = 'yes'
vim.o.colorcolumn = '81'
vim.o.lazyredraw = true
vim.o.laststatus = 2
vim.o.completeopt = 'menu'

-- =============== Persistentcy ===============
vim.o.undofile = true
vim.o.swapfile = false
vim.o.autoread = true
vim.o.autowrite = true

-- =============== Indentation ===============
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.smarttab = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.tabstop = 4
vim.o.expandtab = true

vim.o.wrap = false
vim.o.linebreak = true

-- =============== Search ===============
vim.o.incsearch = true
vim.o.hlsearch = true

-- =============== Windows ===============
vim.o.splitright = true
vim.o.splitbelow = true

vim.g.mapleader = ';'

EOF

" =============== Vim only ===============
syntax on
autocmd VimResized * wincmd =
au FocusGained,BufEnter * :checktime
filetype plugin on
filetype indent on


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

nnoremap gx <cmd>Telescope lsp_references<cr>
nnoremap gd <cmd>Telescope lsp_definitions<cr>
nnoremap gs <cmd>Telescope lsp_document_symbols<cr>

lua <<EOF
local actions = require('telescope.actions')
-- Global remapping
------------------------------
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<ESC>"] = actions.close,
        ["<C-c>"] = actions.close,
      },
      n = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<ESC>"] = actions.close,
        ["<C-c>"] = actions.close,
      },
    },
  }
}
EOF

" Treesitter.nvim
" lua <<EOF
" require'nvim-treesitter.configs'.setup {
"   ensure_installed = {"c", "cpp", "python", "bash", "html", "java", "json", "lua", "regex", "toml"},
"   ignore_install = {},
"   highlight = { enable = true },
" }
" EOF

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
nnoremap <silent> ga :ArgWrap<CR>


lua << EOF

-- =============== LSP ===============

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false
    }
)

local nvim_lsp = require('lspconfig')

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { noremap=true, silent=true }

  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', '<leade>gD', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap("n", "<leader>gf", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

end

local servers = { "pyls", "clangd" }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup { on_attach = on_attach }
end

-- =============== nvim-compe ===============

require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  resolve_timeout = 800;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = {
    border = { '', '' ,'', ' ', '', '', '', ' ' },
    winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
    max_width = 120,
    min_width = 60,
    max_height = math.floor(vim.o.lines * 0.3),
    min_height = 1,
  };

  source = {
    path = true;
    buffer = true;
    calc = true;
    nvim_lsp = true;
    nvim_lua = true;
    vsnip = true;
    ultisnips = true;
    luasnip = true;
  };
}
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
