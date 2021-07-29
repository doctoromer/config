fn = vim.fn

packer = require("packer")
util = require("packer.util")

local script_directory = fn.fnamemodify(vim.call("resolve", fn.expand("<sfile>:p")), ":h")

packer.init {
    package_root = util.join_paths(script_directory),
    compile_path = util.join_paths(script_directory, "plugin", "packer_compiled.lua")
}

return packer.startup(function()
  use {"dracula/vim"}
  use {"jiangmiao/auto-pairs"}
  use {"glepnir/dashboard-nvim"}
  use {"whiteinge/diffconflicts"}
  use {"lewis6991/gitsigns.nvim"}
  use {"lukas-reineke/indent-blankline.nvim"}
  use {"itchyny/lightline.vim"}
  use {"ray-x/lsp_signature.nvim"}
  use {"Shougo/neosnippet-snippets"}
  use {"Shougo/neosnippet.vim"}
  use {"hrsh7th/nvim-compe"}
  use {"kosayoda/nvim-lightbulb"}
  use {"neovim/nvim-lspconfig"}
  use {"nvim-treesitter/nvim-treesitter"}
  use {"romgrk/nvim-treesitter-context"}
  use {"navarasu/onedark.nvim"}
  use {"nvim-lua/plenary.nvim"}
  use {"nvim-lua/popup.nvim"}
  use {"ervandew/supertab"}
  use {"wellle/targets.vim"}
  use {"nvim-telescope/telescope.nvim"}
  use {"markonm/traces.vim"}
  use {"folke/trouble.nvim"}
  use {"foosoft/vim-argwrap"}
  use {"ntpeters/vim-better-whitespace"}
  use {"tpope/vim-commentary"}
  use {"easymotion/vim-easymotion"}
  use {"machakann/vim-highlightedyank"}
  use {"michaeljsmith/vim-indent-object"}
  use {"sickill/vim-pasta"}
  use {"Vimjas/vim-python-pep8-indent"}
  use {"tpope/vim-repeat"}
  use {"tpope/vim-sleuth"}
  use {"tpope/vim-surround"}
  use {"christoomey/vim-tmux-navigator"}
  use {"tpope/vim-unimpaired"}
end)
