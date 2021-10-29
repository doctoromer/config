local M = {}

local g = vim.g
local fn = vim.fn

M["telescope.nvim"] = function()
  local actions = require("telescope.actions")

  require("telescope").setup {
    defaults = {
      vimgrep_arguments = {
        "ag",
        "--nocolor",
        "--noheading",
        "--filename",
        "--numbers",
        "--column",
        "--smart-case"
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
end

M["indent-blankline.nvim"] = function()
  g.indentLine_fileTypeExclude = {"dashboard", "help"}
  g.indent_blankline_use_treesitter = true
  g.indent_blankline_show_first_indent_level = false
  g.indentLine_char = "│"
end

M["vim-better-whitespace"] = function()
  g.better_whitespace_enabled = true
  g.strip_whitespace_on_save = false
  g.better_whitespace_filetypes_blacklist = {"dashboard", "help", "markdown"}
end

M["Navigator.nvim"] = function()
  require('Navigator').setup()
end

M["vim-pasta"] = function()
  g.pasta_disabled_filetypes = {}
end

M["nvim-treesitter"] = function()
  require("nvim-treesitter.configs").setup {
    ensure_installed = {"c", "cpp", "python", "bash", "html", "java", "json", "lua", "regex", "toml"},
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

M["nvim-lspconfig"] = function()
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {virtual_text = false}
  )

  local lspconfig = require("lspconfig")
  local servers = {
    pylsp = {
      init_options = {documentFormatting = false}
    },
    clangd = {},
    efm = {
      init_options = {documentFormatting = true},
      filetypes = {"python"},
      settings = {
        -- cmd = {"efm-langserver"},
        rootMarkers = {".git/"},
        languages = {
          python = {
            {
              formatCommand = "autopep8 --max-line-length 120 -",
              formatStdin = true
            }
          }
        }
      }
    }
  }
  for server_name, config in pairs(servers) do
      lspconfig[server_name].setup(config)
  end

end

M["nvim-compe"] = function()
  require("compe").setup {
      enabled = true;
      autocomplete = true;
      debug = false;
      min_length = 1;
      preselect = "enable";
      throttle_time = 80;
      source_timeout = 200;
      resolve_timeout = 800;
      incomplete_delay = 400;
      max_abbr_width = 100;
      max_kind_width = 100;
      max_menu_width = 100;
      documentation = {
          border = { "", "" ,"", " ", "", "", "", " " },
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
      };
  }
end

M["dashboard-nvim"] = function()
  g.dashboard_default_executive = "telescope"
  g.dashboard_custom_shortcut = {
      last_session = "";
      find_history = "";
      find_file = "";
      new_file = "";
      change_colorscheme = "";
      find_word = "";
      book_marks = "";
  }

  g.dashboard_custom_shortcut_icon = {
      last_session = "";
      find_history = "";
      find_file = "";
      new_file = "";
      change_colorscheme = "";
      find_word = "";
      book_marks = "";
  }

  g.dashboard_custom_header = {
      "",
      "         __                         ",
      "        / /\\                       ",
      "       / /  \\                      ",
      "      / /    \\__________           ",
      "     / /      \\        /\\         ",
      "    /_/        \\      / /          ",
      " ___\\ \\      ___\\____/_/_        ",
      "/____\\ \\    /___________/\\       ",
      "\\     \\ \\   \\           \\ \\   ",
      " \\     \\ \\   \\____       \\ \\  ",
      "  \\     \\ \\  /   /\\       \\ \\ ",
      "   \\   / \\_\\/   / /        \\ \\ ",
      "    \\ /        / /__________\\/    ",
      "     /        / /     /             ",
      "    /        / /     /              ",
      "   /________/ /\\    /              ",
      "   \\________\\/\\ \\  /            ",
      "               \\_\\/               ",
      ""
  }

  g.dashboard_custom_footer = {"🙃"}
end

M["nvim-treesitter-context"] = function()
  require"treesitter-context.config".setup { enable = true }
end

M.lsp_signature = function()
  require "lsp_signature".setup()
end

M["gitsigns.nvim"] = function()
  require("gitsigns").setup()
end

M["lightline.vim"] = function()
  g.lightline = {colorscheme = "one"}
end

M["onedark.nvim"] = function()
  g.onedark_style = "darker"
  vim.cmd "colorscheme onedark"
end

M["nvim-treesitter-textobjects"] = function()
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

M["vim-vsnip"] = function()
  -- This sets the snippets dir to be relative to this file.
  -- Then, it is possible to use this in user's home directory or as a system wide configuration.
  g.vsnip_snippet_dir = fn.fnamemodify(vim.call("resolve", fn.expand("<sfile>:p")), ":h") .. "/../snippets"
end

M["which-key.nvim"] = function()
  require("which-key").setup()
end

M["nvim-comment"] = function()
  require("nvim_comment").setup()
end

return M
