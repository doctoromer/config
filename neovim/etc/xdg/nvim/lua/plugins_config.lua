local M = {}

local g = vim.g
local fn = vim.fn

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
    }
  },
  cmake = {}
}

M["legendary.nvim"] = function()
  legendary = require("legendary")
  legendary.setup()
  legendary.bind_keymaps(require("keymaps").other_keymaps())
end

M["nvim-lspconfig"] = function()
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
  require("treesitter-context.config").setup {enable = true}
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

M["nvim-treesitter-endwise"] = function()
  require("nvim-treesitter.configs").setup {
    endwise = {enable = true}
  }
end

M["nvim-cmp"] = function()
  local cmp = require("cmp")
  local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes(key, true, true, true),
      mode,
      true
    )
  end

  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  local tab = function(fallback)
    if cmp.visible() then
        cmp.select_next_item()
    elseif fn["vsnip#jumpable"](1) == 1 then
        feedkey("<Plug>(vsnip-jump-next)", "")
    elseif has_words_before() then
        cmp.complete()
    else
        fallback()
    end
  end

  local shift_tab = function()
    if cmp.visible() then
      cmp.select_prev_item()
    elseif fn["vsnip#jumpable"](-1) == 1 then
      feedkey("<Plug>(vsnip-jump-prev)", "")
    end
  end

  local c_space = function()
    if fn["vsnip#available"](1) == 1 or fn["vsnip#jumpable"](1) == 1 then
      feedkey("<Plug>(vsnip-expand-or-jump)", "")
    end
  end

  cmp.setup {
    snippet = {
      expand = function(args)
        fn["vsnip#anonymous"](args.body)
      end,
    },
    mapping = {
      ["<Tab>"] = cmp.mapping(tab, {"i", "s"}),
      ["<S-Tab>"] = cmp.mapping(shift_tab, {"i", "s"}),
      ["<C-space>"] = cmp.mapping(c_space, {"i", "s"}),
    },
    sources = cmp.config.sources(
      {{name = "vsnip"}, {name = "nvim_lsp"}, {name = "nvim_lsp_signature_help"}},
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

M["vim-vsnip"] = function()
  -- This sets the snippets dir to be relative to this file.
  -- Then, it is possible to use this in user's home directory or as a system wide configuration.
  g.vsnip_snippet_dir = fn.fnamemodify(vim.call("resolve", fn.expand("<sfile>:p")), ":h") .. "/../snippets"
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
