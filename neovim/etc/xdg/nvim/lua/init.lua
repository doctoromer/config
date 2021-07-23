-- General

local o = vim.o
local g = vim.g
local api = vim.api

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

g.mapleader = ';'

-- Trouble.nvim
require("trouble").setup {
    icons = false,
    fold_open = "v",
    fold_closed = ">",
    indent_lines = false,
    signs = {
        error = "error",
        warning = "warn",
        hint = "hint",
        information = "info",
        other = "other"
    },
    use_lsp_diagnostic_signs = false
}
api.nvim_set_keymap("n", "<leader>x", "<cmd>Trouble<cr>", {silent = true, noremap = true})

-- Telescope.nvim
api.nvim_set_keymap('n', '<leader>f', '<cmd>Telescope find_files<cr>', {noremap = true})
api.nvim_set_keymap('n', '<leader>a', '<cmd>Telescope live_grep<cr>', {noremap = true})
api.nvim_set_keymap('n', '<leader>l', '<cmd>Telescope current_buffer_fuzzy_find<cr>', {noremap = true})
api.nvim_set_keymap('n', '<leader>b', '<cmd>Telescope buffers<cr>', {noremap = true})
api.nvim_set_keymap('n', '<leader>h', '<cmd>Telescope help_tags<cr>', {noremap = true})
api.nvim_set_keymap('n', '<leader>m', '<cmd>Telescope keymaps<cr>', {noremap = true})

api.nvim_set_keymap('n', 'gx', '<cmd>Telescope lsp_references<cr>', {noremap = true})
api.nvim_set_keymap('n', 'gd', '<cmd>Telescope lsp_definitions<cr>', {noremap = true})
api.nvim_set_keymap('n', 'gs', '<cmd>Telescope lsp_document_symbols<cr>', {noremap = true})

local actions = require('telescope.actions')

require('telescope').setup {
    defaults = {
        vimgrep_arguments = {
            'ag',
            '--nocolor',
            '--noheading',
            '--filename',
            '--numbers',
            '--column',
            '--smart-case'
        },
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
            }
        }
    }
}

-- Easymotion
api.nvim_set_keymap('n', '<Space>', '<Plug>(easymotion-prefix)', {})
api.nvim_set_keymap('v', '<Space>', '<Plug>(easymotion-prefix)', {})

-- indent-blankline.nvim
g.indentLine_fileTypeExclude = {'dashboard', 'help'}
g.indent_blankline_use_treesitter = true
g.indentLine_char = '│'

-- better-whitespace
g.better_whitespace_enabled = true
g.strip_whitespace_on_save = false
g.better_whitespace_filetypes_blacklist = {'dashboard', 'help'}

-- vim-tmux-navigator
g.tmux_navigator_no_mappings = true
api.nvim_set_keymap('n', '<M-h>', '<cmd>TmuxNavigateLeft<cr>', {noremap = true, silent = true})
api.nvim_set_keymap('n', '<M-j>', '<cmd>TmuxNavigateDown<cr>', {noremap = true, silent = true})
api.nvim_set_keymap('n', '<M-k>', '<cmd>TmuxNavigateUp<cr>', {noremap = true, silent = true})
api.nvim_set_keymap('n', '<M-l>', '<cmd>TmuxNavigateRight<cr>', {noremap = true, silent = true})

-- superTab
g.SuperTabDefaultCompletionType = "<c-n>"

-- vim-pasta
g.pasta_disabled_filetypes = {}

-- Argwrap
api.nvim_set_keymap('n', 'ga', '<cmd>ArgWrap<cr>', {silent = true})

-- Treesitter.nvim
require('nvim-treesitter.configs').setup {
  ensure_installed = {"c", "cpp", "python", "bash", "html", "java", "json", "lua", "regex", "toml"},
  ignore_install = {},
  highlight = { enable = true },
}

-- nvim-lspconfig
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false
    }
)

local nvim_lsp = require('lspconfig')

local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) api.nvim_buf_set_option(bufnr, ...) end

    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    local opts = { noremap=true, silent=true }

    buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', '<leader>gD', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
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

-- nvim-compe
require('compe').setup {
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
        max_height = math.floor(o.lines * 0.3),
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

-- dashboard.nvim
g.dashboard_default_executive = 'telescope'
g.dashboard_custom_shortcut = {
    last_session = '';
    find_history = '';
    find_file = '';
    new_file = '';
    change_colorscheme = '';
    find_word = '';
    book_marks = '';
}

g.dashboard_custom_shortcut_icon = {
    last_session = '';
    find_history = '';
    find_file = '';
    new_file = '';
    change_colorscheme = '';
    find_word = '';
    book_marks = '';
}

g.dashboard_custom_header = {
    '',
    '         __                         ',
    '        / /\\                       ',
    '       / /  \\                      ',
    '      / /    \\__________           ',
    '     / /      \\        /\\         ',
    '    /_/        \\      / /          ',
    ' ___\\ \\      ___\\____/_/_        ',
    '/____\\ \\    /___________/\\       ',
    '\\     \\ \\   \\           \\ \\   ',
    ' \\     \\ \\   \\____       \\ \\  ',
    '  \\     \\ \\  /   /\\       \\ \\ ',
    '   \\   / \\_\\/   / /        \\ \\ ',
    '    \\ /        / /__________\\/    ',
    '     /        / /     /             ',
    '    /        / /     /              ',
    '   /________/ /\\    /              ',
    '   \\________\\/\\ \\  /            ',
    '               \\_\\/               ',
    ''
}

g.dashboard_custom_footer = {'Get in or get lost 🙃'}


-- treesitter-context.config
require'treesitter-context.config'.setup{ enable = true }

require "lsp_signature".setup()

-- =============== Mappings ===============

api.nvim_set_keymap('n', ';', '<nop>', {noremap = true})
api.nvim_set_keymap('n', '\\', ';', {noremap = true})

-- Stay in visual mode after indent or unindent
api.nvim_set_keymap('v', '>', '>gv', {})
api.nvim_set_keymap('v', '<', '<gv', {})

-- Disable bad keys
api.nvim_set_keymap('n', '<home>', '<nop>', {})
api.nvim_set_keymap('n', '<end>', '<nop>', {})
api.nvim_set_keymap('n', '<del>', '<nop>', {})
api.nvim_set_keymap('n', '<insert>', '<nop>', {})
api.nvim_set_keymap('n', '<left>', '<nop>', {})
api.nvim_set_keymap('n', '<down>', '<nop>', {})
api.nvim_set_keymap('n', '<up>', '<nop>', {})
api.nvim_set_keymap('n', '<right>', '<nop>', {})

-- Tabs
api.nvim_set_keymap('n', '<leader>tt', '<cmd>tabnew<cr>', {noremap = true, silent = true})
api.nvim_set_keymap('n', 'gb', '<cmd>tabprevious<cr>', {noremap = true, silent = true})
api.nvim_set_keymap('n', 'gf', '<cmd>-tabmove<cr>', {noremap = true, silent = true})
api.nvim_set_keymap('n', 'gh', '<cmd>+tabmove<cr>', {noremap = true, silent = true})

-- Horizontal scroll
api.nvim_set_keymap('n', 'zl', 'zL', {noremap = true})
api.nvim_set_keymap('n', 'zh', 'zH', {noremap = true})

-- Other
api.nvim_set_keymap('n', 'Y', 'y$', {noremap = true})
