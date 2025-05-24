local function cmp_config()
    local cmp = require("cmp")

    cmp.setup({
        snippet = {
            expand = function(args)
                require("luasnip").lsp_expand(args.body)
            end,
        },
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "nvim_lsp_signature_help" },
        }, { name = "luasnip" }, { { name = "buffer" } }, { { name = "path" } }),
    })

    cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
    })
    cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
    })
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

    { "hrsh7th/cmp-cmdline", event = "InsertEnter" },
    { "hrsh7th/cmp-path", event = "InsertEnter" },
    { "hrsh7th/cmp-buffer", event = "InsertEnter" },
    { "hrsh7th/cmp-nvim-lsp", event = "InsertEnter" },
    { "hrsh7th/cmp-nvim-lsp-signature-help", event = "InsertEnter" },
    {
        "saadparwaiz1/cmp_luasnip",
        event = "InsertEnter",
        dependencies = "L3MON4D3/LuaSnip",
    },

    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        config = cmp_config,
        dependencies = {
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "saadparwaiz1/cmp_luasnip",
        },
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
