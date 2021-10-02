local M = {}

g = vim.g
fn = vim.fn

function M.telescope()
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

function M.indent_blankline()
  g.indentLine_fileTypeExclude = {"dashboard", "help"}
  g.indent_blankline_use_treesitter = true
  g.indent_blankline_show_first_indent_level = false
  g.indentLine_char = "│"
end

function M.better_whitespace()
  g.better_whitespace_enabled = true
  g.strip_whitespace_on_save = false
  g.better_whitespace_filetypes_blacklist = {"dashboard", "help", "markdown"}
end

function M.navigator_nvim()
  require('Navigator').setup()
end

function M.supertab()
  g.SuperTabDefaultCompletionType = "<c-n>"
end

function M.vim_pasta()
  g.pasta_disabled_filetypes = {}
end

function M.treesitter()
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

function M.lspconfig()
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {virtual_text = false}
  )

  local nvim_lsp = require("lspconfig")
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
      nvim_lsp[server_name].setup(config)
  end

end

function M.compe()
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

function M.dashboard()
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

function M.treesitter_context()
  require"treesitter-context.config".setup { enable = true }
end

function M.lsp_signature()
  require "lsp_signature".setup()
end

function M.gitsigns()
  require("gitsigns").setup()
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

function M.nvim_dap()
  local dap = require("dap")
  dap.adapters.python = {
    type = "executable",
    command = "/usr/bin/python3",
    args = {"-m", "debugpy.adapter"}
  }
  dap.configurations.python = {
    {
      type = "python",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      pythonPath = function()
        local cwd = fn.getcwd()
        if fn.executable(cwd .. "/venv/bin/python3") == 1 then
          return cwd .. "/venv/bin/python3"
        elseif fn.executable(cwd .. "/.venv/bin/python3") == 1 then
          return cwd .. "/.venv/bin/python3"
        else
          return "/usr/bin/python3"
        end
      end
    },
  }
  fn.sign_define("DapBreakpoint", {text="🔴", texthl="", linehl="", numhl=""})
  fn.sign_define("DapStopped", {text="🔵", texthl="", linehl="", numhl=""})
end

function M.nvim_dap_ui()
  require("dapui").setup()
end

function M.vsnip()
  -- This sets the snippets dir to be relative to this file.
  -- Then, it is possible to use this in user's home directory or as a system wide configuration.
  g.vsnip_snippet_dir = fn.fnamemodify(vim.call("resolve", fn.expand("<sfile>:p")), ":h") .. "/../snippets"
end

function M.which_key()
  require("which-key").setup()
end

function M.comment()
  require("nvim_comment").setup()
end

return M
