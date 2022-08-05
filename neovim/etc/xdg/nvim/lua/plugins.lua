local fn = vim.fn

local packer = require("packer")
local util = require("packer.util")
local plugin_manager = require("plugin_manager")

local script_directory = fn.fnamemodify(vim.call("resolve", fn.expand("<sfile>:p")), ":h")

-- This makes the plugins to work in user's home directory, system wide directory or as symlinked files.
packer.init {
    package_root = util.join_paths(script_directory, "pack"),
    compile_path = util.join_paths(script_directory, "plugin", "packer_compiled.lua"),
    display = {
      open_fn = require("packer.util").float
    }
}

local plugin_manager = require("plugin_manager")
plugin_manager.setup {
  keymaps_functions = require("keymaps"),
  plugins_config = require("plugins_config"),
}

return packer.startup(plugin_manager.make_config {
  -- Base plugins
  {"wbthomason/packer.nvim", lock = true, config = false},
  {"mrjones2014/legendary.nvim", requires = "stevearc/dressing.nvim"},

  -- LSP
  {"neovim/nvim-lspconfig", keys = false},
  {"tami5/lspsaga.nvim", requires = "neovim/nvim-lspconfig"},

  {"mhartington/formatter.nvim", cmd = {"Format", "FormatWrite"}},

  -- Treesitter
  "nvim-treesitter/nvim-treesitter",
  "romgrk/nvim-treesitter-context",
  "p00f/nvim-ts-rainbow",
  "nvim-treesitter/nvim-treesitter-textobjects",
  "windwp/nvim-ts-autotag",
  {"David-Kunz/treesitter-unit", keys = false},
  "RRethy/nvim-treesitter-endwise",

  -- Completion and searching
  {
    "hrsh7th/nvim-cmp",
    requires = {
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "neovim/nvim-lspconfig",
      {"hrsh7th/cmp-vsnip", requires = "hrsh7th/vim-vsnip"}
    }
  },
  {
    "nvim-telescope/telescope.nvim",
    requires = {"nvim-lua/popup.nvim", "nvim-lua/plenary.nvim"},
    ft = "dashboard",
  },
  {"nvim-telescope/telescope-fzf-native.nvim", after = "telescope.nvim", run = "make"},

  -- UI and display
  "navarasu/onedark.nvim",
  "nvim-lualine/lualine.nvim",
  {"kdheepak/tabline.nvim"},
  "glepnir/dashboard-nvim",
  {"lewis6991/gitsigns.nvim", requires = "nvim-lua/plenary.nvim"},
  {"machakann/vim-highlightedyank", event = "TextYankPost"},
  "ntpeters/vim-better-whitespace",
  "lukas-reineke/indent-blankline.nvim",
  "lukas-reineke/virt-column.nvim",

  -- Utilities
  "tpope/vim-sleuth",
  "hrsh7th/vim-vsnip",
  {"whiteinge/diffconflicts", cmd = "DiffConflicts"},
  {"Vimjas/vim-python-pep8-indent", ft = "python"},
  "numToStr/Navigator.nvim",

  -- Editing
  "tpope/vim-repeat",
  "sickill/vim-pasta",
  {
    "tpope/vim-surround",
    keys = {
      {"n", "ds"},
      {"n", "cs"},
      {"n", "cS"},
      {"n", "ys"},
      {"n", "yS"},
      {"n", "yss"},
      {"n", "ySs"},
      {"n", "ySS"},
      {"x", "S"},
      {"x", "gS"},
      {"i", "<C-S>"},
      {"i", "<C-G>s"},
      {"i", "<C-G>S"}
    }
  },
  "wellle/targets.vim",
  "foosoft/vim-argwrap",
  "tpope/vim-unimpaired",
  {"ZhiyuanLck/smart-pairs", event = 'InsertEnter'},
  {
    "terrortylor/nvim-comment",
    keys = {
      {"x", "gc"},
      {"n", "gc"},
      {"o", "gc"},
      {"n", "gcc"},
      {"n", "cgc"},
      {"n", "gcu"}
    },
  },
  "easymotion/vim-easymotion",
  "michaeljsmith/vim-indent-object",
  {"Julian/vim-textobj-variable-segment", requires = "kana/vim-textobj-user"}
})
