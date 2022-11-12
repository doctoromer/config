local o = vim.o
local g = vim.g

o.showmode = true
o.showmatch = true
o.ttimeoutlen = 0
o.foldenable = false
o.clipboard = "unnamed"
o.hidden = true
o.mouse = nil

-- Window display
o.number = true
o.signcolumn = "yes"
o.colorcolumn = "120"
o.completeopt = "menu,menuone,noselect"
o.display = "lastline"
o.laststatus = 3

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

-- Disable health check providers
g.loaded_perl_provider = 0
g.loaded_node_provider = 0
g.loaded_ruby_provider = 0
g.loaded_python_provider = 0

-- Disable default plugins
g.loaded_gzip = 1
g.loaded_zip = 1
g.loaded_zipPlugin = 1
g.loaded_tar = 1
g.loaded_tarPlugin = 1

g.loaded_getscript = 1
g.loaded_getscriptPlugin = 1
g.loaded_vimball = 1
g.loaded_vimballPlugin = 1
g.loaded_2html_plugin = 1

g.loaded_matchit = 1
g.loaded_matchparen = 1
g.loaded_logiPat = 1
g.loaded_rrhelper = 1

-- Other configurations
vim.api.nvim_create_autocmd("VimResized", {
    pattern = "*",
    callback = function()
        vim.cmd("wincmd =")
    end,
    desc = "Auto resize windows when terminal sized is changed",
})

local misspelled_commands = { "W", "Wq", "WQ", "Q", "Qa", "QA", "Wqa", "WQa", "WQA" }

for _, command in pairs(misspelled_commands) do
    vim.api.nvim_create_user_command(command, function()
        vim.cmd(string.lower(command))
    end, { bang = true })
end

-- Used for debugging
function p(...)
    print(vim.inspect(...))
end

return {
    nvim_root_dir = vim.fn.fnamemodify(vim.call("resolve", vim.fn.expand("<sfile>:p")), ":h"),
}
