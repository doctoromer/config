local function treesitter_config()
    local parsers_dir = require("cool.options").nvim_root_dir
    vim.opt.runtimepath:prepend(parsers_dir)

    local default_parser = {
            "c",
            "cpp",
            "cmake",
            "python",
            "bash",
            "html",
            "java",
            "json",
            "lua",
            "vim",
            "regex",
            "toml",
            "vimdoc",
            -- used also for lspsaga hover feature
            "markdown",
            "markdown_inline",
        }

    require("nvim-treesitter.configs").setup({
        ensure_installed = vim.g.download_mode and default_parser or {},
        sync_install = true,
        auto_install = false,
        highlight = { enable = true },
        parser_install_dir = parsers_dir,
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

return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = function()
            local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
            ts_update()
        end,
        config = treesitter_config,
    },
    { "romgrk/nvim-treesitter-context", dependencies = "nvim-treesitter/nvim-treesitter", opts = { enable = true } },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = "nvim-treesitter/nvim-treesitter",
        event = "VeryLazy",
        main = "nvim-treesitter.configs",
        opts = {
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        af = "@function.outer",
                        ["if"] = "@function.inner",
                        ac = "@class.outer",
                        ic = "@class.inner",
                        il = "@loop.inner",
                        al = "@loop.outer",
                    },
                },
            },
        },
    },
    { "HiPhish/nvim-ts-rainbow2", main = "nvim-treesitter.configs", opts = { rainbow = { enable = true } } },
    { "windwp/nvim-ts-autotag", dependencies = "nvim-treesitter/nvim-treesitter", config = true, event = "VeryLazy" },
    { "David-Kunz/treesitter-unit", event = "VeryLazy" },
    {
        "RRethy/nvim-treesitter-endwise",
        dependencies = "nvim-treesitter/nvim-treesitter",
        event = "VeryLazy",
        main = "nvim-treesitter.configs",
        opts = {
            endwise = { enable = true },
        },
    },
    {
        "danymat/neogen",
        dependencies = "nvim-treesitter/nvim-treesitter",
        event = "VeryLazy",
        opts = {
            snippet_engine = "luasnip",
            languages = {
                python = {
                    template = { annotation_convention = "google_docstrings" },
                },
            },
        },
    },
}
