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

" Save and quit convenience command mappings
command W w
command Wq wq
command WQ wq
command Q q
