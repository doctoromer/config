local nvim_root_dir = require("cool.options").nvim_root_dir
local plugins_path = nvim_root_dir .. "/lazy_plugins"
local lazy_path = nvim_root_dir .. "/lazy/lazy.nvim"

local function bootstrap_lazy_nvim()
    local was_bootstrapped = false

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
    xdg_config_dirs = vim.tbl_map(
        function(item) return item .. "/nvim" end,
        vim.fn.split(vim.env.XDG_CONFIG_DIRS or "/etc/xdg", ":")
    )

    require("lazy").setup(
        "cool.plugins",
        {
            root = plugins_path,
            -- For some reason it notifies that file are deleted, when it is not true
            change_detection = { notify = false },
            -- For some reason the system-wide path is not included in the runtimepath
            performance = { rtp = { paths = xdg_config_dirs } },
        }
    )

    -- Set keymaps that aren't part of any plugins
    require("legendary").keymaps(require("cool.keymaps").other_keymaps())
end

bootstrap_lazy_nvim()
init_lazy()
