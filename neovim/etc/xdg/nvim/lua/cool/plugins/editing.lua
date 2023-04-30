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
    "foosoft/vim-argwrap",
    "tpope/vim-unimpaired",
    { "m4xshen/autoclose.nvim", event = "InsertEnter", config = true },
    {
        "terrortylor/nvim-comment",
        main = "nvim_comment",
        opts = {
            comment_empty = false,
        },
        keys = {
            { "gc", mode = { "n", "o", "x" } },
            "gcc",
        }
    },
    { "gaoDean/autolist.nvim", config = true },
    "easymotion/vim-easymotion",
    "michaeljsmith/vim-indent-object",
    { "Julian/vim-textobj-variable-segment", dependencies = "kana/vim-textobj-user" },
}
