local M = {}

local keymaps = require("cool.keymaps")
local nvim_root_dir = require("cool.options").nvim_root_dir
local plugins_path = nvim_root_dir .. "/lazy_plugins"
local lazy_path = nvim_root_dir .. "/lazy/lazy.nvim"

local download_mode = vim.g.download_mode

local function bootstrap_lazy_nvim()
    if vim.fn.empty(vim.fn.glob(lazy_path)) ~= 0 then
        if download_mode then
            vim.notify("Downloading lazy plugin manager...", vim.log.levels.INFO)

            local job_id = vim.fn.jobstart({
                "git",
                "clone",
                "--depth",
                "1",
                "--filter=blob:none",
                "--branch=stable", -- latest stable release
                "https://github.com/folke/lazy.nvim.git",
                lazy_path,
            })
            local return_code = vim.fn.jobwait({ job_id })[1]

            if return_code ~= 0 then
                vim.notify("Failed to download git! Exit code: " .. return_code, vim.log.levels.WARN)
                return false
            else
                return true
            end
        else
            vim.notify("Lazy is not installed! Use download mode to get it", vim.log.levels.WARN)
            return false
        end
    else
        return true
    end
end

DUMMY_MODULE = {}
setmetatable(DUMMY_MODULE, {
    __index = function(dummy_module)
        return dummy_module
    end,
    __call = function(dummy_module)
        return dummy_module
    end,
})

local function do_for_each_keymap(plugin_keymaps, keymap_function)
    for _, keymap in pairs(plugin_keymaps) do
        local flatted_keymaps = keymap.keymaps and keymap.keymaps or { keymap }

        for _, inner_keymap in pairs(flatted_keymaps) do
            keymap_function(inner_keymap)
        end
    end
end

local original_add
local original_config

local function get_plugin_keymaps_function(plugin_full_name)
    local plugin_name = plugin_full_name:gmatch("[^/]+/(.+)")()
    if plugin_name and keymaps[plugin_name] then
        return keymaps[plugin_name]
    end
end

local function plugin_add_patched(self, plugin, is_dep)
    -- Skip the plugin if it doesn't have a name, it is a dependency or it has been already loaded
    if not plugin[1] or is_dep or rawget(plugin, "_") then
        return original_add(self, plugin, is_dep)
    end

    local keymaps_function = get_plugin_keymaps_function(plugin[1])

    if keymaps_function then
        setfenv(keymaps_function, vim.tbl_extend("force", getfenv(), { require = DUMMY_MODULE }))
        local plugin_keymaps = keymaps_function()
        setfenv(keymaps_function, vim.tbl_extend("force", getfenv(), { require = require }))

        if not plugin.keys then
            plugin.keys = {}
            do_for_each_keymap(plugin_keymaps, function(keymap)
                table.insert(plugin.keys, { keymap[1], mode = keymap.mode })
            end)
        end

        -- If config have a value, then the patched config function will be called
        if not plugin.config then
            plugin.config = "__keymaps__"
        end
    end

    return original_add(self, plugin, is_dep)
end

local function loader_config_patched(plugin)
    if plugin.config == "__keymaps__" then
        plugin.config = nil
    end

    if plugin.config or plugin.opts then
        original_config(plugin)
    end

    local keymap_function = get_plugin_keymaps_function(plugin[1])

    if keymap_function then
        local map_only_keymaps = {}

        do_for_each_keymap(keymap_function(), function(keymap)
            keymap.description = nil
            table.insert(map_only_keymaps, keymap)
        end)

        require("legendary").keymaps(map_only_keymaps)
    end
end

local function patch_lazy()
    local Spec = require("lazy.core.plugin").Spec
    original_add = Spec.add
    Spec.add = plugin_add_patched

    local loader = require("lazy.core.loader")
    original_config = loader.config
    loader.config = loader_config_patched
end

local function create_legendary_menus()
    local result = {}
    for _, keymap_function in pairs(keymaps) do
        setfenv(keymap_function, vim.tbl_extend("force", getfenv(), { require = DUMMY_MODULE }))
        local plugin_keymaps = keymap_function()
        setfenv(keymap_function, vim.tbl_extend("force", getfenv(), { require = require }))
        do_for_each_keymap(plugin_keymaps, function(keymap)
            keymap[2] = nil
        end)
        for _, keymap_item in pairs(plugin_keymaps) do
            table.insert(result, keymap_item)
        end
    end

    vim.api.nvim_create_autocmd(
        "User",
        {
            pattern = "LazyDone",
            callback = function()
                require("legendary").keymaps(result)
            end,
            once = true,
        }
    )
end

local function init_lazy()
    vim.opt.rtp:prepend(lazy_path)

    local xdg_config_dirs = vim.tbl_map(function(item)
        return item .. "/nvim"
    end, vim.fn.split(vim.env.XDG_CONFIG_DIRS or "/etc/xdg", ":"))

    patch_lazy()
    create_legendary_menus()

    require("lazy").setup("cool.plugins", {
        root = plugins_path,
        lockfile = nvim_root_dir .. "/lazy-lock.json",
        -- For some reason it notifies that file are deleted, when it is not true
        change_detection = { notify = false },
        -- For some reason the system-wide path is not included in the runtimepath
        performance = { rtp = { paths = xdg_config_dirs } },
        install = {
            missing = download_mode,
            colorscheme = { "onedark" },
        },
        ui = {
            icons = {
                cmd = "⌘",
                config = "🛠",
                event = "📅",
                ft = "📂",
                init = "⚙",
                keys = "🗝",
                plugin = "🔌",
                runtime = "💻",
                source = "📄",
                start = "🚀",
                task = "📌",
                lazy = "💤 ",
            },
        },
    })
    return true
end

local function quit()
    if download_mode then
        vim.notify("\nEverything downloaded sucessfully!\n", vim.log.levels.INFO)
        vim.cmd.quit()
    end
end

local function download_mason_tools()
    vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsUpdateCompleted",
        callback = function()
            quit()
        end,
    })

    vim.notify("Updating mason tools...", vim.log.levels.INFO)
    vim.cmd.MasonToolsUpdate()
end

local function download()
    if download_mode then
        vim.notify("Updating plugins...", vim.log.levels.INFO)
        require("lazy").sync()

        if require("lazy.core.loader").init_done then
            download_mason_tools()
        else
            vim.api.nvim_create_autocmd("User", {
                pattern = "LazyInstall",
                callback = function()
                    download_mason_tools()
                end,
                once = true,
            })
        end
    end
end

M.setup = function()
    if download_mode then
        if not bootstrap_lazy_nvim() then
            return
        end
    end

    if not init_lazy() then
        return
    end

    download()
end

return M
