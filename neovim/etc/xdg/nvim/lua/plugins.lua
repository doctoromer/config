local packer = require("packer")
local util = require("packer.util")
local plugin_manager = require("plugin_manager")
local config = require("config")

-- This makes the plugins to work in user's home directory, system wide directory or as symlinked files.
packer.init({
    package_root = util.join_paths(config.nvim_root_dir, "pack"),
    compile_path = util.join_paths(config.nvim_root_dir, "plugin", "packer_compiled.lua"),
    display = {
        open_fn = require("packer.util").float,
    },
})

plugin_manager.setup({
    keymaps_functions = require("keymaps"),
    plugins_config = require("plugins_config"),
})

return packer.startup(plugin_manager.make_config({
    -- Base plugins
    { "wbthomason/packer.nvim", lock = true, config = false },
    { "mrjones2014/legendary.nvim", requires = "stevearc/dressing.nvim" },

    -- LSP
    { "williamboman/mason.nvim", requires = "williamboman/mason-lspconfig.nvim" },
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    { "neovim/nvim-lspconfig", keys = false, requires = { "williamboman/mason.nvim", "hrsh7th/cmp-nvim-lsp" } },
    { "glepnir/lspsaga.nvim", requires = "neovim/nvim-lspconfig" },

    { "mhartington/formatter.nvim", cmd = { "Format", "FormatWrite" } },

    -- Treesitter
    "nvim-treesitter/nvim-treesitter",
    {"romgrk/nvim-treesitter-context", requires = "nvim-treesitter/nvim-treesitter"},
    {"p00f/nvim-ts-rainbow", requires = "nvim-treesitter/nvim-treesitter"},
    {"nvim-treesitter/nvim-treesitter-textobjects", requires = "nvim-treesitter/nvim-treesitter"},
    {"windwp/nvim-ts-autotag", requires = "nvim-treesitter/nvim-treesitter"},
    { "David-Kunz/treesitter-unit", keys = false },
    {"RRethy/nvim-treesitter-endwise", requires = "nvim-treesitter/nvim-treesitter"},
    { "danymat/neogen", requires = "nvim-treesitter/nvim-treesitter" },

    -- Completion and searching
    {
        "hrsh7th/nvim-cmp",
        keys = false,
        requires = {
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "neovim/nvim-lspconfig",
            { "saadparwaiz1/cmp_luasnip", require = "L3MON4D3/LuaSnip" },
        },
    },
    {
        "nvim-telescope/telescope.nvim",
        requires = { "nvim-lua/popup.nvim", "nvim-lua/plenary.nvim" },
        ft = "dashboard",
    },
    { "nvim-telescope/telescope-fzf-native.nvim", after = "telescope.nvim", run = "make" },

    -- UI and display
    "navarasu/onedark.nvim",
    "nvim-lualine/lualine.nvim",
    "nanozuki/tabby.nvim",
    "glepnir/dashboard-nvim",
    { "lewis6991/gitsigns.nvim", keys = false, requires = "nvim-lua/plenary.nvim" },
    { "machakann/vim-highlightedyank", event = "TextYankPost" },
    "ntpeters/vim-better-whitespace",
    "lukas-reineke/indent-blankline.nvim",
    "lukas-reineke/virt-column.nvim",

    -- Utilities
    "tpope/vim-sleuth",
    { "L3MON4D3/LuaSnip", keys = false },
    { "sindrets/diffview.nvim", cmd = "DiffviewOpen", requires = "nvim-lua/plenary.nvim" },
    { "Vimjas/vim-python-pep8-indent", ft = "python" },
    "numToStr/Navigator.nvim",

    -- Editing
    "tpope/vim-repeat",
    "sickill/vim-pasta",
    {
        "tpope/vim-surround",
        keys = {
            { "n", "ds" },
            { "n", "cs" },
            { "n", "cS" },
            { "n", "ys" },
            { "n", "yS" },
            { "n", "yss" },
            { "n", "ySs" },
            { "n", "ySS" },
            { "x", "S" },
            { "x", "gS" },
            { "i", "<C-S>" },
            { "i", "<C-G>s" },
            { "i", "<C-G>S" },
        },
    },
    "wellle/targets.vim",
    "foosoft/vim-argwrap",
    "tpope/vim-unimpaired",
    { "ZhiyuanLck/smart-pairs", event = "InsertEnter" },
    {
        "terrortylor/nvim-comment",
        keys = {
            { "x", "gc" },
            { "n", "gc" },
            { "o", "gc" },
            { "n", "gcc" },
            { "n", "cgc" },
            { "n", "gcu" },
        },
    },
    "gaoDean/autolist.nvim",
    "easymotion/vim-easymotion",
    "michaeljsmith/vim-indent-object",
    { "Julian/vim-textobj-variable-segment", requires = "kana/vim-textobj-user" },
}))
