local function pasta_config()
    vim.g.pasta_disabled_filetypes = {}
end

local function autolist_config()
    local autolist = require("autolist")
    autolist.setup()

    autolist.create_mapping_hook("i", "<CR>", autolist.new)
    autolist.create_mapping_hook("i", "<Tab>", autolist.indent)
    autolist.create_mapping_hook("i", "<S-Tab>", autolist.indent, "<C-D>")
    autolist.create_mapping_hook("n", "o", autolist.new)
    autolist.create_mapping_hook("n", "O", autolist.new_before)
    autolist.create_mapping_hook("n", ">>", autolist.indent)
    autolist.create_mapping_hook("n", "<<", autolist.indent)
    autolist.create_mapping_hook("n", "<C-r>", autolist.force_recalculate)
    autolist.create_mapping_hook("n", "<leader>x", autolist.invert_entry, "")
end

return {
    "tpope/vim-repeat",
    { "sickill/vim-pasta", config = pasta_config },
    {
        "tpope/vim-surround",
        keys = { "ds", "cs", "cS", "ys", "yS", "yss", "ySs", "ySS", "S", "gS", "<C-S>", "<C-G>s", "<C-G>S" },
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
    { "gaoDean/autolist.nvim", config = autolist_config, ft = { "markdown", "text" } },
    { "easymotion/vim-easymotion" },
    { "michaeljsmith/vim-indent-object" },
    { "Julian/vim-textobj-variable-segment", dependencies = "kana/vim-textobj-user" },
}
