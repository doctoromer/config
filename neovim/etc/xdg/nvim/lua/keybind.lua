local which_key = require("which-key")

telescope = require("telescope.builtin")
navigator = require("Navigator")

-- Normal mode keybindings
which_key.register({
    ["<leader>"] = {
        f = {telescope.find_files, "Find file"},
        a = {telescope.live_grep, "Search in files"},
        l = {telescope.current_buffer_fuzzy_find, "Search in current file"},
        b = {telescope.buffers, "Find buffer"},
        h = {telescope.help_tags, "Help pages"},
        m = {telescope.keymaps, "Find keymaps"},

        gD = {vim.lsp.buf.type_definition, "Goto type definition"},
        gf = {vim.lsp.buf.formatting, "Format all file"},
        ca = {vim.lsp.buf.code_action, "Code action"},

        gb = {"<cmd>Git blame<CR>", "Git blame"},
    },
    g = {
        x = {telescope.lsp_references, "Show references"},
        d = {telescope.lsp_definitions, "Goto definition"},
        s = {telescope.lsp_document_symbols, "Show symbols"},
        D = {vim.lsp.buf.declaration, "Goto decleration"},
        i = {vim.lsp.buf.implementation, "Goto implementation"},
        r = {vim.lsp.buf.rename, "Rename"},

        a = {"<cmd>ArgWrap<CR>", "Spread arguments"},
    },

    K = {vim.lsp.buf.hover, "Hover"},
    ["[d"] = {vim.lsp.diagnostic.goto_prev, "Next diagnostic"},
    ["]d"] = {vim.lsp.diagnostic.goto_next, "Previous diagnostic"},

    ["<M-h>"] = {navigator.left, "Tmux left"},
    ["<M-j>"] = {navigator.down, "Tmux down"},
    ["<M-k>"] = {navigator.up, "Tmux up"},
    ["<M-l>"] = {navigator.right, "Tmux right"},

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

