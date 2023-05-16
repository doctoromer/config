

local function telescope_config()
    local actions = require("telescope.actions")

    local default_keymaps = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<ESC>"] = actions.close,
        ["<C-c>"] = actions.close,
    }

    require("telescope").setup({
        defaults = {
            vimgrep_arguments = {
                "ag",
                "--nocolor",
                "--noheading",
                "--filename",
                "--numbers",
                "--column",
                "--smart-case",
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
            },
            mappings = { i = default_keymaps, n = default_keymaps },
        },
    })
end

local function telescope_fzf_native_config()
    require("telescope").load_extension("fzf")
end

return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/popup.nvim", "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
        -- Couldn't use the 'opts' field because some of the options requires using the 'actions' module
        config = telescope_config,
        ft = "dashboard",
    },
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        dependencies = "nvim-telescope/telescope.nvim",
        config = telescope_fzf_native_config,
        build = "make",
        event = "VeryLazy",
    },
    {
        "princejoogie/dir-telescope.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        config = true,
    },
}
