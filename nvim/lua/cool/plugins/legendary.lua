return {
    {
        "mrjones2014/legendary.nvim",
        dependencies = { "stevearc/dressing.nvim", dependencies = "nvim-telescope/telescope.nvim" },
        event = "VeryLazy",
        config = function()
            local legendary = require("legendary")

            legendary.setup({
                include_builtin = false,
                include_legendary_cmds = false,
                extensions = {
                    lazy = { keymaps = require("cool.keymaps") },
                },
                icons = {
                    itemgroup = "➤ ",
                },
                select_prompt = "⌘  Keymaps Explorer ⌘",
            })

            -- Set keymaps that aren't part of any plugins
            legendary.keymaps(require("cool.keymaps").other_keymaps())
        end,
    },
}
