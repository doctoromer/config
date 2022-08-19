local M = {}

local g = vim.g
local fn = vim.fn

M["legendary.nvim"] = function()
  legendary = require("legendary")
  legendary.setup()
  legendary.bind_keymaps(require("keymaps").other_keymaps())
end

M["nvim-lspconfig"] = function()
  local language_servers = {
    pylsp = {
      init_options = {documentFormatting = false}
    },
    clangd = {
      cmd = {
        (function()
          clangd_names = {"clangd", "clangd-12", "clangd-11", "clangd-10", "clangd-9"}
          for _, x in ipairs(clangd_names) do
            if fn.executable(x) == 1 then
              return x
            end
          end
        end)()
      },
    },
    cmake = {}
  }

  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {virtual_text = false}
  )

  local capabilities = nil
  pcall(
    function()
      local capabilities = require("cmp_nvim_lsp").update_capabilities(
        vim.lsp.protocol.make_client_capabilities()
      )
    end
  )

  for server_name, config in pairs(language_servers) do
      config.capabilities = capabilities
      require("lspconfig")[server_name].setup(config)
  end
end

M["lspsaga.nvim"] = function()
  require("lspsaga").init_lsp_saga {
    finder_action_keys = {
      vsplit = "v", split = "s", quit = {"q", "<esc>", "<C-c>"}, open = "<CR>"
    }
  }
end

M["formatter.nvim"] = function(formatter)
  formatters = {}

  if fn.executable("autopep8") == 1 then
    formatters.python = {
      function()
        return {
          exe = "autopep8",
          args = {
            "--in-place --max-line-length 120",
            fn.fnameescape(vim.api.nvim_buf_get_name(0))
          },
          stdin = false
        }
      end
    }
  end

  require("formatter").setup({filetype = formatters})
end

M["nvim-treesitter"] = function()
  require("nvim-treesitter.configs").setup {
    ensure_installed = {
      "c",
      "cpp",
      "cmake",
      "python",
      "bash",
      "html",
      "java",
      "json",
      "lua",
      "regex",
      "toml"
    },
    highlight = {enable = true},
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
  vim.wo.foldmethod = "expr"
  vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
end

M["nvim-treesitter-context"] = function()
  require("treesitter-context").setup {enable = true}
end

M["nvim-ts-rainbow"] = function()
  require("nvim-treesitter.configs").setup {
    rainbow = {
      enable = true,
      extended_mode = true,
      max_file_lines = nil,
    }
  }
end

M["nvim-treesitter-textobjects"] = function()
  require("nvim-treesitter.configs").setup {
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          af = "@function.outer",
          ["if"] = "@function.inner",
          ac = "@class.outer",
          ic = "@class.inner",
        }
      }
    }
  }
end

M["nvim-ts-autotag"] = function()
  require("nvim-treesitter.configs").setup {
    autotag = {enable = true}
  }
end

M["neogen"] = function()
  require("neogen").setup {}
end

M["nvim-treesitter-endwise"] = function()
  require("nvim-treesitter.configs").setup {
    endwise = {enable = true}
  }
end

M["nvim-cmp"] = function()
  local cmp = require("cmp")

  cmp.setup {
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    sources = cmp.config.sources(
      {{name = "luasnip"}, {name = "nvim_lsp"}, {name = "nvim_lsp_signature_help"}},
      {{name = "buffer"}},
      {{name = "path"}}
    )
  }

  cmp.setup.cmdline("/", {sources = {{name = "buffer"}}})
  cmp.setup.cmdline("?", {sources = {{name = "buffer"}}})
  cmp.setup.cmdline(":", {sources = cmp.config.sources({{name = "path"}}, {{name = "cmdline"}})})
end

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
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case"
        }
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

M["onedark.nvim"] = function()
  require("onedark").setup {
    style = "darker"
  }
  vim.cmd("colorscheme onedark")
end

M["lualine.nvim"] = function()
  require("lualine").setup {
    options = {
      theme = require("lualine.themes.onedark"),
      component_separators = {
        left = "│",
        right = "│"
      },
      section_separators = {
        left = "",
        right = ""
      }
    },
    sections = {
      lualine_a = {"mode"},
      lualine_b = {
        {
          "branch",
          icon = ""
        }
      },
      lualine_c = {
        {
          "filename",
          symbols = {
            modified = " +",
            readonly = "",
            unnamed = ""
          }
        }
      },
      lualine_x = {"endcoding"},
      lualine_y = {
        "fileformat",
        {
          "filetype",
          cond = function() return vim.bo.filetype ~= "dashboard" end
        }
      },
      lualine_z = {"location"},
    }
  }
end

M["tabline.nvim"] = function()
  require("tabline").setup {
    enable = true,
    options = {
      section_separators = {"", ""},
      component_separators = {"", ""},
      show_tabs_always = false,
      show_devicons = false,
      show_filename_only = true,
      show_tabs_only = true,
      modified_icon = "+ "
    }
  }
end

M["dashboard-nvim"] = function()
  dashboard = require("dashboard")
  dashboard.custom_header = {
    "               __                         ",
    "             / /\\                       ",
    "            / /  \\                      ",
    "           / /    \\__________           ",
    "         / /      \\        /\\         ",
    "         /_/        \\      / /          ",
    "    ___\\ \\      ___\\____/_/_        ",
    "   /____\\ \\    /___________/\\       ",
    "\\     \\ \\   \\           \\ \\   ",
    " \\     \\ \\   \\____       \\ \\  ",
    "  \\     \\ \\  /   /\\       \\ \\ ",
    "    \\   / \\_\\/   / /        \\ \\ ",
    "        \\ /        / /__________\\/    ",
    "         /        / /     /             ",
    "        /        / /     /              ",
    "       /________/ /\\    /              ",
    "    \\________\\/\\ \\  /            ",
    "                  \\_\\/               ",
    "", ""
  }

  dashboard.custom_center = {
    {icon = "* ", desc = "Find files", action = "Telescope find_files"},
    {icon = "* ", desc = "New file", action = "enew"},
  }
  dashboard.custom_footer = {"🙃"}
end

M["gitsigns.nvim"] = function()
  require("gitsigns").setup()
end

M["vim-better-whitespace"] = function()
  g.better_whitespace_enabled = true
  g.strip_whitespace_on_save = false
  g.better_whitespace_filetypes_blacklist = {"dashboard", "help", "markdown"}
end

M["indent-blankline.nvim"] = function()
  require("indent_blankline").setup {
    char = "│",
    filetype_exclude = {"dashboard", "help"},
    show_first_indent_level = false,
    show_trailing_blankline_indent = false
  }
end

M["virt-column.nvim"] = function()
  require("virt-column").setup()
end

M["LuaSnip"] = function()
  local snippets_dir = fn.fnamemodify(vim.call("resolve", fn.expand("<sfile>:p")), ":h") .. "/../snippets"
  require("luasnip.loaders.from_vscode").lazy_load({ paths = { snippets_dir } })
end

M["Navigator.nvim"] = function()
  require("Navigator").setup()
end

M["vim-pasta"] = function()
  g.pasta_disabled_filetypes = {}
end

M["smart-pairs"] = function()
  require('pairs'):setup {
    indent = {
      python = 1
    }
  }
end

M["nvim-comment"] = function()
  require("nvim_comment").setup()
end

return M
