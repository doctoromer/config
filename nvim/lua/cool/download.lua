M = {}

local levels = vim.log.levels
local is_path_exists = require("cool.utils").is_path_exists

local function bootstrap_lazy_nvim(lazy_path)
    if is_path_exists(lazy_path) then
        vim.notify("Lazy plugin manager already exists, not downloading", levels.INFO)
        return
    end
    vim.notify("Downloading lazy plugin manager...", levels.INFO)

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

    if return_code == 0 then
        vim.notify("Lazy downloaded successfully", levels.INFO)
    else
        vim.notify("Failed to download git! Exit code: " .. return_code, levels.WARN)
    end
end

local function download_mason_tools()
    vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsUpdateCompleted",
        callback = function()
            require("cool.py_download").download_all()
            vim.notify("Everything downloaded sucessfully!\n", levels.INFO)
            vim.cmd.quit()
        end,
    })

    vim.notify("Updating mason tools...", levels.INFO)
    vim.cmd.MasonToolsUpdate()
end

local function download_plugins()
    vim.notify("Updating plugins...", levels.INFO)
    vim.api.nvim_create_autocmd("User", {
        pattern = "LazyDone",
        callback = download_mason_tools,
        once = true,
    })
end

function M.download(download_dir)
    M.download_dir = download_dir

    if #vim.api.nvim_list_uis() ~= 0 then
        vim.notify("Please run neovim with the '--headless' switch. Exiting...", levels.ERROR)
        vim.cmd.quit()
    end
    local lazy_init = require("cool.lazy_init")

    bootstrap_lazy_nvim(download_dir .. "/lazy/lazy.nvim")
    download_plugins()
    lazy_init.setup(true, download_dir)

    vim.print("")
end

return M
