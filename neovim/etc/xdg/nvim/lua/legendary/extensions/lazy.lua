toolbox = require("legendary.toolbox")

local function init(config)
    local keymaps_functions = config.keymaps
    local lazy_plugins = require("lazy.core.config").plugins

    for plugin_name, plugin_spec in pairs(lazy_plugins) do
        keymaps_function = keymaps_functions[plugin_name]

        if keymaps_function then

            -- This forces the loading of all plugins with keymaps and efectively cancels the lazy-loading
            -- In the future, this should be fixed
            local keymaps = keymaps_function()
            require("legendary").keymaps(keymaps)
        end
    end
end

return function(config)
    if require("lazy.core.loader").init_done then
        init(config)
    else
        vim.api.nvim_create_autocmd("User", {
            pattern = "LazyDone",
            callback = function() init(config) end,
            once = true
        })
    end
end
