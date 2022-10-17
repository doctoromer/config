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
            init_options = { documentFormatting = false },
        },
        clangd = {
            cmd = {
                (function()
                    clangd_names = { "clangd", "clangd-12", "clangd-11", "clangd-10", "clangd-9" }
                    for _, x in ipairs(clangd_names) do
                        if fn.executable(x) == 1 then
                            return x
                        end
                    end
                end)(),
            },
        },
        cmake = {},
        zls = {},
    }

    vim.lsp.handlers["textDocument/publishDiagnostics"] =
        vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    for server_name, config in pairs(language_servers) do
        config.capabilities = capabilities
        require("lspconfig")[server_name].setup(config)
    end
end

M["lspsaga.nvim"] = function()
    local colors = require("lspsaga.lspkind").colors
    require("lspsaga").init_lsp_saga({
        move_in_saga = { prev = "<C-u>", next = "<C-d>" },
        finder_icons = {
            def = "⌘ ",
            ref = "➜ ",
            link = "➤ "
        },
        finder_action_keys = {
            vsplit = "v",
            split = "s",
            quit = { "q", "<esc>", "<C-c>" },
            open = "<CR>",
        },
        custom_kind = {
            File = { "π ", colors.fg },
            Module = { "δ ", colors.blue },
            Namespace = { "ν ", colors.orange },
            Package = { "Π ", colors.violet },
            Class = { "κ ", colors.violet },
            Method = { "μ ", colors.violet },
            Property = { "ρ ", colors.cyan },
            Field = { "λ ", colors.teal },
            Constructor = { "ξ ", colors.blue },
            Enum = { "ε ", colors.green },
            Interface = { "ι ", colors.orange },
            Function = { "Φ ", colors.violet },
            Variable = { "Ω ", colors.blue },
            Constant = { "Σ ", colors.cyan },
            String = { "σ ", colors.green },
            Number = { "ν ", colors.green },
            Boolean = { "β ", colors.orange },
            Array = { "α ", colors.blue },
            Object = { "ω ", colors.orange },
            Key = { "υ ", colors.red },
            Null = { "Θ ", colors.red },
            EnumMember = { "ζ ", colors.green },
            Struct = { "ς ", colors.violet },
            Event = { "Δ ", colors.violet },
            Operator = { "ψ ", colors.green },
            TypeParameter = { "Ξ ", colors.green },
            TypeAlias = { "δ ", colors.green },
            Parameter = { "γ ", colors.blue },
            StaticMethod = { "θ ", colors.orange },
            Macro = { "η ", colors.red },
        }
    })
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
                        fn.fnameescape(vim.api.nvim_buf_get_name(0)),
                    },
                    stdin = false,
                }
            end,
        }
    end

    require("formatter").setup({ filetype = formatters })
end

M["nvim-treesitter"] = function()
    require("nvim-treesitter.configs").setup({
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
            "toml",
        },
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
    })
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
end

M["nvim-treesitter-context"] = function()
    require("treesitter-context").setup({ enable = true })
end

M["nvim-ts-rainbow"] = function()
    require("nvim-treesitter.configs").setup({
        rainbow = {
            enable = true,
            extended_mode = true,
            max_file_lines = nil,
        },
    })
end

M["nvim-treesitter-textobjects"] = function()
    require("nvim-treesitter.configs").setup({
        textobjects = {
            select = {
                enable = true,
                lookahead = true,
                keymaps = {
                    af = "@function.outer",
                    ["if"] = "@function.inner",
                    ac = "@class.outer",
                    ic = "@class.inner",
                },
            },
        },
    })
end

M["nvim-ts-autotag"] = function()
    require("nvim-treesitter.configs").setup({
        autotag = { enable = true },
    })
end

M["neogen"] = function()
    require("neogen").setup({})
end

M["nvim-treesitter-endwise"] = function()
    require("nvim-treesitter.configs").setup({
        endwise = { enable = true },
    })
end

M["nvim-cmp"] = function()
    local cmp = require("cmp")

    cmp.setup({
        snippet = {
            expand = function(args)
                require("luasnip").lsp_expand(args.body)
            end,
        },
        sources = cmp.config.sources(
            { { name = "luasnip" }, { name = "nvim_lsp" }, { name = "nvim_lsp_signature_help" } },
            { { name = "buffer" } },
            { { name = "path" } }
        ),
    })

    cmp.setup.cmdline("/", { sources = { { name = "buffer" } } })
    cmp.setup.cmdline("?", { sources = { { name = "buffer" } } })
    cmp.setup.cmdline(":", { sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }) })
end

M["telescope.nvim"] = function()
    local actions = require("telescope.actions")
    require("telescope").setup({
        defaults = {
            vimgrep_arguments = {
                "ag",
                "--nocolor",
                "--noheading",
                "--filename",
                "--numbers",
                "--column",
                "--smart-case",
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
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
                },
            },
        },
    })
end

M["onedark.nvim"] = function()
    require("onedark").setup({
        style = "darker",
    })
    vim.cmd("colorscheme onedark")
end

M["lualine.nvim"] = function()
    require("lualine").setup({
        options = {
            theme = require("lualine.themes.onedark"),
            component_separators = {
                left = "│",
                right = "│",
            },
            section_separators = {
                left = "",
                right = "",
            },
        },
        sections = {
            lualine_a = { "mode" },
            lualine_b = {
                {
                    "branch",
                    icon = "",
                },
            },
            lualine_c = {
                {
                    "filename",
                    symbols = {
                        modified = " +",
                        readonly = "",
                        unnamed = "",
                    },
                },
            },
            lualine_x = { "endcoding" },
            lualine_y = {
                "fileformat",
                {
                    "filetype",
                    cond = function()
                        return vim.bo.filetype ~= "dashboard"
                    end,
                },
            },
            lualine_z = { "location" },
        },
    })
end

M["tabby.nvim"] = function()
    local lualine_theme = require("lualine.themes.onedark")
    local mode_theme = {
        n = lualine_theme.normal.a,
        c = lualine_theme.command.a,
        i = lualine_theme.insert.a,

        v = lualine_theme.visual.a,
        V = lualine_theme.visual.a,
        ["CTRL-V"] = lualine_theme.visual.a,

        t = lualine_theme.terminal.a,
        R = lualine_theme.replace.a,
    }
    local inactive_theme = lualine_theme.inactive.a

    -- This makes the tabline update when changing modes (not including visual modes)
    vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave", "InsertEnter", "InsertLeave", "CursorHold" }, {
        callback = function()
            vim.cmd("redrawtabline")
        end,
    })

    -- Renders one tab label from tabby's tab object
    local function tab_render(tab)
        local hl = tab.is_current() and mode_theme[fn.mode()] or inactive_theme
        local modified = vim.api.nvim_buf_get_option(tab.current_win().buf().id, "modified") and " +" or ""
        return {
            " ",
            tab.name(),
            modified,
            " ",
            hl = hl,
        }
    end

    -- Renders one dindow label from tabby's window object
    local function window_render(window)
        local hl = window.is_current() and mode_theme[fn.mode()] or inactive_theme
        return { " ", window.buf_name(), " ", hl = hl }
    end

    -- Renders the entire tabline from tabby's line object
    local function tabline_render(line)
        return {
            line.tabs().foreach(tab_render),
            line.spacer(),
            line.wins_in_tab(line.api.get_current_tab()).foreach(window_render),
            hl = "TabLineFill",
        }
    end

    -- Renders the label's name string from neovim's tab_id
    local function tab_label_render(tab_id)
        local current_window = vim.api.nvim_tabpage_get_win(tab_id)
        if vim.api.nvim_win_get_config(current_window).relative ~= "" then
            return "[Floating]"
        else
            return require("tabby.feature.buf_name").get(current_window)
        end
        return name
    end

    require("tabby.tabline").set(
        tabline_render,
        { tab_name = { name_fallback = tab_label_render }, buf_name = { mode = "unique" } }
    )
end

M["dashboard-nvim"] = function()
    dashboard = require("dashboard")

    ascii_art = require("ascii_art")
    if vim.env.NVIM_RANDOM_DASHBOARD_ASCII_ART then
        math.randomseed(os.time())
        dashboard.custom_header = ascii_art[math.random(#ascii_art)]
    else
        dashboard.custom_header = ascii_art[1]
    end

    dashboard.custom_center = {
        { icon = "* ", desc = "Find files", action = "Telescope find_files" },
        { icon = "* ", desc = "New file", action = "enew" },
    }
    dashboard.custom_footer = { "🙃" }
end

M["gitsigns.nvim"] = function()
    require("gitsigns").setup()
end

M["vim-better-whitespace"] = function()
    g.better_whitespace_enabled = true
    g.strip_whitespace_on_save = false
    g.better_whitespace_filetypes_blacklist = { "dashboard", "help", "markdown" }
end

M["indent-blankline.nvim"] = function()
    require("indent_blankline").setup({
        char = "│",
        filetype_exclude = { "dashboard", "help" },
        show_first_indent_level = false,
        show_trailing_blankline_indent = false,
    })
end

M["virt-column.nvim"] = function()
    require("virt-column").setup()
end

M["LuaSnip"] = function()
    local snippets_dir = fn.fnamemodify(vim.call("resolve", fn.expand("<sfile>:p")), ":h") .. "/../snippets"
    require("luasnip.loaders.from_vscode").lazy_load({ paths = { snippets_dir } })
end

M["diffview.nvim"] = function()
    require("diffview").setup({
        use_icons = false,
    })
end

M["Navigator.nvim"] = function()
    require("Navigator").setup()
end

M["vim-pasta"] = function()
    g.pasta_disabled_filetypes = {}
end

M["smart-pairs"] = function()
    require("pairs"):setup({
        indent = {
            python = 1,
        },
    })
end

M["nvim-comment"] = function()
    require("nvim_comment").setup({
        comment_empty = false,
    })
end

M["autolist.nvim"] = function()
    require("autolist").setup({})
end

return M
