-- General
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

-- Window display
vim.o.encoding = 'utf-8'
vim.o.number = true
vim.o.ruler = true
vim.o.signcolumn = 'yes'
vim.o.colorcolumn = '81'
vim.o.lazyredraw = true
vim.o.laststatus = 2
vim.o.completeopt = 'menu'

-- Persistentcy
vim.o.undofile = true
vim.o.swapfile = false
vim.o.autoread = true
vim.o.autowrite = true

-- Indentation
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.smarttab = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.tabstop = 4
vim.o.expandtab = true

vim.o.wrap = false
vim.o.linebreak = true

-- Search
vim.o.incsearch = true
vim.o.hlsearch = true

-- Windows
vim.o.splitright = true
vim.o.splitbelow = true

vim.g.mapleader = ';'

-- indent-blankline.nvim
vim.g.indent_blankline_use_treesitter = true

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
vim.api.nvim_set_keymap("n", "<leader>x", "<cmd>Trouble<cr>", {silent = true, noremap = true})

-- Telescope.nvim
vim.api.nvim_set_keymap('n', '<leader>f', '<cmd>Telescope find_files<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>a', '<cmd>Telescope live_grep<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>b', '<cmd>Telescope buffers<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>h', '<cmd>Telescope help_tags<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>m', '<cmd>Telescope keymaps<cr>', {noremap = true})

vim.api.nvim_set_keymap('n', 'gx', '<cmd>Telescope lsp_references<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', 'gd', '<cmd>Telescope lsp_definitions<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', 'gs', '<cmd>Telescope lsp_document_symbols<cr>', {noremap = true})

local actions = require('telescope.actions')

require('telescope').setup {
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

-- Easymotion
vim.api.nvim_set_keymap('n', '<Space>', '<Plug>(easymotion-prefix)', {})
vim.api.nvim_set_keymap('v', '<Space>', '<Plug>(easymotion-prefix)', {})

-- IndentLine
vim.g.indentLine_char = '│'

-- better-whitespace
vim.g.better_whitespace_enabled = true
vim.g.strip_whitespace_on_save = false

-- vim-tmux-navigator
vim.g.tmux_navigator_no_mappings = true
vim.api.nvim_set_keymap('n', '<M-h>', '<cmd>TmuxNavigateLeft<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<M-j>', '<cmd>TmuxNavigateDown<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<M-k>', '<cmd>TmuxNavigateUp<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<M-l>', '<cmd>TmuxNavigateRight<cr>', {noremap = true, silent = true})

-- superTab
vim.g.SuperTabDefaultCompletionType = "<c-n>"

-- vim-pasta
vim.g.pasta_disabled_filetypes = {}

-- Argwrap
vim.api.nvim_set_keymap('n', 'ga', '<cmd>ArgWrap<cr>', {noremap = true, silent = true})

-- Treesitter.nvim
require'nvim-treesitter.configs'.setup {
  ensure_installed = {"c", "cpp", "python", "bash", "html", "java", "json", "lua", "regex", "toml"},
  ignore_install = {},
  highlight = { enable = true },
}

-- Semshi
vim.g['semshi#error_sign'] = false

-- nvim-lspconfig
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

-- nvim-compe
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
