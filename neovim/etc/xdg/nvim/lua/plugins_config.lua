local M = {}

g = vim.g

function M.trouble()
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
end

function M.telescope()
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
end

function M.indent_blankline()
  g.indentLine_fileTypeExclude = {'dashboard', 'help'}
  g.indent_blankline_use_treesitter = true
  g.indent_blankline_show_first_indent_level = false
  g.indentLine_char = '│'
end

function M.better_whitespace()
  g.better_whitespace_enabled = true
  g.strip_whitespace_on_save = false
  g.better_whitespace_filetypes_blacklist = {'dashboard', 'help', 'markdown'}
end

function M.vim_tmux_navigator()
  g.tmux_navigator_no_mappings = true
end

function M.supertab()
  g.SuperTabDefaultCompletionType = '<c-n>'
end

function M.vim_pasta()
  g.pasta_disabled_filetypes = {}
end

function M.treesitter()
  require('nvim-treesitter.configs').setup {
    ensure_installed = {'c', 'cpp', 'python', 'bash', 'html', 'java', 'json', 'lua', 'regex', 'toml'},
    ignore_install = {},
    highlight = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-n>",
        node_incremental = "<C-n>",
        scope_incremental = "<C-s>",
        node_decremental = "<C-r>",
      },
    },

  }
end

function M.lspconfig()
  vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {virtual_text = false}
  )

  local nvim_lsp = require('lspconfig')
  local servers = { 'pylsp', 'clangd' }
  for _, lsp in ipairs(servers) do
      nvim_lsp[lsp].setup {}
  end
end

function M.compe()
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
end

function M.dashboard()
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

  g.dashboard_custom_footer = {'🙃'}
end

function M.treesitter_context()
  require'treesitter-context.config'.setup { enable = true }
end

function M.lsp_signature()
  require 'lsp_signature'.setup()
end

function M.gitsigns()
  require('gitsigns').setup()
end

function M.lightbulb()
  vim.cmd "autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()"
end

function M.lightline()
  g.lightline = {colorscheme = "one"}
end

function M.onedark()
  g.onedark_style = "darker"
  vim.cmd "colorscheme onedark"
end

function M.treesitter_textobjects()
  require("nvim-treesitter.configs").setup {
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        }
      }
    }
  }
end

return M
