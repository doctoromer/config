local function mason_config()
    local lspconfig = require("lspconfig")
    local mason_lspconfig = require("mason-lspconfig")

    -- The setup is done here instead of using 'opts' or 'config' lazy keys to prevent some kind of race condition.
    -- Basically, sometimes for no good reason neodev doesn't work, and this fixes it.
    require("neodev").setup({})

    require("mason").setup({
        install_root_dir = require("cool.utils").download_dir .. "/mason",
        pip = { upgrade_pip = true },
    })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    mason_lspconfig.setup({})

    local function setup_generic_server(server_name)
        lspconfig[server_name].setup({ capabilities = capabilities })
    end

    mason_lspconfig.setup_handlers({
        setup_generic_server,
        clangd = function()
            lspconfig.clangd.setup({
                capabilities = capabilities,
                on_attach = function()
                    -- Zero for current buffer only
                    vim.diagnostic.disable(0)
                end
            })
        end,
    })
end

local function lsp_config()
    local no_virtual_text_handler = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false })
    vim.lsp.handlers["textDocument/publishDiagnostics"] = no_virtual_text_handler
end

local function formatter_config()
    local formatters = {
        lua = { require("formatter.filetypes.lua").stylua },
        c = { require("formatter.filetypes.c").clangformat },
    }

    if vim.fn.executable("autopep8") == 1 then
        formatters.python = {
            function()
                return {
                    exe = "autopep8",
                    args = {
                        "--in-place --max-line-length 120",
                        vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)),
                    },
                    stdin = false,
                }
            end,
        }
    end

    require("formatter").setup({ filetype = formatters })
end

return {
    {
        "williamboman/mason.nvim",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "folke/neodev.nvim",
        },
        config = mason_config,
    },
    { "folke/neodev.nvim" },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        cmd = { "MasonToolsInstall", "MasonToolsUpdate" },
        opts = {
            ensure_installed = {
                "clangd",
                "lua-language-server",
                "taplo",
                { "stylua", version = "v0.17.0" },
            },
            auto_update = false,
            run_on_start = false,
        },
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = { "williamboman/mason.nvim", "hrsh7th/cmp-nvim-lsp" },
        config = lsp_config,
    },
    {
        "nvimdev/lspsaga.nvim",
        dependencies = "neovim/nvim-lspconfig",
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
            },
        },
    },
    { "mhartington/formatter.nvim", cmd = { "Format", "FormatWrite" }, config = formatter_config },
}
