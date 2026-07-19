local function treesitter_config()
    local parsers_dir = require("cool.utils").download_dir
    local queries_dir = require("nvim-treesitter.install").get_package_path("runtime")
    vim.opt.runtimepath:prepend(parsers_dir)
    vim.opt.runtimepath:prepend(queries_dir)

    require("nvim-treesitter.config").setup({
        install_dir = parsers_dir,
    })

    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            pcall(vim.treesitter.start)
        end,
    })

    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
end

local function textobjects_setup()
    local select = require("nvim-treesitter-textobjects.select")
    local mode = { "x", "o" }
    vim.keymap.set(mode, "af", function()
        select.select_textobject("@function.outer", "textobjects")
    end)
    vim.keymap.set(mode, "if", function()
        select.select_textobject("@function.inner", "textobjects")
    end)
    vim.keymap.set(mode, "ac", function()
        select.select_textobject("@class.outer", "textobjects")
    end)
    vim.keymap.set(mode, "ic", function()
        select.select_textobject("@class.inner", "textobjects")
    end)
    vim.keymap.set(mode, "al", function()
        select.select_textobject("@loop.outer", "textobjects")
    end)
    vim.keymap.set(mode, "il", function()
        select.select_textobject("@loop.inner", "textobjects")
    end)
end

return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = function()
            local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
            ts_update()
        end,
        branch = "main",
        config = treesitter_config,
    },
    {
        "romgrk/nvim-treesitter-context",
        dependencies = "nvim-treesitter/nvim-treesitter",
        opts = { enable = false },
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = "nvim-treesitter/nvim-treesitter",
        main = "nvim-treesitter-textobjects",
        opts = {
            select = {
                enable = true,
                lookahead = true,
            },
        },
        config = function(_, opts)
            require("nvim-treesitter-textobjects").setup(opts)
            textobjects_setup()
        end,
    },
    { "HiPhish/rainbow-delimiters.nvim" },
    {
        "windwp/nvim-ts-autotag",
        dependencies = "nvim-treesitter/nvim-treesitter",
        config = true,
        ft = { "html", "javascript", "vue", "xml", "markdown" },
    },
    { "David-Kunz/treesitter-unit" },
    {
        "RRethy/nvim-treesitter-endwise",
        ft = { "python", "lua", "sh", "bash" },
    },
    {
        "danymat/neogen",
        dependencies = "nvim-treesitter/nvim-treesitter",
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
