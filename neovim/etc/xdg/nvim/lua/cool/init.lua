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

    require("lazy").setup(
        --plugin_manager.make_config(plugins_plugins),
        "cool.plugins",
        {
            root = plugins_path,
            install = {
                -- missing = false
            },
            change_detection = {
                -- For some reason it notifies that file are deleted, when it is not true
                notify = false
            }
        }
    )
end

bootstrap_lazy_nvim()
init_lazy()
