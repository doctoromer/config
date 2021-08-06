
vim.cmd [[
    autocmd VimResized * wincmd =
    autocmd FocusGained,BufEnter * :checktime

    command W w
    command Wq wq
    command WQ wq
    command Q q
]]

require('config')
require('keybind')
require('plugins')
require('plugins_config')
