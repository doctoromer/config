local M = {}

config = {
  keybindings = nil,
  plugins_config = nil,
}

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
    keybind_result = config.keybindings[name]()

    if keybind_result[1] and keybind_result[2] then
      which_key.register(keybind_result[1], keybind_result[2])
    else
      which_key.register(keybind_result)
    end
  end

  if config.plugins_config[name] then
    config.plugins_config[name]()
  end
end

local function generate_keybinds(keybindings)
  local which_key_keys = require_or_value("which-key.keys", DUMMY_MODULE)

  setfenv(keybindings, vim.tbl_extend("force", getfenv(), { require = function() return DUMMY_MODULE end}))
  keybind_result = keybindings()
  setfenv(keybindings, vim.tbl_extend("force", getfenv(), { require = require}))

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
