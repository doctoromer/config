M = {}

local DUMMY_MODULE = {}
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

local function get_plugin_keymaps_function(plugin, keymaps)
    local plugin_full_name = plugin[1] or plugin.url
    local plugin_name = plugin_full_name:gmatch("/([^/]+)$")()
    if plugin_name and keymaps[plugin_name] then
        return keymaps[plugin_name]
    end
end

local function plugin_add_patched(self, plugin)
    -- Skip the plugin if it doesn't have a name, it is a dependency or it has been already loaded
    if not plugin[1] or rawget(plugin, "_") then
        return M.original_add(self, plugin)
    end

    local plugin_keymaps = get_plugin_keymaps_function(plugin, M.keymaps_with_dummy)

    if plugin_keymaps then
        -- The no_lazy value in the keys field is used to allow using auto_keymaps module to map keys without
        -- lazy loading the plugin.
        if plugin.keys == "no_lazy" then
            plugin.keys = nil
        else
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

    return M.original_add(self, plugin)
end

local function loader_config_patched(plugin)
    if plugin.config == "__keymaps__" then
        plugin.config = nil
    end

    if plugin.config or plugin.opts then
        M.original_config(plugin)
    end

    local keymap_function = get_plugin_keymaps_function(plugin, M.keymaps_functions)

    if keymap_function then
        local map_only_keymaps = {}

        do_for_each_keymap(keymap_function(), function(keymap)
            keymap.description = nil
            table.insert(map_only_keymaps, keymap)
        end)

        require("legendary").keymaps(map_only_keymaps)
    end
end

local function patch_lazy_functions()
    local meta = require("lazy.core.meta")
    M.original_add = meta.add
    meta.add = plugin_add_patched

    local loader = require("lazy.core.loader")
    M.original_config = loader.config
    loader.config = loader_config_patched
end

local function create_legendary_menus()
    local result = {}

    for _, plugin_keymaps in pairs(vim.deepcopy(M.keymaps_with_dummy)) do
        do_for_each_keymap(plugin_keymaps, function(keymap)
            keymap[2] = nil
        end)

        for _, keymap_item in pairs(plugin_keymaps) do
            table.insert(result, keymap_item)
        end
    end

    vim.api.nvim_create_autocmd("User", {
        pattern = "LazyDone",
        callback = function()
            require("legendary").keymaps(result)
        end,
        once = true,
    })
end

function M.setup(opts)
    M.keymaps_functions = opts.keymaps
    M.keymaps_with_dummy = {}

    for plugin_name, keymap_function in pairs(M.keymaps_functions) do
        -- Run a function while temporarily replacing the require function with dummy function that does nothing.
        -- This is useful to use the keymaps without load the plugins themselves, because it cannot be done while
        -- before calling require("lazy").setup.
        setfenv(keymap_function, vim.tbl_extend("force", getfenv(), { require = DUMMY_MODULE }))
        local plugin_keymaps = keymap_function()
        setfenv(keymap_function, vim.tbl_extend("force", getfenv(), { require = require }))

        M.keymaps_with_dummy[plugin_name] = plugin_keymaps
    end

    patch_lazy_functions()
    create_legendary_menus()
end

return M
