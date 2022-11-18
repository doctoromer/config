local M = {}

vim.g.mapleader = ";"

M["legendary.nvim"] = function()
    return {
        { "<leader>m", require("legendary").find, description = "Show all keymaps" },
    }
end

M["nvim-lspconfig"] = function()
    return {
        { "<leader>gD", vim.lsp.buf.type_definition, description = "Goto type definition" },
        -- { "<leader>gf", vim.lsp.buf.formatting, description = "Format the entire file" },
        { "<leader>ca", vim.lsp.buf.code_action, description = "Perform code action" },
        { "<leader>gf", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", mode = "v", description = "Format code in range" },
        { "gD", vim.lsp.buf.declaration, description = "Goto symbol decleration" },
        { "gi", vim.lsp.buf.implementation, description = "Goto symbol implementation" },
    }
end

M["lspsaga.nvim"] = function()
    local saga_diagnostic = require("lspsaga.diagnostic")

    return {
        { "<leader>sf", "<cmd>Lspsaga lsp_finder<CR>", description = "Show symbol definition and references" },
        { "<leader>sp", "<cmd>Lspsaga peek_definition<CR>", description = "Preview symbol definition" },
        { "<leader>so", "<cmd>LSoutlineToggle<CR>", description = "Show file symbols" },
        { "K", "<cmd>Lspsaga hover_doc<CR>", description = "Show symbol hover information" },
        { "gr", "<cmd>Lspsaga rename<CR>", description = "Rename symbol" },
        { "]d", saga_diagnostic.goto_next, description = "Goto previous diagnostic" },
        { "[d", saga_diagnostic.goto_prev, description = "Goto next diagnostic" },
        { "<C-t>", "<cmd>Lspsaga open_floaterm<CR>", description = "Toggle float terminal" },
        { "<C-t>", "<cmd>Lspsaga close_floaterm<CR>", mode = "t" },
    }
end

M["formatter.nvim"] = function()
    return {
        { "<leader>F", "<cmd>Format<CR>", description = "Autoformat current file" },
    }
end

M["treesitter-unit"] = function()
    return {
        { "iu", ":lua require'treesitter-unit'.select()<CR>", mode = "x" },
        { "au", ":lua require'treesitter-unit'.select(true)<CR>", mode = "x" },
        { "iu", ":<c-u>lua require'treesitter-unit'.select()<CR>", mode = "o" },
        { "au", ":<c-u>lua require'treesitter-unit'.select(true)<CR>", mode = "o" },
    }
end

M["neogen"] = function()
    return {
        { "<leader>n", require("neogen").generate, mode = "n", description = "Autogenerate documentation" },
    }
end

M["nvim-cmp"] = function()
    local luasnip = require("luasnip")
    local cmp = require("cmp")

    local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    local tab = function()
        if cmp.visible() then
            cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
            luasnip.jump(1)
        elseif has_words_before() then
            cmp.complete()
        else
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), "n")
        end
    end

    local shift_tab = function()
        if cmp.visible() then
            cmp.select_prev_item()
        elseif luasnip.jumpable() then
            luasnip.jump(-1)
        end
    end

    return {
        { "<Tab>", tab, mode = { "i", "s" } },
        { "<S-Tab>", shift_tab, mode = { "i", "s" } },
    }
end

M["telescope.nvim"] = function()
    local telescope = require("telescope.builtin")

    return {
        { "<leader>f", telescope.find_files, description = "Find file" },
        { "<leader>a", telescope.live_grep, description = "Search inside all files recursively" },
        { "<leader>l", telescope.current_buffer_fuzzy_find, description = "Search in current file's lines" },
        { "<leader>H", telescope.help_tags, description = "Search help pages" },
        { "gx", telescope.lsp_references, description = "Show symbol references" },
        { "gd", telescope.lsp_definitions, description = "Goto symbol definition" },
        { "gs", telescope.lsp_document_symbols, description = "Show symbols" },
    }
end

M["gitsigns.nvim"] = function()
    local gitsigns = require("gitsigns")

    local function next_hunk()
        if vim.wo.diff then
            return "]c"
        end
        vim.schedule(gitsigns.next_hunk)
        return "<Ignore>"
    end

    local function previous_hunk()
        if vim.wo.diff then
            return "[c"
        end
        vim.schedule(gitsigns.prev_hunk)
        return "<Ignore>"
    end

    return {
        { "]c", next_hunk, description = "Goto next hunk", opts = { expr = true } },
        { "[c", previous_hunk, description = "Goto previous hunk", opts = { expr = true } },
        { "<leader>hs", gitsigns.stage_hunk, mode = { "n", "v" }, description = "Git stage hunk" },
        { "<leader>hr", gitsigns.reset_hunk, mode = { "n", "v" }, description = "Git reset hunk", favorite = true },
        { "<leader>hS", gitsigns.stage_buffer, description = "Git stage buffer" },
        { "<leader>hu", gitsigns.undo_stage_hunk, description = "Git undo stage buffer" },
        { "<leader>hR", gitsigns.reset_buffer, description = "Git reset buffer" },
        { "<leader>hp", gitsigns.preview_hunk, description = "Git preview hunk" },
        {
            "<leader>hb",
            function()
                gitsigns.blame_line({ full = true })
            end,
            description = "Git blame line",
        },
        { "<leader>ht", gitsigns.toggle_current_line_blame, description = "Toggle current git line blame" },
        { "<leader>hd", gitsigns.diffthis, description = "Show diff of current changes" },
        {
            "<leader>hD",
            function()
                gitsigns.diffthis("~")
            end,
            description = "Show diff from previous commit",
        },
        { "ih", ":<C-U>Gitsigns select_hunk<CR>", mode = { "o", "x" }, description = "Git hunk text object" },
    }
end

M["LuaSnip"] = function()
    return {
        { "<C-space>", require("luasnip").expand_or_jump, mode = { "i", "s" }, description = "Expand snippets" },
    }
end

M["diffview.nvim"] = function()
    local diffview = require("diffview")
    local function open_diffview()
        vim.ui.input({ prompt = "Enter git commit: " }, diffview.open)
    end
    return {
        { "<leader>do", open_diffview, description = "Open diffview on given commit or commit-like" },
        { "<leader>dc", diffview.close, description = "Close diffview" },
    }
end

M["Navigator.nvim"] = function()
    local navigator = require("Navigator")

    return {
        { "<M-h>", navigator.left, description = "Tmux left" },
        { "<M-j>", navigator.down, description = "Tmux down" },
        { "<M-k>", navigator.up, description = "Tmux up" },
        { "<M-l>", navigator.right, description = "Tmux right" },
    }
end

M["vim-argwrap"] = function()
    return {
        { "ga", "<cmd>ArgWrap<CR>", description = "Spread or unspread arguments, Use inside parenthesis" },
    }
end

M["vim-easymotion"] = function()
    return {
        { "<Space>", "<Plug>(easymotion-prefix)", description = "Prefix for movements (For example, <space>w)" },
    }
end

local paste_mode = false
local colorcolumn = nil

M["other_keymaps"] = function()
    local toggle_copy_mode = function()
        if paste_mode then
            vim.cmd("IndentBlanklineEnable")
            if vim.o.colorcolumn ~= nil then
                vim.o.colorcolumn = colorcolumn
            end
            vim.o.number = true
            vim.o.signcolumn = "yes"
        else
            vim.cmd("IndentBlanklineDisable")
            colorcolumn = vim.o.colorcolumn
            vim.o.colorcolumn = ""
            vim.o.number = false
            vim.o.signcolumn = "no"
        end
        paste_mode = not paste_mode
    end

    local function delete_special()
        local line_data = vim.api.nvim_win_get_cursor(0) -- returns {row, col}
        local current_line = vim.api.nvim_buf_get_lines(0, line_data[1] - 1, line_data[1], false)
        local delete_command = nil

        if current_line[1] == "" then
            delete_command = '"_dd'
        else
            delete_command = "dd"
        end

        vim.api.nvim_feedkeys(delete_command, "n", false)
    end

    return {
        -- General keymaps
        { "\\", ";" },

        -- Disable bad keys
        { "<home>", "<nop>", description = "Bad key" },
        { "<end>", "<nop>", description = "Bad key" },
        { "<del>", "<nop>", description = "Bad key" },
        { "<insert>", "<nop>", description = "Bad key" },
        { "<left>", "<nop>", description = "Bad key" },
        { "<down>", "<nop>", description = "Bad key" },
        { "<up>", "<nop>", description = "Bad key" },
        { "<right>", "<nop>", description = "Bad key" },

        -- Tabs
        { "<leader>tt", "<cmd>tabnew<CR>", description = "New tab" },
        { "gb", "<cmd>tabprevious<CR>", description = "Previous tab" },
        { "gf", "<cmd>-tabmove<CR>", description = "Move tab left" },
        { "gh", "<cmd>+tabmove<CR>", description = "Move tab right" },

        { "<leader>p", toggle_copy_mode, description = "Toggle copymode to allow copying from the vim inside the terminal" },
        { "dd", delete_special },

        -- Horizontal scroll
        { "zl", "zL", description = "Scroll right" },
        { "zh", "zH", description = "Scroll left" },

        -- Other
        { ">", ">gv", mode = "v", description = "Indent" },
        { "<", "<gv", mode = "v", description = "Dedent" },
    }
end

return M
