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

modules_names = {
  ["telescope.nvim"] = {keybind = "telescope.builtin", config = {"telescope", "telescope.actions"}},
  ["Navigator.nvim"] = {keybind = "Navigator", config = {"Navigator"}},
  ["nvim-treesitter"] = {config = {"nvim-treesitter.configs"}},
  ["nvim-lspconfig"] = {config = {"lspconfig"}},
  ["nvim-compe"] = {config = {"compe"}},
  ["nvim-treesitter-context"] = {config = {"treesitter-context.config"}},
  ["lsp_signature.nvim"] = {config = {"lsp_signature"}},
  ["gitsigns.nvim"] = {config = {"gitsigns"}},
  ["nvim-treesitter-textobjects"] = {config = {"nvim-treesitter.configs"}},
  ["which-key.nvim"] = {config = {"which-key"}},
  ["nvim-comment"] = {config = {"nvim_comment"}},
}

function require_plugin_modules(plugin_name, modules_type)
  plugin_spec = modules_names[plugin_name] or {}
  require_data = plugin_spec[modules_type] or {}

  if type(require_data) == "string" then
    require_data = {require_data}
  elseif type(require_data) ~= "table" then
    error("Invalid require table data type: " .. type(require_data))
  end

  result = {}
  for i, module_name in ipairs(require_data) do
    result[i] = require(module_name)
  end

  return result
end

local function call_config_and_keybinds(name)
  local keybind = require("keybind")
  local which_key = require("which-key")
  local plugins_config = require("plugins_config")

  if keybind[name] then
    modules = require_plugin_modules(name, "keybind")
    keybind_result = keybind[name](unpack(modules))

    if keybind_result[1] and keybind_result[2] then
      which_key.register(keybind_result[1], keybind_result[2])
    else
      which_key.register(keybind_result)
    end
  end

  if plugins_config[name] then
    modules = require_plugin_modules(name, "config")
    plugins_config[name](unpack(modules))
  end
end


return packer.startup(function()
  local plugins_config = require("plugins_config")

  -- Packer.nvim
  use {"wbthomason/packer.nvim", lock = true}

  -- LSP
  use {
    "neovim/nvim-lspconfig",
    config = call_config_and_keybinds
  }
  use {"ray-x/lsp_signature.nvim", config = call_config_and_keybinds}

  -- Treesitter
  use {"romgrk/nvim-treesitter-context", config = call_config_and_keybinds}
  use {"nvim-treesitter/nvim-treesitter", config = call_config_and_keybinds}
  use {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "0.5-compat",
    config = call_config_and_keybinds
  }

  -- Completion and searching
  use {"hrsh7th/nvim-compe", config = call_config_and_keybinds}
  use {
    "nvim-telescope/telescope.nvim",
    requires = {"nvim-lua/popup.nvim", "nvim-lua/plenary.nvim"},
    config = call_config_and_keybinds
  }

  -- UI and display
  use {"navarasu/onedark.nvim", config = call_config_and_keybinds}
  use {"itchyny/lightline.vim", config = call_config_and_keybinds}
  use {"glepnir/dashboard-nvim", config = call_config_and_keybinds}
  use {
    "lewis6991/gitsigns.nvim",
    requires = {"nvim-lua/plenary.nvim"},
    config = call_config_and_keybinds
  }
  use {
    "tpope/vim-fugitive",
    config = call_config_and_keybinds
  }
  use {"machakann/vim-highlightedyank", event = "TextYankPost"}
  use {"ntpeters/vim-better-whitespace", config = call_config_and_keybinds}
  use {"lukas-reineke/indent-blankline.nvim", config = call_config_and_keybinds}

  -- Utilities
  use "tpope/vim-sleuth"
  use {"hrsh7th/vim-vsnip", config = call_config_and_keybinds}
  use {"whiteinge/diffconflicts", cmd = "DiffConflicts"}
  use {"Vimjas/vim-python-pep8-indent", ft = "python"}
  use {
    "numToStr/Navigator.nvim",
    config = call_config_and_keybinds
  }

  -- Editing
  use "tpope/vim-repeat"
  use {"sickill/vim-pasta", config = call_config_and_keybinds}
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
  use {
    "foosoft/vim-argwrap",
    config = call_config_and_keybinds
  }
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
    config = call_config_and_keybinds
  }
  use {
    "easymotion/vim-easymotion",
    config = call_config_and_keybinds
  }
  use "michaeljsmith/vim-indent-object"
  use {
    "folke/which-key.nvim",
    config = call_config_and_keybinds
  }
end)
