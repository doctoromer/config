
return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/popup.nvim", "nvim-lua/plenary.nvim" },
        -- Couldn't use the 'opts' field because some of the options requires using the 'actions' module
        config = function()
            local actions = require("telescope.actions")
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
                    mappings = {
                        i = {
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<ESC>"] = actions.close,
                            ["<C-c>"] = actions.close,
                        },
                        n = {
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<ESC>"] = actions.close,
                            ["<C-c>"] = actions.close,
                        },
                    },
                },
            })
        end,
        ft = "dashboard",
    },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
}
