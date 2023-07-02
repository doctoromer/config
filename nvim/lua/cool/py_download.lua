local M = {}

local levels = vim.log.levels
local utils = require("cool.utils")

M.pytools_dir = utils.download_dir .. "/pytools"
M.bin_dir = M.pytools_dir .. "/bin/"

local function run_command(...)
    local job_id = vim.fn.jobstart(...)
    local return_code = vim.fn.jobwait({ job_id })[1]
    return return_code
end

function M.find_pip()
    if M._found_pip then
        return M._found_pip
    end

    local search_list = {
        { "pip3" },
        { "python3",  "-m", "pip"  },
        { "pip" },
        { "python",  "-m", "pip"  },
    }

    local found_executable
    for _, executable in ipairs(search_list) do

        if vim.fn.executable(executable[1]) == 1 then
            local version_test = { unpack(executable) }
            table.insert(version_test, "--version")
            run_command(
                version_test,
                    {
                    on_stdout = function(_, data, _)
                        local major, minor = string.gmatch(data[1], ".*%(python (%d+)%.(%d+)%)")()
                        if major and minor then
                            if tonumber(major) == 3 and tonumber(minor) >= 5 then
                                found_executable = executable
                            end
                        end
                    end,
                }
            )
            if found_executable then
                break
            end
        end
    end
    M._found_pip = found_executable
    return found_executable
end

function M.find_python()
    if M._found_python then
        return M._found_python
    end

    local pythons = { "python3" }
    for i = 5, 11 do
        table.insert(pythons, "python3." .. i)
    end

    for _, python in ipairs(pythons) do
        if vim.fn.executable(python) == 1 then
            return python
        end
    end

    local python
    run_command(
        { "python", "--version" },
        {
            on_stdout = function(_, data, _)
                if string.gmatch(data[1], "Python (%d)%.%d%.%d") == "3" then
                    python = "python"
                end
            end
        }
    )
    if python then
        M._found_python = python
        return python
    end
end

function M.ensure_pex()
    local cache_dir = vim.fn.stdpath("cache")
    local pex_path = cache_dir .. "/pex"

    if utils.is_path_exists(pex_path) then
        return cache_dir
    end

    local download_pex_command = {unpack(M.find_pip())}
    table.insert(download_pex_command, "download")
    table.insert(download_pex_command, "-d")
    table.insert(download_pex_command, cache_dir)
    table.insert(download_pex_command, "pex")

    run_command(download_pex_command)

    local wheel_path = vim.fn.glob(cache_dir .. "/pex*.whl")
    run_command({ "unzip", wheel_path, "pex/*", "-d", cache_dir })
    return cache_dir
end

function M.run_pex(args)
    local pex_path = M.ensure_pex()
    local python3 = M.find_python()

    local pex_command = { python3, "-m", "pex" }
    for _, arg in ipairs(args) do
        table.insert(pex_command, arg)
    end
    run_command(pex_command, { env = { PYTHONPATH = pex_path } })
end

function M.download_to_pex(package_name, command_name)
    if command_name == nil then
        command_name = package_name
    end

    local pex_dir_path = M.pytools_dir .. "/packages/" .. command_name

    if not utils.is_path_exists(pex_dir_path) then
        vim.notify("Downloading " .. command_name .. "\n", levels.INFO)
        M.run_pex({ package_name, "--layout", "packed", "-c", command_name, "-o", pex_dir_path })
    else
        vim.notify("Command " .. command_name .. " Already exists, not downloading" .. "\n", levels.INFO)
    end

    local script_path = M.bin_dir .. command_name

    if not utils.is_path_exists(script_path) then
        vim.fn.mkdir(M.bin_dir, "p")

        local script_file = io.open(script_path, "w")

        if script_file then
            script_file:write(
                "#!/bin/sh" .. "\n" ..
                M.find_python() .. ' $(dirname -- "$( readlink -f -- "$0"; )")/../packages/' .. command_name .. ";"
            )

            run_command({"chmod", "+x", script_path})

            script_file:close()
        end
    end
end

function M.download_all()
    M.download_to_pex("python-lsp-server", "pylsp")
    M.download_to_pex("cmake-language-server")
    M.download_to_pex("clang-format")
end

function M.setup()
    vim.env.PATH = M.bin_dir .. ":" .. vim.env.PATH
end

return M
