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
    local legendary = require_or_value("legendary", DUMMY_MODULE)

    if config.keymaps_functions[name] then
        local keymaps = config.keymaps_functions[name]()
        legendary.keymaps(keymaps)
    end

    if config.plugins_config[name] then
        config.plugins_config[name]()
    end
end

local function generate_packer_keymaps(keymaps_function)
    setfenv(
        keymaps_function,
        vim.tbl_extend("force", getfenv(), {
            require = function()
                return DUMMY_MODULE
            end,
        })
    )
    local keymaps = keymaps_function()
    setfenv(keymaps_function, vim.tbl_extend("force", getfenv(), { require = require }))

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

M.setup = function(user_config)
    config = user_config
end

M.make_config = function(plugins)
    local result = {}
    for _, plugin in pairs(plugins) do
        if type(plugin) == "string" then
            plugin = { plugin }
        end

        local function set_if_not_false(table, key, value)
            if table[key] == nil then
                table[key] = value
            elseif table[key] == false then
                table[key] = nil
            end
        end

        local repo_name = plugin[1]:gmatch("[^/]+/(.+)")()

        if config.keymaps_functions[repo_name] then
            set_if_not_false(plugin, "keys", generate_packer_keymaps(config.keymaps_functions[repo_name]))
        end

        if config.plugins_config[repo_name] or config.keymaps_functions[repo_name] then
            set_if_not_false(plugin, "config", call_config_and_bind_keymaps)
        end

        table.insert(result, plugin)
    end
    return { result }
end

return M
