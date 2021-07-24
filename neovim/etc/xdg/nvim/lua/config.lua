local o = vim.o

o.showmode = true
o.showmatch = true
o.ttimeoutlen = 0
o.foldenable = false
o.lazyredraw = true
o.clipboard = 'unnamed'
o.hidden = true

-- Window display
o.number = true
o.signcolumn = 'yes'
o.colorcolumn = '81'
o.lazyredraw = true
o.completeopt = 'menu'

-- Persistentcy
o.undofile = true
o.swapfile = false
o.autowrite = true

-- Indentation
o.smartindent = true
o.shiftwidth = 4
o.softtabstop = 4
o.tabstop = 4
o.expandtab = true

o.wrap = false
o.linebreak = true

-- Windows
o.splitright = true
o.splitbelow = true
