
vim.cmd [[
    autocmd VimResized * wincmd =
    autocmd FocusGained,BufEnter * :checktime

    let g:onedark_style = 'darker'
    colorscheme onedark

    command W w
    command Wq wq
    command WQ wq
    command Q q
]]

require('config')
require('keybind')
require('plugins')
require('plugins_config')
