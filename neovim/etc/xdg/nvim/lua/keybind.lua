local M = {}

local which_key = require("which-key")

-- Normal mode keybindings
function M.telescope()
    telescope = require("telescope.builtin")
    return {
        ["<leader>"] = {
            f = {telescope.find_files, "Find file"},
            a = {telescope.live_grep, "Search in files"},
            l = {telescope.current_buffer_fuzzy_find, "Search in current file"},
            b = {telescope.buffers, "Find buffer"},
            h = {telescope.help_tags, "Help pages"},
            m = {telescope.keymaps, "Find keymaps"},
        },
        g = {
            x = {telescope.lsp_references, "Show references"},
            d = {telescope.lsp_definitions, "Goto definition"},
            s = {telescope.lsp_document_symbols, "Show symbols"},
        }
    }
end

function M.lspconfig()
    return {
        ["<leader>"] = {
            gD = {vim.lsp.buf.type_definition, "Goto type definition"},
            gf = {vim.lsp.buf.formatting, "Format all file"},
            ca = {vim.lsp.buf.code_action, "Code action"},
            gf = {"<cmd>lua vim.lsp.buf.range_formatting()<CR>", "Format range", mode="v"}
        },
        g = {
            D = {vim.lsp.buf.declaration, "Goto decleration"},
            i = {vim.lsp.buf.implementation, "Goto implementation"},
            r = {vim.lsp.buf.rename, "Rename"},
        },
        K = {vim.lsp.buf.hover, "Hover"},
        ["[d"] = {vim.lsp.diagnostic.goto_prev, "Next diagnostic"},
        ["]d"] = {vim.lsp.diagnostic.goto_next, "Previous diagnostic"},
    }
end

function M.fugitive()
    return {
        ["<leader>"] = {
            gb = {"<cmd>Git blame<CR>", "Git blame"}
        }
    }
end

function M.argwrap()
    return {
        ga = {"<cmd>ArgWrap<CR>", "Spread arguments"}
    }
end

function M.navigator()
    navigator = require("Navigator")
    return {
        ["<M-h>"] = {navigator.left, "Tmux left"},
        ["<M-j>"] = {navigator.down, "Tmux down"},
        ["<M-k>"] = {navigator.up, "Tmux up"},
        ["<M-l>"] = {navigator.right, "Tmux right"},
    }
end

function M.easymotion()
    return {
        ["<Space>"] = {"<Plug>(easymotion-prefix)", "Easymotion prefix"}
    }
end

which_key.register {
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
    [">"] = {">gv", "Indent", mode="v"},
    ["<"] = {"<gv", "Dedent", mode="v"}
}

-- Temporary direct calls, Until there will be a better way to set same mapping for multiple modes
vsnip_keys = {
    ["<C-space>"] = {"vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : ''", "Complete snippet", expr=true},
    ["<Tab>"] = {"vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : pumvisible() ? '<C-n>' : '<Tab>'", "Jump next placeholder", expr=true},
    ["<S-Tab>"] = {"vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : pumvisible() ? '<C-p>' : '<S-Tab>'", "Jump previous placeholder", expr=true}
}

which_key.register(vsnip_keys, {mode = "i", noremap = false})
which_key.register(vsnip_keys, {mode = "s", noremap = false})

which_key.register({
    ["<Space>"] = {"<Plug>(easymotion-prefix)", "Easymotion prefix", mode = "v"}
})

-- Setting the leader key
vim.g.mapleader = ";"

return M
