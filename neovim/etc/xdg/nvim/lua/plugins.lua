local fn = vim.fn

local packer = require("packer")
local util = require("packer.util")

local script_directory = fn.fnamemodify(vim.call("resolve", fn.expand("<sfile>:p")), ":h")

packer.init {
    package_root = util.join_paths(script_directory, "pack"),
    compile_path = util.join_paths(script_directory, "plugin", "packer_compiled.lua"),
    display = {
      open_fn = require('packer.util').float,
    }
}

return packer.startup(function()
  local plugins_config = require("plugins_config")

  -- Packer.nvim
  use {"wbthomason/packer.nvim", lock = true}

  -- LSP
  use {
    "folke/trouble.nvim",
    cmd = "Trouble",
    config = plugins_config.trouble
  }
  use {
    "neovim/nvim-lspconfig",
    config = plugins_config.lspconfig
  }
  use {
    "kosayoda/nvim-lightbulb",
    config = plugins_config.lightbulb
  }
  use "ray-x/lsp_signature.nvim"

  -- Treesitter
  use {
    "romgrk/nvim-treesitter-context",
    config = plugins_config.treesitter_context
  }
  use {
    "nvim-treesitter/nvim-treesitter",
    -- run = ":TSUpdate",
    config = plugins_config.treesitter
  }
  use {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "0.5-compat"
  }

  -- Completion and searching
  use {
    "ervandew/supertab",
    config = plugins_config.supertab
  }
  use {
    "hrsh7th/nvim-compe",
    config = plugins_config.compe
  }
  use {
    "nvim-telescope/telescope.nvim",
    requires = {"nvim-lua/popup.nvim", "nvim-lua/plenary.nvim"},
    cmd = "Telescope",
    config = plugins_config.telescope
  }

  -- UI and display
  use {
    "navarasu/onedark.nvim",
    config = plugins_config.onedark
  }
  use {
    "itchyny/lightline.vim",
    config = plugins_config.lightline
  }
  use {
    "glepnir/dashboard-nvim",
    config = plugins_config.dashboard
  }
  use {
    "lewis6991/gitsigns.nvim",
    requires = {"nvim-lua/plenary.nvim"}
  }
  use {
    "machakann/vim-highlightedyank",
    event = "TextYankPost"
  }
  use {
    "ntpeters/vim-better-whitespace",
    config = plugins_config.better_whitespace
  }
  use {
    "lukas-reineke/indent-blankline.nvim",
    config = plugins_config.indent_blankline
  }

  -- Utilities
  use "tpope/vim-sleuth"
  use "Shougo/neosnippet.vim"
  use {
    "whiteinge/diffconflicts",
    cmd = "DiffConflicts"
  }
  use "Shougo/neosnippet-snippets"
  use {"Vimjas/vim-python-pep8-indent", ft = "python"}
  use {
    "christoomey/vim-tmux-navigator",
    cmd = {"TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight"},
    config = plugins_config.vim_tmux_navigator
  }

  -- Editing
  use "tpope/vim-repeat"
  use {
    "sickill/vim-pasta",
    config = plugins_config.vim_pasta
  }
  use "tpope/vim-surround"
  use "wellle/targets.vim"
  use "markonm/traces.vim"
  use {
    "foosoft/vim-argwrap",
    cmd = "ArgWrap"

  }
  use "tpope/vim-unimpaired"
  use "jiangmiao/auto-pairs"
  use "tpope/vim-commentary"
  use {
    "easymotion/vim-easymotion",
    keys = {{"n", "<Plug>(easymotion-prefix)"}, {"v", "<Plug>(easymotion-prefix)"}}
  }
  use "michaeljsmith/vim-indent-object"
end)
