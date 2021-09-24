local which_key = require("which-key")

-- Normal mode keybindings
which_key.register({
    ["<leader>"] = {
        f = {"<cmd>Telescope find_files<CR>", "Find file"},
        a = {"<cmd>Telescope live_grep<CR>", "Search in files"},
        l = {"<cmd>Telescope current_buffer_fuzzy_find<CR>", "Search in current file"},
        b = {"<cmd>Telescope buffers<CR>", "Find buffer"},
        h = {"<cmd>Telescope help_tags<CR>", "Help pages"},
        m = {"<cmd>Telescope keymaps<CR>", "Find keymaps"},

        gD = {"<cmd>lua vim.lsp.buf.type_definition()<CR>", "Goto type definition"},
        gf = {"<cmd>lua vim.lsp.buf.formatting()<CR>", "Format all file"},
        ca = {"<cmd>lua vim.lsp.buf.code_action()<CR>", "Code action"},

        gb = {"<cmd>Git blame<CR>", "Git blame"},
    },
    g = {
        x = {"<cmd>Telescope lsp_references<CR>", "Show references"},
        d = {"<cmd>Telescope lsp_definitions<CR>", "Goto definition"},
        s = {"<cmd>Telescope lsp_document_symbols<CR>", "Show symbols"},
        D = {"<Cmd>lua vim.lsp.buf.declaration()<CR>", "Goto decleration"},
        i = {"<cmd>lua vim.lsp.buf.implementation()<CR>", "Goto implementation"},
        r = {"<cmd>lua vim.lsp.buf.rename()<CR>", "Rename"},

        a = {"<cmd>ArgWrap<CR>", "Spread arguments"},
    },

    K = {"<Cmd>lua vim.lsp.buf.hover()<CR>", "Hover"},
    ["[d"] = {"<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", "Next diagnostic"},
    ["]d"] = {"<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", "Previous diagnostic"},

    ["<M-h>"] = {"<cmd>TmuxNavigateLeft<CR>", "Tmux left"},
    ["<M-j>"] = {"<cmd>TmuxNavigateDown<CR>", "Tmux down"},
    ["<M-k>"] = {"<cmd>TmuxNavigateUp<CR>", "Tmux up"},
    ["<M-l>"] = {"<cmd>TmuxNavigateRight<CR>", "Tmux right"},

    ["<Space>"] = {"<Plug>(easymotion-prefix)", "Easymotion prefix"},

    -- General keybindings
    [";"] = {"<nop>", ""},
    ["\\"] = {";", ""},

    -- Disable bad keys
    ["<home>"] = {"<nop>", "Bad key"},
    ["<end>"] = {"<nop>", "Bad key"},
    ["<del>"] = {"<nop>", "Bad key"},
    ["<insert>"] = {"<nop>", "Bad key"},
    ["<left>"] = {"<nop>", "Bad key"},
    ["<down>"] = {"<nop>", "Bad key"},
    ["<up>"] = {"<nop>", "Bad key"},
    ["<right>"] = {"<nop>", "Bad key"},

    -- Tabs
    ["<leader>tt"] = {"<cmd>tabnew<CR>", "New tab"},
    ["gb"] = {"<cmd>tabprevious<CR>", "Previous tab"},
    ["gf"] = {"<cmd>-tabmove<CR>", "Move tab left"},
    ["gh"] = {"<cmd>+tabmove<CR>", "Move tab right"},

    -- Horizontal scroll
    ["zl"] = {"zL", "Scroll right"},
    ["zh"] = {"zH", "Scroll left"},

    -- Other
    ["Y"] = {"y$", "Yank to end of line"},
    ["<c-l>"] = {"<cmd>noh<CR>", "Turn off search highlight"},
})

-- Visual mode keybindings
which_key.register({
    ["<leader>"] = {
        gf = {"<cmd>lua vim.lsp.buf.range_formatting()<CR>", "Format range"}
    },
    ["<Space>"] = {"<Plug>(easymotion-prefix)", "Easymotion prefix"},
    [">"] = {">gv", "Indent"},
    ["<"] = {"<gv", "Dedent"}
}, {mode = "v"})

vsnip_keys = {
    ["<C-space>"] = {"vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<nop>'", "Complete snippet", expr=true},
    ["<Tab>"] = {"vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>'", "Jump next placeholder", expr=true},
    ["<S-Tab>"] = {"vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'", "Jump previous placeholder", expr=true}
}

which_key.register(vsnip_keys, {mode = "i", noremap = false})
which_key.register(vsnip_keys, {mode = "s", noremap = false})

vim.g.mapleader = ";"

-- -- nvim-dap
-- map("n", "<F5>", "<cmd>lua require'dap'.continue()<CR>")
-- map("n", "<F8>", "<cmd>lua require'dap'.step_over()<CR>")
-- map("n", "<F9>", "<cmd>lua require'dap'.step_into()<CR>")
-- map("n", "<F10>", "<cmd>lua require'dap'.step_out()<CR>")
-- map("n", "<leader>b", "<cmd>lua require'dap'.toggle_breakpoint()<CR>")
-- map("n", "<leader>B", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
-- map("n", "<leader>dr", "<cmd>lua require'dap'.repl.open()<CR>")
-- map("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<CR>")
-- map("n", "<leader>dr", "<cmd>lua require'dap'.repl.open()<CR>")
-- map("n", "<leader>do", "<cmd>lua require('dapui').toggle()<CR>")

