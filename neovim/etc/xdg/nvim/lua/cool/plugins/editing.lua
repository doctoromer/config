local function pasta_config()
    vim.g.pasta_disabled_filetypes = {}
end

return {
    "tpope/vim-repeat",
    { "sickill/vim-pasta", config = pasta_config },
    {
        "tpope/vim-surround",
        keys = {"ds", "cs", "cS", "ys", "yS", "yss", "ySs", "ySS", "S", "gS", "<C-S>", "<C-G>s", "<C-G>S"},
    },
    "wellle/targets.vim",
    {
        "Wansmer/treesj",
        event = "VeryLazy",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = {
            use_default_keymaps = false,
            -- Practically disable max line length
            max_join_length = 1000
        }
    },
    "tpope/vim-unimpaired",
    { "m4xshen/autoclose.nvim", event = "InsertEnter", config = true },
    {
        "terrortylor/nvim-comment",
        main = "nvim_comment",
        opts = { comment_empty = false },
        keys = {
            { "gc", mode = { "n", "o", "x" } },
            "gcc",
        }
    },
    { "gaoDean/autolist.nvim", config = true, event = "InsertEnter" },
    { "easymotion/vim-easymotion", event = "VeryLazy" },
    { "michaeljsmith/vim-indent-object", event = "VeryLazy" },
    { "Julian/vim-textobj-variable-segment", dependencies = "kana/vim-textobj-user", event = "VeryLazy" },
}
