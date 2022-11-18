local M = {}

config = {
    keymaps_functions = nil,
    plugins_config = nil,
}

DUMMY_MODULE = {}
setmetatable(DUMMY_MODULE, {
    __index = function(dummy_module)
        return dummy_module
    end,
    __call = function(dummy_module)
        return dummy_module
    end,
})

function require_or_value(module_name, value)
    local success, module = pcall(require, module_name)
    if success then
        return module
    else
        return value
    end
end

function call_config_and_bind_keymaps(name)
    local Keymap = require("legendary.data.keymap")

    if config.keymaps_functions[name] then
        local keymaps = config.keymaps_functions[name]()
        for _, keymap in pairs(keymaps) do
            Keymap:parse(keymap):apply()
        end

    end

    if config.plugins_config[name] then
        config.plugins_config[name]()
    end
end

local function generate_packer_keymaps(keymaps)
    local result = {}

    for _, keymap in pairs(keymaps) do
        if type(keymap.mode) == "table" then
            for _, mode in pairs(keymap.mode) do
                table.insert(result, { mode, keymap[1] })
            end
        else
            local mode = keymap.mode or "n"
            table.insert(result, { mode, keymap[1] })
        end
    end

    -- Check if table is empty
    return result
end

local function set_if_not_false(table, key, value)
    if table[key] == nil then
        table[key] = value
    elseif table[key] == false then
        table[key] = nil
    end
end

local function map_keymaps_without_keys(keymaps)
    local legendary = require("legendary")
    local keymaps_without_callbacks = vim.deepcopy(keymaps)
    for _, keymap in pairs(keymaps_without_callbacks) do
        keymap[2] = nil
    end
    -- p(keymaps_without_callbacks)
    legendary.keymaps(keymaps_without_callbacks)
end

M.make_config = function(plugins)
    vim.cmd("packadd legendary.nvim")
    local result = {}

    for _, plugin in pairs(plugins) do
        if type(plugin) == "string" then
            plugin = { plugin }
        end

        -- Extract from <plugin_author>/<plugin_name> the <plugin_name>
        local repo_name = plugin[1]:gmatch("[^/]+/(.+)")()

        local keymaps_function = config.keymaps_functions[repo_name]

        if keymaps_function then

          -- Get the keymaps table without requiring the actual plugin
          setfenv(keymaps_function, vim.tbl_extend("force", getfenv(), {require = DUMMY_MODULE}))
          local keymaps = keymaps_function()
          setfenv(keymaps_function, vim.tbl_extend("force", getfenv(), {require = require}))

          map_keymaps_without_keys(keymaps)

          set_if_not_false(plugin, "keys", generate_packer_keymaps(keymaps))
        end

        if config.plugins_config[repo_name] or keymaps_function then
            set_if_not_false(plugin, "config", call_config_and_bind_keymaps)
        end

        table.insert(result, plugin)
    end
    return { result }
end

M.setup = function(user_config)
    config = user_config
end

return M
