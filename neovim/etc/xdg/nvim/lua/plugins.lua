local g = vim.g

-- Trouble.nvim
require('trouble').setup {
    icons = false,
    fold_open = 'v',
    fold_closed = '>',
    indent_lines = false,
    signs = {
        error = 'error',
        warning = 'warn',
        hint = 'hint',
        information = 'info',
        other = 'other'
    },
    use_lsp_diagnostic_signs = false
}

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
                ['<C-j>'] = actions.move_selection_next,
                ['<C-k>'] = actions.move_selection_previous,
                ['<ESC>'] = actions.close,
                ['<C-c>'] = actions.close,
            },
            n = {
                ['<C-j>'] = actions.move_selection_next,
                ['<C-k>'] = actions.move_selection_previous,
                ['<ESC>'] = actions.close,
                ['<C-c>'] = actions.close,
            }
        }
    }
}

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

-- superTab
g.SuperTabDefaultCompletionType = '<c-n>'

-- vim-pasta
g.pasta_disabled_filetypes = {}

-- Treesitter.nvim
require('nvim-treesitter.configs').setup {
  ensure_installed = {'c', 'cpp', 'python', 'bash', 'html', 'java', 'json', 'lua', 'regex', 'toml'},
  ignore_install = {},
  highlight = { enable = true },
}

-- nvim-lspconfig
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false
    }
)

local nvim_lsp = require('lspconfig')
local servers = { 'pylsp', 'clangd' }
for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {}
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
        winhighlight = 'NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder',
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

g.dashboard_custom_footer = {'Get lost 🙃'}


-- treesitter-context.config
require'treesitter-context.config'.setup { enable = true }

require 'lsp_signature'.setup()
require('gitsigns').setup()

vim.cmd("autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()")
