local function telescope_config()
    local actions = require("telescope.actions")
    local state = require("telescope.state")
    local action_state = require("telescope.actions.state")

    -- Copied from telescope.actions.set
    local function scroll_line_previewer(prompt_bufnr, direction)
        local previewer = action_state.get_current_picker(prompt_bufnr).previewer
        local status = state.get_status(prompt_bufnr)

        -- Check if we actually have a previewer and a preview window
        if type(previewer) ~= "table" or previewer.scroll_fn == nil or status.preview_win == nil then
            return
        end
        previewer:scroll_fn(direction)
    end

    local function scroll_line(direction)
        return function(prompt_bufnr)
            scroll_line_previewer(prompt_bufnr, direction)
        end
    end

    local default_keymaps = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,

        ["<ESC>"] = actions.close,
        ["<C-c>"] = actions.close,

        ["<C-s>"] = actions.file_split,
        ["<C-v>"] = actions.file_vsplit,
        ["<C-t>"] = actions.file_tab,

        -- One line scrolling
        ["<C-e>"] = scroll_line(1),
        ["<C-y>"] = scroll_line(-1),

        -- Disable selection since multi-select actions are not implemented
        ["<Tab>"] = function() end,
        ["<S-Tab>"] = function() end,
    }

    require("telescope").setup({
        defaults = {
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
        -- Couldn't use the 'opts' field because some of the options requires using the 'actions' module
        config = telescope_config,
        ft = "dashboard",
    },
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        dependencies = "nvim-telescope/telescope.nvim",
        config = telescope_fzf_native_config,
        build = "make",
    },
    {
        "princejoogie/dir-telescope.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        config = true,
    },
}
