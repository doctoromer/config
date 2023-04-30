return {
    {
        "mrjones2014/legendary.nvim",
        dependencies = { "stevearc/dressing.nvim", dependencies = "nvim-telescope/telescope.nvim" },
        opts = {
            include_builtin = false,
            include_legendary_cmds = false,
            extensions = {
                lazy = { keymaps = require("cool.keymaps") }
            }
        }
    },
}
