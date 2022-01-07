local M = {}

local config = {
  modules_names = nil,
  keybindings = nil,
  plugins_config = nil,
}

function require_plugin_modules(plugin_name, modules_type)
  plugin_spec = config.modules_names[plugin_name] or {}
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
  local plugins_config = config.plugins_config
  local keybind = config.keybindings
  local which_key = require("which-key")

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

local DUMMY_MODULE = {}
setmetatable(DUMMY_MODULE, {
  __index = function(dummy_module, key)
    return dummy_module
  end,
  __call = function(dummy_module, args)
    return dummy_module
  end
})

local function generate_keybinds(name)
  local keybind = config.keybindings
  local keys = require("which-key.keys")

  if keybind[name] then
    keybind_result = keybind[name](
      DUMMY_MODULE,
      DUMMY_MODULE,
      DUMMY_MODULE,
      DUMMY_MODULE,
      DUMMY_MODULE,
      DUMMY_MODULE,
      DUMMY_MODULE,
      DUMMY_MODULE,
      DUMMY_MODULE,
      DUMMY_MODULE,
      DUMMY_MODULE,
      DUMMY_MODULE,
      DUMMY_MODULE,
      DUMMY_MODULE,
      DUMMY_MODULE,
      DUMMY_MODULE,
      DUMMY_MODULE,
      DUMMY_MODULE,
      DUMMY_MODULE
    )
    mappings = keys.parse_mappings({}, keybind_result, "")
    result = {}

    for _, mapping in pairs(mappings) do
      if not mapping.group then
        mode = mapping.mode or "n"
        table.insert(result, {mode, mapping.prefix})
      end
    end
    return result
  else
    return {}
  end
end

M.setup = function(user_config)
  config = user_config
end

M.make_config = function(plugins)
  result = {}
  for _, plugin in pairs(plugins) do

    if type(plugin) == "string" then
      plugin = {plugin}
    end

    if not plugin.config then
      plugin.config = call_config_and_keybind
    end

    local function set_if_not_false(table, key, value)
      if table[key] == nil then
        table[key] = value
      elseif table[key] == false then
        table[key] = nil
      end
    end

    repo_name = plugin[1]:gmatch("[^/]+/(.+)")()
    set_if_not_false(plugin, "keys", generate_keybinds(repo_name))
    set_if_not_false(plugin, "config", call_config_and_keybinds)

    table.insert(result, plugin)
  end
  return result
end

return M
