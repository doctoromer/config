local function blink_config()
    return {
        keymap = {
            preset = "none",

            ["<C-space>"] = { "snippet_forward", "fallback" },
            -- { "show", "show_documentation", "hide_documentation" },
            -- ["<C-e>"] = { "hide", "fallback" },
            ["<CR>"] = { "accept", "fallback" },

            ["<Tab>"] = { "select_next", "fallback" },
            ["<S-Tab>"] = { "select_prev", "fallback" },

            ["<C-k>"] = { "scroll_documentation_up", "fallback" },
            ["<C-j>"] = { "scroll_documentation_down", "fallback" },
        },
        appearance = {
            kind_icons = {
                Text = "📝",
                Method = "🎯",
                Function = "⚙️",
                Constructor = "🔨",

                Field = "🏷️",
                Variable = "📊",
                Property = "🔧",

                Class = "🎓",
                Interface = "🔌",
                Struct = "🧱",
                Module = "📦",

                Unit = "📏",
                Value = "💎",
                Enum = "📋",
                EnumMember = "🔹",

                Keyword = "🔑",
                Constant = "🔒",

                Snippet = "✂️",
                Color = "🎨",
                File = "📄",
                Reference = "🔗",
                Folder = "📁",
                Event = "⚡",
                Operator = "➕",
                TypeParameter = "🔤",
            },
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
        },
        completion = {
            menu = { border = "rounded" },
            documentation = {
                auto_show = true,
                window = { border = "rounded" },
            },
        },
        signature = { enabled = true, window = { border = "rounded" } },
        snippets = {
            preset = "luasnip",
        },
    }
end

local function luasnip_config()
    local luasnip = require("luasnip")
    local unlink_group = vim.api.nvim_create_augroup("UnlinkSnippetOnModeChange", { clear = true })

    vim.api.nvim_create_autocmd("ModeChanged", {
        group = unlink_group,
        pattern = { "s:n", "i:*" },
        desc = "Forget the current snippet when leaving the insert mode",
        callback = function(event)
            if luasnip.session and luasnip.session.current_nodes[event.buf] and not luasnip.session.jump_active then
                luasnip.unlink_current()
            end
        end,
    })

    local snippets_dir = require("cool.utils").nvim_root_dir .. "/snippets"
    require("luasnip.loaders.from_vscode").lazy_load({ paths = { snippets_dir } })
end

return {
    { "L3MON4D3/LuaSnip", config = luasnip_config, event = "InsertEnter" },

    {
        "saghen/blink.cmp",
        version = "1.*",
        event = "InsertEnter",
        dependencies = {
            "rafamadriz/friendly-snippets",
            "L3MON4D3/LuaSnip",
        },
        opts = blink_config,
        opts_extend = { "sources.default" },
    },
    {
        "olimorris/codecompanion.nvim",
        opts = {
            strategies = {
                chat = {
                    adapter = "openai",
                },
                inline = {
                    adapter = "openai",
                },
            },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        keys = "no_lazy",
    },
}
