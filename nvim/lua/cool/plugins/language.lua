local function mason_config()
    vim.g.python3_host_prog = vim.fn.exepath("python3.8")
    local lspconfig = require("lspconfig")
    local mason_lspconfig = require("mason-lspconfig")

    -- The setup is done here instead of using 'opts' or 'config' lazy keys to prevent some kind of race condition.
    -- Basically, sometimes for no good reason neodev doesn't work, and this fixes it.
    require("neodev").setup({})

    require("mason").setup({
        install_root_dir = require("cool.utils").download_dir .. "/mason",
        pip = { upgrade_pip = true },
    })

    local py_download = require("cool.py_download")
    -- The setup prepend the bin directory of downloaded pex files to $PATH
    -- This should be called after mason.setup because it also prepends to path
    py_download.setup()

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    mason_lspconfig.setup({})

    local function setup_generic_server(server_name)
        lspconfig[server_name].setup({ capabilities = capabilities })
    end

    mason_lspconfig.setup_handlers({
        setup_generic_server,
        clangd = function()
            setup_generic_server("clangd")
            vim.diagnostic.disable(0)
        end,
    })

    local pex_lsp_servers = { "pylsp", "cmake" }
    for _, server_name in ipairs(pex_lsp_servers) do
        setup_generic_server(server_name)
    end
end

local function lsp_config()
    vim.lsp.handlers["textDocument/publishDiagnostics"] =
        vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false })
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
                "stylua",
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
            },
        },
    },
    { "mhartington/formatter.nvim", cmd = { "Format", "FormatWrite" }, config = formatter_config },
}
