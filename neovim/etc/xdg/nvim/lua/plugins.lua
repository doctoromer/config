fn = vim.fn

packer = require("packer")
util = require("packer.util")

local script_directory = fn.fnamemodify(vim.call("resolve", fn.expand("<sfile>:p")), ":h")

packer.init {
    package_root = util.join_paths(script_directory, "pack"),
    compile_path = util.join_paths(script_directory, "plugin", "packer_compiled.lua"),
    display = {
      open_fn = require('packer.util').float,
    }
}

return packer.startup(function()
  -- Packer.nvim
  use "wbthomason/packer.nvim"

  -- LSP
  use "folke/trouble.nvim"
  use "neovim/nvim-lspconfig"
  use "kosayoda/nvim-lightbulb"
  use "ray-x/lsp_signature.nvim"

  -- Treesitter
  use "romgrk/nvim-treesitter-context"
  use {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate"}

  -- Completion and searching
  use "ervandew/supertab"
  use "hrsh7th/nvim-compe"
  use {
    "nvim-telescope/telescope.nvim",
    requires = {"nvim-lua/popup.nvim", "nvim-lua/plenary.nvim"}
  }

  -- UI and display
  use "navarasu/onedark.nvim"
  use "itchyny/lightline.vim"
  use "glepnir/dashboard-nvim"
  use {"lewis6991/gitsigns.nvim", requires = {"nvim-lua/plenary.nvim"}}
  use "machakann/vim-highlightedyank"
  use "ntpeters/vim-better-whitespace"
  use "lukas-reineke/indent-blankline.nvim"

  -- Utilities
  use "tpope/vim-sleuth"
  use "Shougo/neosnippet.vim"
  use "whiteinge/diffconflicts"
  use "Shougo/neosnippet-snippets"
  use "Vimjas/vim-python-pep8-indent"
  use "christoomey/vim-tmux-navigator"

  -- Editing
  use "tpope/vim-repeat"
  use "sickill/vim-pasta"
  use "tpope/vim-surround"
  use "wellle/targets.vim"
  use "markonm/traces.vim"
  use "foosoft/vim-argwrap"
  use "tpope/vim-unimpaired"
  use "jiangmiao/auto-pairs"
  use "tpope/vim-commentary"
  use "easymotion/vim-easymotion"
  use "michaeljsmith/vim-indent-object"
end)
