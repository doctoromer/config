local function multiopen(prompt_bufnr, open_cmd)
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    local picker = action_state.get_current_picker(prompt_bufnr)
    local num_selections = #picker:get_multi_selection()

    if not num_selections or num_selections <= 1 then
        actions.add_selection(prompt_bufnr)
    end
    actions.send_selected_to_qflist(prompt_bufnr)

    local results = vim.fn.getqflist()

    for _, result in ipairs(results) do
        local current_file = vim.fn.bufname()
        local next_file = vim.fn.bufname(result.bufnr)

        if current_file == "" then
            vim.api.nvim_command("edit" .. " " .. next_file)
        else
            vim.api.nvim_command(open_cmd .. " " .. next_file)
        end
    end

    vim.api.nvim_command("cd .")
end

local function telescope_config()
    local actions = require("telescope.actions")

    local action_keymaps = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<ESC>"] = actions.close,
        ["<C-c>"] = actions.close,
        ["<TAB>"] = actions.toggle_selection + actions.move_selection_next,

        ["<C-v>"] = function(prompt_bufnr)
            multiopen(prompt_bufnr, "vsplit")
        end,
        ["<C-s>"] = function(prompt_bufnr)
            multiopen(prompt_bufnr, "split")
        end,
        ["<C-t>"] = function(prompt_bufnr)
            multiopen(prompt_bufnr, "tabe")
        end,
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
            mappings = { i = action_keymaps, n = action_keymaps },
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
