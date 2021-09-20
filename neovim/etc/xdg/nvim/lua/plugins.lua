local fn = vim.fn

local packer = require("packer")
local util = require("packer.util")

local script_directory = fn.fnamemodify(vim.call("resolve", fn.expand("<sfile>:p")), ":h")

-- This makes the plugins to work in user's home directory, system wide directory or as symlinked files.
packer.init {
    package_root = util.join_paths(script_directory, "pack"),
    compile_path = util.join_paths(script_directory, "plugin", "packer_compiled.lua"),
    display = {
      open_fn = require("packer.util").float
    }
}

return packer.startup(function()
  local plugins_config = require("plugins_config")

  -- Packer.nvim
  use {"wbthomason/packer.nvim", lock = true}

  -- LSP
  use {"neovim/nvim-lspconfig", config = plugins_config.lspconfig}
  use {"kosayoda/nvim-lightbulb", config = plugins_config.lightbulb}
  use "ray-x/lsp_signature.nvim"

  -- Treesitter
  use {"romgrk/nvim-treesitter-context", config = plugins_config.treesitter_context}
  use {"nvim-treesitter/nvim-treesitter", config = plugins_config.treesitter}
  use {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "0.5-compat",
    config = plugins_config.treesitter_textobjects
  }

  -- Completion and searching
  use {"ervandew/supertab", config = plugins_config.supertab}
  use {"hrsh7th/nvim-compe", config = plugins_config.compe}
  use {
    "nvim-telescope/telescope.nvim",
    requires = {"nvim-lua/popup.nvim", "nvim-lua/plenary.nvim"},
    cmd = "Telescope",
    config = plugins_config.telescope
  }

  -- UI and display
  use {"navarasu/onedark.nvim", config = plugins_config.onedark}
  use {"itchyny/lightline.vim", config = plugins_config.lightline}
  use {"glepnir/dashboard-nvim", config = plugins_config.dashboard}
  use {
    "lewis6991/gitsigns.nvim",
    requires = {"nvim-lua/plenary.nvim"},
    config = plugins_config.gitsigns
  }
  use {"tpope/vim-fugitive", cmd = "Git"}
  use {"machakann/vim-highlightedyank", event = "TextYankPost"}
  use {"ntpeters/vim-better-whitespace", config = plugins_config.better_whitespace}
  use {"lukas-reineke/indent-blankline.nvim", config = plugins_config.indent_blankline}

  -- Debugging
  use {"mfussenegger/nvim-dap", config = plugins_config.nvim_dap}
  use {"rcarriga/nvim-dap-ui", config = plugins_config.nvim_dap_ui}

  -- Utilities
  use "tpope/vim-sleuth"
  use {"hrsh7th/vim-vsnip", config = plugins_config.vsnip}
  use {"whiteinge/diffconflicts", cmd = "DiffConflicts"}
  use {"Vimjas/vim-python-pep8-indent", ft = "python"}
  use {
    "christoomey/vim-tmux-navigator",
    cmd = {"TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight"},
    config = plugins_config.vim_tmux_navigator
  }

  -- Editing
  use "tpope/vim-repeat"
  use {"sickill/vim-pasta", config = plugins_config.vim_pasta}
  use {
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
  }
  use "wellle/targets.vim"
  use "markonm/traces.vim"
  use {"foosoft/vim-argwrap", cmd = "ArgWrap"}
  use "tpope/vim-unimpaired"
  use "jiangmiao/auto-pairs"
  use {
    "terrortylor/nvim-comment",
    keys = {
      {"x", "gc"},
      {"n", "gc"},
      {"o", "gc"},
      {"n", "gcc"},
      {"n", "cgc"},
      {"n", "gcu"}
    },
    config = plugins_config.comment
  }
  use {
    "easymotion/vim-easymotion",
    keys = {{"n", "<Plug>(easymotion-prefix)"}, {"v", "<Plug>(easymotion-prefix)"}}
  }
  use "michaeljsmith/vim-indent-object"
  use {
    "folke/which-key.nvim",
    config = plugins_config.which_key
  }
end)
