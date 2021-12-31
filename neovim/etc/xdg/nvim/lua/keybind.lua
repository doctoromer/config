local M = {}

vim.g.mapleader = ";"

M["nvim-lspconfig"] = function()
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
        },
        ["[d"] = {vim.lsp.diagnostic.goto_prev, "Next diagnostic"},
        ["]d"] = {vim.lsp.diagnostic.goto_next, "Previous diagnostic"},
    }
end

M["lspsaga.nvim"] = function(saga_provider, saga_hover, saga_rename, saga_diagnostic, saga_floaterm)
    vim.api.nvim_set_keymap(
        "t",
        "<C-t>",
        "<C-\\><C-n>:lua require('lspsaga.floaterm').close_float_terminal()<CR>",
        {noremap = true, silent = true}
    )
    return {
        ["<leader>"] = {
            gd = {saga_provider.lsp_finder, "Show definition and references"}
        },
        K = {saga_hover.render_hover_doc, "Show hover information"},
        gr = {saga_rename.rename, "Rename symbol"},
        gp = {saga_provider.preview_definition, "Preview definition"},
        ["[d"] = {saga_diagnostic.navigate("prev"), "Previous diagnostic"},
        ["]d"] = {saga_diagnostic.navigate("next"), "Next diagnostic"},
        ["<C-t>"] = {saga_floaterm.open_float_terminal, "Toggle float terminal"},
    }
end

M["treesitter-unit"] = function()
  vim.api.nvim_set_keymap('x', 'iu', ':lua require"treesitter-unit".select()<CR>', {noremap=true})
  vim.api.nvim_set_keymap('x', 'au', ':lua require"treesitter-unit".select(true)<CR>', {noremap=true})
  vim.api.nvim_set_keymap('o', 'iu', ':<c-u>lua require"treesitter-unit".select()<CR>', {noremap=true})
  vim.api.nvim_set_keymap('o', 'au', ':<c-u>lua require"treesitter-unit".select(true)<CR>', {noremap=true})
  return {}
end

M["telescope.nvim"] = function(telescope)
    return {
        ["<leader>"] = {
            f = {telescope.find_files, "Find file"},
            a = {telescope.live_grep, "Search in files"},
            l = {telescope.current_buffer_fuzzy_find, "Search in current file"},
            b = {telescope.buffers, "Find buffer"},
            H = {telescope.help_tags, "Help pages"},
            m = {telescope.keymaps, "Find keymaps"},
        },
        g = {
            x = {telescope.lsp_references, "Show references"},
            d = {telescope.lsp_definitions, "Goto definition"},
            s = {telescope.lsp_document_symbols, "Show symbols"},
        }
    }
end

M["vim-fugitive"] = function()
    return {
        ["<leader>"] = {
            gb = {"<cmd>Git blame<CR>", "Git blame"}
        }
    }
end

M["Navigator.nvim"] = function(navigator)
    return {
        ["<M-h>"] = {navigator.left, "Tmux left"},
        ["<M-j>"] = {navigator.down, "Tmux down"},
        ["<M-k>"] = {navigator.up, "Tmux up"},
        ["<M-l>"] = {navigator.right, "Tmux right"},
    }
end

M["vim-argwrap"] = function()
    return {
        ga = {"<cmd>ArgWrap<CR>", "Spread arguments"}
    }
end

M["vim-easymotion"] = function()
    return {
        ["<Space>"] = {"<Plug>(easymotion-prefix)", "Easymotion prefix"}
    }
end

M["which-key.nvim"] = function()
    return {
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
        gb = {"<cmd>tabprevious<CR>", "Previous tab"},
        gf = {"<cmd>-tabmove<CR>", "Move tab left"},
        gh = {"<cmd>+tabmove<CR>", "Move tab right"},

        -- Horizontal scroll
        zl = {"zL", "Scroll right"},
        zh = {"zH", "Scroll left"},

        -- Other
        [">"] = {">gv", "Indent", mode="v"},
        ["<"] = {"<gv", "Dedent", mode="v"},

        -- Center after search
        n = {"nzz", "Search next"},
        N = {"Nzz", "Search previous"},
    }
end

return M
