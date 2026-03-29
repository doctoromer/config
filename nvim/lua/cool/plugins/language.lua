vim.g.rustaceanvim = {
    tools = {
        hover_actions = {
            auto_focus = true,
        },
        ra_multiplex = {
            enable = true,
        },
    },
    server = {
        on_attach = function(client, _)
            client.server_capabilities.semanticTokensProvider = nil
        end,
        -- default_settings = {
        --     ["rust-analyzer"] = {
        --         procMacro = {
        --             enable = false
        --         }
        --     }
        -- }
    },
}

local function mason_config()
    local capabilities = require("blink.cmp").get_lsp_capabilities()
    vim.lsp.config("*", {
        capabilities = capabilities,
    })

    require("mason").setup({
        install_root_dir = require("cool.utils").download_dir .. "/mason",
        pip = { upgrade_pip = true },
    })
end

local function formatter_config()
    local formatters = {
        lua = { require("formatter.filetypes.lua").stylua },
        c = { require("formatter.filetypes.c").clangformat },
        rust = {
            {
                exe = "rustfmt",
                args = { "--edition 2024" },
                stdin = true,
            },
        },
        javascript = { require("formatter.filetypes.javascript").biome },
        javascriptreact = { require("formatter.filetypes.javascript").biome },
        python = {
            {
                exe = "ruff",
                args = {
                    "format",
                    "-q",
                    "--line-length=120",
                    "-",
                },
                stdin = true,
            },
        },
    }

    require("formatter").setup({ filetype = formatters })
end

return {
    {
        "mason-org/mason.nvim",
        config = mason_config,
    },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        opts = {},
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = { "saghen/blink.cmp" },
        opt = {},
    },
    {
        "nvimdev/lspsaga.nvim",
        event = "LspAttach",
        opts = {
            scroll_preview = {
                scroll_down = "<C-d>",
                scroll_up = "<C-u>",
            },
            finder = {
                vsplit = "v",
                split = "s",
                quit = { "q", "<esc>", "<C-c>" },
            },
            symbol_in_winbar = { enable = false },
            lightbulb = { enable = false },
            ui = {
                incoming = "⬊ ",
                outgoing = "⬉ ",
                hover = "⭐ ",
                title = false,
            },
        },
    },
    { "mhartington/formatter.nvim", cmd = { "Format", "FormatWrite" }, config = formatter_config },
    {
        "mrcjkb/rustaceanvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = "no_lazy",
        version = "^6",
        lazy = false,
        ft = { "rust" },
        config = function() end,
    },
}
