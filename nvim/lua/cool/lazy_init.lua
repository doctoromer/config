local M = {}

local nvim_root_dir = require("cool.options").nvim_root_dir
local plugins_path = nvim_root_dir .. "/lazy_plugins"
local lazy_path = nvim_root_dir .. "/lazy/lazy.nvim"

local download_mode = vim.g.download_mode

local function bootstrap_lazy_nvim()
    if vim.fn.empty(vim.fn.glob(lazy_path)) ~= 0 then
        if download_mode then
            vim.notify("Downloading lazy plugin manager...", vim.log.levels.INFO)

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

            if return_code ~= 0 then
                vim.notify("Failed to download git! Exit code: " .. return_code, vim.log.levels.WARN)
                return false
            else
                return true
            end
        else
            vim.notify("Lazy is not installed! Use download mode to get it", vim.log.levels.WARN)
            return false
        end
    else
        return true
    end
end

local function init_lazy()
    vim.opt.rtp:prepend(lazy_path)

    local xdg_config_dirs = vim.tbl_map(function(item)
        return item .. "/nvim"
    end, vim.fn.split(vim.env.XDG_CONFIG_DIRS or "/etc/xdg", ":"))

    -- Lazy need the mapleader setted, which is defined in keymaps module
    require("cool.keymaps")

    require("lazy").setup("cool.plugins", {
        root = plugins_path,
        lockfile = nvim_root_dir .. "/lazy-lock.json",
        -- For some reason it notifies that file are deleted, when it is not true
        change_detection = { notify = false },
        -- For some reason the system-wide path is not included in the runtimepath
        performance = { rtp = { paths = xdg_config_dirs } },
        install = {
            missing = download_mode,
            colorscheme = { "onedark" },
        },
        ui = {
            icons = {
                cmd = "✼ ",
                config = "✠",
                event = "✇",
                ft = "࿋ ",
                init = "➤ ",
                import = "⎌ ",
                keys = "྿ ",
                lazy = "⌘ ",
                loaded = "●",
                not_loaded = "○",
                plugin = "☘ ",
                runtime = "☸ ",
                source = "⬠ ",
                start = "⇧",
                task = "✔ ",
                list = { "●", "➜", "★", "‒" },
            },
        },
    })
    return true
end

local function quit()
    if download_mode then
        vim.notify("\nEverything downloaded sucessfully!\n", vim.log.levels.INFO)
        vim.cmd.quit()
    end
end

local function download_mason_tools()
    vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsUpdateCompleted",
        callback = function()
            quit()
        end,
    })

    vim.notify("Updating mason tools...", vim.log.levels.INFO)
    vim.cmd.MasonToolsUpdate()
end

local function download()
    if download_mode then
        vim.notify("Updating plugins...", vim.log.levels.INFO)
        require("lazy").sync()

        if require("lazy.core.loader").init_done then
            download_mason_tools()
        else
            vim.api.nvim_create_autocmd("User", {
                pattern = "LazyInstall",
                callback = function()
                    download_mason_tools()
                end,
                once = true,
            })
        end
    end
end

M.setup = function()
    if download_mode then
        if not bootstrap_lazy_nvim() then
            return
        end
    end

    if not init_lazy() then
        return
    end

    download()
end

return M
