local full_char_seperator = "│"

local function onedark_config()
    require("onedark").setup({ style = "darker" })
    vim.cmd("colorscheme onedark")
end

local function lualine_config()
    require("lualine").setup({
        options = {
            theme = require("lualine.themes.onedark"),
            component_separators = { left = full_char_seperator, right = full_char_seperator },
            section_separators = { left = "", right = "" },
        },
        sections = {
            lualine_a = { "mode" },
            lualine_b = {
                { "branch", icon = "" },
            },
            lualine_c = {
                {
                    "filename",
                    symbols = { modified = " +", readonly = "", unnamed = "" },
                },
            },
            lualine_y = {
                "fileformat",
                {
                    "filetype",
                    cond = function()
                        return vim.bo.filetype ~= "dashboard"
                    end,
                },
            },
            lualine_z = { "location" },
        },
    })
end

local function tabby_config()
    local lualine_theme = require("lualine.themes.onedark")
    local mode_theme = {
        n = lualine_theme.normal.a,
        c = lualine_theme.command.a,
        i = lualine_theme.insert.a,

        v = lualine_theme.visual.a,
        V = lualine_theme.visual.a,
        [""] = lualine_theme.visual.a,

        t = lualine_theme.terminal.a,
        R = lualine_theme.replace.a,
    }
    local inactive_theme = lualine_theme.inactive.a

    -- This makes the tabline update when changing modes (not including visual modes)
    vim.api.nvim_create_autocmd({ "ModeChanged" }, {
        callback = function()
            vim.cmd("redrawtabline")
        end,
    })

    -- Renders one tab label from tabby's tab object
    local function tab_render(tab)
        local hl = tab.is_current() and mode_theme[vim.fn.mode()] or inactive_theme
        local modified = vim.api.nvim_get_option_value("modified", {buf = tab.current_win().buf().id}) and " +" or ""
        return {
            " ",
            tab.name(),
            modified,
            " ",
            hl = hl,
        }
    end

    -- Renders the entire tabline from tabby's line object
    local function tabline_render(line)
        return {
            line.tabs().foreach(tab_render),
            line.spacer(),
            hl = "TabLineFill",
        }
    end

    -- Renders the label's name string from neovim's tab_id
    local function tab_label_render(tab_id)
        local current_window = vim.api.nvim_tabpage_get_win(tab_id)
        if vim.api.nvim_win_get_config(current_window).relative ~= "" then
            return "[Floating]"
        else
            return require("tabby.feature.buf_name").get(current_window)
        end
    end

    require("tabby.tabline").set(
        tabline_render,
        { tab_name = { name_fallback = tab_label_render }, buf_name = { mode = "unique" } }
    )
    vim.o.showtabline = 2
end

local function dashboard_config()
    local dashboard = require("dashboard")

    local ascii_art = require("cool.ascii_art")
    local header

    if vim.env.NVIM_RANDOM_DASHBOARD_ASCII_ART then
        math.randomseed(os.time())
        header = ascii_art[math.random(#ascii_art)]
    else
        header = ascii_art[1]
    end

    -- Spacing from top of the window
    header = { "", "", "", "", "", unpack(header) }

    dashboard.setup({
        -- The hyper theme requires web-devicons, so doom is used
        theme = "doom",
        config = {
            header = header,
            center = {
                { icon = "* ", desc = "Find files", action = "Telescope find_files" },
                { icon = "* ", desc = "New file", action = "enew" },
            },
            footer = { "🙃" },
        },
    })
end

local function better_whitespace_config()
    vim.g.better_whitespace_enabled = true
    vim.g.strip_whitespace_on_save = false
    -- The "" filetype is the filetype of terminal buffers
    vim.g.better_whitespace_filetypes_blacklist = { "dashboard", "help", "markdown", "" }
end

local function indent_blankline_config()
    require("ibl").setup(
        {
            indent = { char = full_char_seperator },
            exclude = { filetypes = { "dashboard", "help" }},
            scope = { enabled = false, show_start = false },
        }
    )
    local hooks = require("ibl.hooks")
    hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
end

return {
    { "navarasu/onedark.nvim", lazy = false, priority = 1000, config = onedark_config },
    { "nvim-lualine/lualine.nvim", config = lualine_config },
    { "j-hui/fidget.nvim", config = true },
    { "nanozuki/tabby.nvim", config = tabby_config },
    { "nvimdev/dashboard-nvim", config = dashboard_config },
    { "lewis6991/gitsigns.nvim", dependencies = "nvim-lua/plenary.nvim", config = true, event = "VeryLazy", keys = "no_lazy" },
    { "machakann/vim-highlightedyank", event = "TextYankPost" },
    { "asiryk/auto-hlsearch.nvim", config = true, keys = { "/", "?", "*", "#" } },
    { "ntpeters/vim-better-whitespace", config = better_whitespace_config },
    { "lukas-reineke/indent-blankline.nvim", config = indent_blankline_config, event = "VeryLazy" },
    { "lukas-reineke/virt-column.nvim", config = true },
}
