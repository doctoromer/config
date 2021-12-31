local M = {}

local g = vim.g
local fn = vim.fn

local language_servers = {
  pylsp = {
    init_options = {documentFormatting = false}
  },
  clangd = {},
  cmake = {}
}

M["which-key.nvim"] = function(which_key)
  which_key.setup()
end

M["nvim-lspconfig"] = function(lspconfig)
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {virtual_text = false}
  )

  for server_name, config in pairs(language_servers) do
      lspconfig[server_name].setup(config)
  end

end

M["lspsaga.nvim"] = function(saga)
  saga.init_lsp_saga {
    finder_action_keys = {
      vsplit = "v", split = "s", quit = {"q", "<esc>", "<C-c>"}, open = "<CR>"
    }
  }
end

M["lsp_signature.nvim"] = function(lsp_signature)
  lsp_signature.setup()
end

M["formatter.nvim"] = function(formatter)
  formatters = {}

  -- if fn.executable("clang-format") == 1 then
  --   formatters.c = {
  --    function()
  --       return {
  --         exe = "clang-format",
  --         args = {"--assume-filename", vim.api.nvim_buf_get_name(0)},
  --         stdin = true,
  --         cwd = fn.expand('%:p:h')
  --       }
  --     end
  --   }
  -- end

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

  formatter.setup({filetype = formatters})
end

M["nvim-treesitter-context"] = function(treesitter_context)
  treesitter_context.setup {enable = true}
end

M["nvim-treesitter"] = function(treesitter_config)
  treesitter_config.setup {
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
    ignore_install = {},
    highlight = {enable = true},
    rainbow = {
      enable = true,
      extended_mode = true,
      max_file_lines = nil,
    },
    autotag = {enable = true},
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

M["nvim-treesitter-textobjects"] = function(treesitter_config)
  treesitter_config.setup {
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

M["nvim-cmp"] = function(cmp, cmp_nvim_lsp)

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
    elseif fn["vsnip#available"](1) == 1 then
        feedkey("<Plug>(vsnip-expand-or-jump)", "")
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

  cmp.setup {
    snippet = {
      expand = function(args)
        fn["vsnip#anonymous"](args.body)
      end,
    },
    mapping = {
      ["<Tab>"] = cmp.mapping(tab, {"i", "s"}),
      ["<S-Tab>"] = cmp.mapping(shift_tab, {"i", "s"}),
      ["<CR>"] = cmp.mapping.confirm(
        {behavior = cmp.ConfirmBehavior.Replace, select = true},
        {"i", "s"}
      ),
    },
    sources = cmp.config.sources(
      {{name = "vsnip"}, {name = "nvim_lsp"}},
      {{name = "buffer"}}
    )
  }

  cmp.setup.cmdline("/", {sources = {{name = "buffer"}}})
  cmp.setup.cmdline("?", {sources = {{name = "buffer"}}})
  cmp.setup.cmdline(":", {
    sources = cmp.config.sources({{name = "path"}}, {{name = "cmdline"}})
  })

  -- setup lspconfig
  local capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())
  -- Replace <YOUR_LSP_SERVER> with each lsp server you"ve enabled.
  for server_name, _ in pairs(language_servers) do
    require("lspconfig")[server_name].setup {
      capabilities = capabilities
    }
  end
end

M["telescope.nvim"] = function(telescope, actions)
  telescope.setup {
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
  g.onedark_style = "darker"
  vim.cmd "colorscheme onedark"
end

M["lightline.vim"] = function()
  g.lightline = {colorscheme = "one"}
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

M["gitsigns.nvim"] = function(gitsigns)
  gitsigns.setup()
end

M["vim-better-whitespace"] = function()
  g.better_whitespace_enabled = true
  g.strip_whitespace_on_save = false
  g.better_whitespace_filetypes_blacklist = {"dashboard", "help", "markdown"}
end

M["indent-blankline.nvim"] = function()
  g.indentLine_fileTypeExclude = {"dashboard", "help"}
  g.indent_blankline_use_treesitter = true
  g.indent_blankline_show_first_indent_level = false
  g.indentLine_char = "│"
end

M["virt-column.nvim"] = function(virt_column)
  virt_column.setup()
end

M["vim-vsnip"] = function()
  -- This sets the snippets dir to be relative to this file.
  -- Then, it is possible to use this in user's home directory or as a system wide configuration.
  g.vsnip_snippet_dir = fn.fnamemodify(vim.call("resolve", fn.expand("<sfile>:p")), ":h") .. "/../snippets"
end

M["Navigator.nvim"] = function(navigator)
  navigator.setup()
end

M["vim-pasta"] = function()
  g.pasta_disabled_filetypes = {}
end

M["nvim-comment"] = function(comment)
  comment.setup()
end

return M
