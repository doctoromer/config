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
    local snippets_dir = require("cool.config").nvim_root_dir .. "/snippets"
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
        config = cmp_config
    },
    { "L3MON4D3/LuaSnip", config = luasnip_config },

}
