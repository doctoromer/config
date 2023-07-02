local M = {}

function M.setup(auto_install, download_dir)
    local lockfile_path = require("cool.utils").nvim_root_dir .. "/lazy-lock.json"

    vim.opt.rtp:prepend(download_dir .. "/lazy/lazy.nvim")

    local xdg_config_dirs = vim.tbl_map(function(item)
        return item .. "/nvim"
    end, vim.fn.split(vim.env.XDG_CONFIG_DIRS or "/etc/xdg", ":"))

    require("cool.auto_keymaps").setup({ keymaps = require("cool.keymaps") })

    require("lazy").setup("cool.plugins", {
        root = download_dir .. "/plugins",
        lockfile = lockfile_path,
        -- For some reason it notifies that file are deleted, when it is not true
        change_detection = { notify = false },
        -- For some reason the system-wide path is not included in the runtimepath
        performance = { rtp = { paths = xdg_config_dirs } },
        install = {
            missing = auto_install or false,
            colorscheme = { "onedark" },
        },
        ui = {
            icons = {
                cmd = "⌘",
                config = "🛠",
                event = "📅",
                ft = "📂",
                init = "⚙",
                keys = "🗝",
                plugin = "🔌",
                runtime = "💻",
                source = "📄",
                start = "🚀",
                task = "📌",
                lazy = "💤 ",
            },
        },
    })
    return true
end

return M
