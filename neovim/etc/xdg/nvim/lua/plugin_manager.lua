local M = {}

config = {
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

DUMMY_MODULE = {}
setmetatable(DUMMY_MODULE, {
  __index = function(dummy_module, key)
    return dummy_module
  end,
  __call = function(dummy_module, args)
    return dummy_module
  end
})

function require_or_value(module_name, value)
  success, module = pcall(require, module_name)
  if success then
    return module
  else
    return value
  end
end

function call_config_and_keybinds(name)
  local which_key = require_or_value("which-key", DUMMY_MODULE)

  if config.keybindings[name] then
    modules = require_plugin_modules(name, "keybind")
    keybind_result = config.keybindings[name](unpack(modules))

    if keybind_result[1] and keybind_result[2] then
      which_key.register(keybind_result[1], keybind_result[2])
    else
      which_key.register(keybind_result)
    end
  end

  if config.plugins_config[name] then
    modules = require_plugin_modules(name, "config")
    config.plugins_config[name](unpack(modules))
  end
end

local function generate_keybinds(keybindings)
  local which_key_keys = require_or_value("which-key.keys", DUMMY_MODULE)

  keybind_result = keybindings(
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
  mappings = which_key_keys.parse_mappings({}, keybind_result, "")
  result = {}

  for _, mapping in pairs(mappings) do
    if not mapping.group then
      mode = mapping.mode or "n"
      table.insert(result, {mode, mapping.prefix})
    end
  end
  -- Check if table is empty
  if not next(result) then
    return nil
  else
    return result
  end
end

M.setup = function(user_config)
  config = user_config
end

M.make_config = function(plugins)
  local result = {}
  for _, plugin in pairs(plugins) do

    if type(plugin) == "string" then
      plugin = {plugin}
    end

    local function set_if_not_false(table, key, value)
      if table[key] == nil then
        table[key] = value
      elseif table[key] == false then
        table[key] = nil
      end
    end

    repo_name = plugin[1]:gmatch("[^/]+/(.+)")()

    if config.keybindings[repo_name] then
      set_if_not_false(plugin, "keys", generate_keybinds(config.keybindings[repo_name]))
    end

    if config.plugins_config[repo_name] or config.keybindings[repo_name] then
      set_if_not_false(plugin, "config", call_config_and_keybinds)
    end

    table.insert(result, plugin)
  end
  return {result}
end

return M
