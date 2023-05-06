local function mason_config()
    vim.g.python3_host_prog = vim.fn.exepath("python3.8")
    local lspconfig = require("lspconfig")
    local mason_lspconfig = require("mason-lspconfig")

    require("mason").setup({
        install_root_dir = require("cool.options").nvim_root_dir .. "/mason",
        pip = {
            upgrade_pip = true,
        },
    })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    mason_lspconfig.setup({})

    mason_lspconfig.setup_handlers({
        function(server_name)
            lspconfig[server_name].setup({ capabilities = capabilities })
        end,
        pylsp = function()
            -- Maybe add cmp_nvim_lsp capabilities?
            lspconfig.pylsp.setup({ init_options = { documentFormatting = false } })
        end,
        lua_ls = function()
            lspconfig.lua_ls.setup({
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        -- Make the server aware of Neovim runtime files
                        -- workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                        telemetry = { enable = false },
                        diagnostics = { globals = "vim" },
                    },
                },
            })
        end,
    })
end

local function lsp_config()
    vim.lsp.handlers["textDocument/publishDiagnostics"] =
        vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false })
end

local function formatter_config()
    local formatters = {
        lua = { require("formatter.filetypes.lua").stylua },
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
    { "williamboman/mason.nvim", dependencies = "williamboman/mason-lspconfig.nvim", config = mason_config },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        cmd = { "MasonToolsInstall", "MasonToolsUpdate" },
        opts = {
            ensure_installed = {
                "clangd",
                "python-lsp-server",
                "cmake-language-server",
                "lua-language-server",
                "taplo",
                "stylua",
            },
            auto_update = false,
            run_on_start = false,
        },
    },
    { "folke/neodev.nvim", config = true },
    {
        "neovim/nvim-lspconfig",
        dependencies = { "williamboman/mason.nvim", "hrsh7th/cmp-nvim-lsp", "folke/neodev.nvim" },
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
        },
    },
    { "mhartington/formatter.nvim", cmd = { "Format", "FormatWrite" }, config = formatter_config },
}
