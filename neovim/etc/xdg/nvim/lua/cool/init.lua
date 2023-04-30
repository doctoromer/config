require("cool.config")

local config = require("cool.config")
local plugins_path = config.nvim_root_dir .. "/lazy_plugins"

local function bootstrap_lazy_nvim()
    local was_bootstrapped = false
    local lazy_path = config.nvim_root_dir .. "/lazy/lazy.nvim"

    if vim.fn.empty(vim.fn.glob(lazy_path)) ~= 0 then
        vim.fn.system({
            "git",
            "clone",
            "--depth", "1",
            "--filter=blob:none",
            "--branch=stable", -- latest stable release
            "https://github.com/folke/lazy.nvim.git",
            lazy_path
        })
        was_bootstrapped = true
    end

    vim.opt.rtp:prepend(lazy_path)
    return was_bootstrapped
end

local function init_lazy()
    local plugin_manager = require("cool.plugin_manager")
    plugin_manager.setup({
        keymaps_functions = require("cool.keymaps"),
        plugins_config = require("cool.plugins_config"),
    })

    xdg_config_dirs = vim.tbl_map(
        function(item) return item .. "/nvim" end,
        vim.fn.split(vim.env.XDG_CONFIG_DIRS or "/etc/xdg", ":")
    )

    require("lazy").setup(
        "cool.plugins",
        {
            root = plugins_path,
            install = {
                -- missing = false
            },
            change_detection = {
                -- For some reason it notifies that file are deleted, when it is not true
                notify = false
            },
            performance = {
                rtp = {
                    -- For some reason the system-wide path is not included in the runtimepath
                    paths = xdg_config_dirs
                },
            },
        }
    )

    -- Set keymaps that aren't part of any plugins
    require("legendary").keymaps(require("cool.keymaps").other_keymaps())
end

bootstrap_lazy_nvim()
init_lazy()
