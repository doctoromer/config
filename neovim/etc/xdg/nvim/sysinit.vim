" =============== Plugin ===============
execute pathogen#infect()
execute pathogen#helptags()

lua require("init")

" =============== Vim only ===============
syntax on
autocmd VimResized * wincmd =
au FocusGained,BufEnter * :checktime
filetype plugin on
filetype indent on


" =============== Plugins configurations ===============

" colorscheme
let g:onedark_style = 'darker'
colorscheme onedark


" neosnippet
imap <C-Space> <Plug>(neosnippet_expand_or_jump)
smap <C-Space> <Plug>(neosnippet_expand_or_jump)
xmap <C-Space> <Plug>(neosnippet_expand_target)

" IndentLine
autocmd FileType help IndentLinesDisable
autocmd FileType json IndentLinesDisable

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
