local function cmp_config()
    local cmp = require("cmp")

    cmp.setup({
        snippet = {
            expand = function(args)
                require("luasnip").lsp_expand(args.body)
            end,
        },
        sources = cmp.config.sources(
            { { name = "luasnip" }, { name = "nvim_lsp" }, { name = "nvim_lsp_signature_help" } },
            { { name = "buffer" } },
            { { name = "path" } }
        ),
    })

    cmp.setup.cmdline("/", { sources = { { name = "buffer" } } })
    cmp.setup.cmdline("?", { sources = { { name = "buffer" } } })
    cmp.setup.cmdline(":", { sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }) })
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
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "neovim/nvim-lspconfig",
            { "saadparwaiz1/cmp_luasnip", dependencies = "L3MON4D3/LuaSnip" },
        },
        event = "InsertEnter",
        config = cmp_config,
    },
    { "L3MON4D3/LuaSnip", config = luasnip_config, event = "InsertEnter" },
}
