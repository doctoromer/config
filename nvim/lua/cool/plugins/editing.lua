local function pasta_config()
    vim.g.pasta_disabled_filetypes = {}
end

return {
    "tpope/vim-repeat",
    { "sickill/vim-pasta", config = pasta_config },
    {
        "kylechui/nvim-surround",
        config = true,
        keys = { "ds", "cs", "ys" },
    },
    "wellle/targets.vim",
    {
        "Wansmer/treesj",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = {
            use_default_keymaps = false,
            -- Practically disable max line length
            max_join_length = 1000,
        },
    },
    { "altermo/ultimate-autopair.nvim", event = "InsertEnter", config = true },
    {
        "terrortylor/nvim-comment",
        main = "nvim_comment",
        opts = { comment_empty = false },
    },
    { "smoka7/hop.nvim", opts = {} },
    { "michaeljsmith/vim-indent-object" },
    { "kana/vim-textobj-user" },
    { "Julian/vim-textobj-variable-segment", dependencies = "kana/vim-textobj-user" },
    { "gregorias/coerce.nvim", config = true },
}
