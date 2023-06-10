local M = {}

function M.is_path_exists(path)
    return vim.fn.empty(vim.fn.glob(path)) ~= 1
end

local function get_nvim_config_dir()
    local config_dirs = vim.fn.stdpath("config_dirs")
    table.insert(config_dirs, vim.fn.stdpath("config"))

    for _, dir in ipairs(config_dirs) do
        if M.is_path_exists(dir .. "/lua/cool") then
            return vim.fn.resolve(dir)
        end
    end
end

M.nvim_root_dir = get_nvim_config_dir()

return M
