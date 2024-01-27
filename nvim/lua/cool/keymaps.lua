local M = {}

vim.g.mapleader = ";"

M["legendary.nvim"] = function()
    return {
        {
            itemgroup = "Finders",
            keymaps = {
                { "<leader>m", require("legendary").find, description = "Show all keymaps" },
            },
        },
    }
end

M["nvim-lspconfig"] = function()
    return {
        {
            itemgroup = "Language",
            description = "Smart langauge features",
            keymaps = {
                { "<leader>gD", vim.lsp.buf.type_definition, description = "Goto type definition" },
                { "gD", vim.lsp.buf.declaration, description = "Goto symbol decleration" },
                { "gi", vim.lsp.buf.implementation, description = "Goto symbol implementation" },
            },
        },
    }
end

M["lspsaga.nvim"] = function()
    local saga_diagnostic = require("lspsaga.diagnostic")

    return {
        {
            itemgroup = "Language",
            keymaps = {
                { "<leader>sf", "<cmd>Lspsaga lsp_finder<CR>", description = "Show symbol definition and references" },
                { "<leader>sp", "<cmd>Lspsaga peek_definition<CR>", description = "Preview symbol definition" },
                { "K", "<cmd>Lspsaga hover_doc<CR>", description = "Show symbol hover information" },
                { "gr", "<cmd>Lspsaga rename<CR>", description = "Rename symbol" },
                {
                    "]d",
                    function()
                        saga_diagnostic:goto_next()
                    end,
                    description = "Goto previous diagnostic",
                },
                {
                    "[d",
                    function()
                        saga_diagnostic:goto_prev()
                    end,
                    description = "Goto next diagnostic",
                },
            },
        },
        {
            itemgroup = "Miscellaneous",
            keymaps = {
                { "<C-t>", "<cmd>Lspsaga term_toggle<CR>", description = "Toggle float terminal" },
                { "<C-t>", "<cmd>Lspsaga term_toggle<CR>", mode = "t" },
            },
        },
    }
end

M["formatter.nvim"] = function()
    return {
        {
            itemgroup = "Language",
            keymaps = {
                { "<leader>F", "<cmd>Format<CR>", description = "Autoformat current file" },
            },
        },
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
        {
            itemgroup = "Miscellaneous",
            keymaps = {
                { "<leader>n", require("neogen").generate, mode = "n", description = "Autogenerate documentation" },
            },
        },
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
        {
            itemgroup = "Finders",
            description = "Stuff that helps you find other stuff",
            keymaps = {
                { "<leader>f", telescope.find_files, description = "find a file" },
                { "<leader>a", telescope.live_grep, description = "search inside all files recursively" },
                { "<leader>H", telescope.help_tags, description = "Search help pages" },
                { "<leader>l", telescope.current_buffer_fuzzy_find, description = "search in current file's lines" },
            },
        },
        {
            itemgroup = "Language",
            keymaps = {
                { "gx", telescope.lsp_references, description = "Show symbol references" },
                { "gd", telescope.lsp_definitions, description = "Goto symbol definition" },
                { "gs", telescope.lsp_document_symbols, description = "Show symbols" },
            },
        },
    }
end

M["dir-telescope.nvim"] = function()
    local dir_telescope = require("telescope").extensions.dir

    return {
        {
            itemgroup = "Finders",
            keymaps = {
                { "<leader>df", dir_telescope.find_files, description = "Find a file in a sub directory" },
                {
                    "<leader>da",
                    dir_telescope.live_grep,
                    description = "Search inside all files recursively in a sub directory",
                },
            },
        },
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
        {
            itemgroup = "Git operations",
            description = "Smart langauge features",
            keymaps = {
                { "]c", next_hunk, description = "Goto next hunk", opts = { expr = true } },
                { "[c", previous_hunk, description = "Goto previous hunk", opts = { expr = true } },
                { "<leader>hs", gitsigns.stage_hunk, mode = { "n", "v" }, description = "Git stage hunk" },
                {
                    "<leader>hr",
                    gitsigns.reset_hunk,
                    mode = { "n", "v" },
                    description = "Git reset hunk",
                    favorite = true,
                },
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
            },
        },
    }
end

M["LuaSnip"] = function()
    return {
        {
            itemgroup = "Miscellaneous",
            keymaps = {
                {
                    "<C-space>",
                    require("luasnip").expand_or_jump,
                    mode = { "i", "s" },
                    description = "Expand snippets",
                },
            },
        },
    }
end

M["Navigator.nvim"] = function()
    local navigator = require("Navigator")
    local modes = { "n", "i", "c" }

    return {
        {
            itemgroup = "Navigation",
            description = "Move around",
            keymaps = {
                { "<M-h>", navigator.left, description = "Tmux left", modes = modes },
                { "<M-j>", navigator.down, description = "Tmux down", modes = modes },
                { "<M-k>", navigator.up, description = "Tmux up", modes = modes },
                { "<M-l>", navigator.right, description = "Tmux right", modes = modes },
            },
        },
    }
end

M["treesj"] = function()
    return {
        {
            itemgroup = "Editing",
            description = "Edit text",
            keymaps = {
                { "ga", require("treesj").toggle, description = "Spread and join arguments, Use inside parenthesis" },
            },
        },
    }
end

M["nvim-comment"] = function()
    return {
        {
            itemgroup = "Editing",
            keymaps = {
                { "gc", description = "Toggle comment action (Example: gcap)", modes = { "x", "n" } },
                { "gcc", description = "Toggle comment for one line" },
            },
        },
    }
end

M["hop.nvim"] = function()
    local hop = require("hop")
    local direction = require("hop.hint").HintDirection

    return {
        {
            itemgroup = "Navigation",
            keymaps = {
                { "<space><motion>", description = "Multijump motion, try it!" },
                { "<space>w", ":HopWordAC<CR>", description = "", modes = { "n", "v" } },
                {
                    "<space>W",
                    function() hop.hint_patterns({ direction = direction.AFTER_CURSOR }, '\\S\\+') end,
                    description = "",
                },
                {
                    "<space>E",
                    function() hop.hint_patterns({ direction = direction.AFTER_CURSOR }, '\\S\\s') end,
                    description = "",
                },
                { "<space>b", ":HopWordBC<CR>", description = "", modes = { "n", "v" } },
                {
                    "<space>B",
                    function() hop.hint_patterns({ direction = direction.BEFORE_CURSOR }, '\\S\\+') end,
                    description = "",
                },
                { "<space>j", ":HopLineStartAC<CR>", description = "", modes = { "n", "v" } },
                { "<space>k", ":HopLineStartBC<CR>", description = "", modes = { "n", "v" } },
                {
                    "<space>f",
                    function() hop.hint_char1({ direction = direction.AFTER_CURSOR }) end,
                    description = "",
                    modes = { "n", "v" },
                },
                {
                    "<space>F",
                    function() hop.hint_char1({ direction = direction.BEFORE_CURSOR }) end,
                    description = "",
                    modes = { "n", "v" },
                },
                {
                    "<space>t",
                    function() hop.hint_char1({ direction = direction.AFTER_CURSOR, hint_offset = -1 }) end,
                    description = "",
                    modes = { "n", "v" },
                },
                {
                    "<space>T",
                    function() hop.hint_char1({ direction = direction.BEFORE_CURSOR, hint_offset = 1 }) end,
                    description = "",
                    modes = { "n", "v" },
                },
            }
        }
    }
end

M["vim-indent-object"] = function()
    local modes = { "v", "o" }
    return {
        {
            itemgroup = "Editing",
            keymaps = {
                { "ai", description = "Line above and indent level text object", mode = modes },
                { "ii", description = "Indent level and line below text object", mode = modes },
                { "aI", description = "Lines above/below indent level text object", mode = modes },
            },
        },
    }
end

M["vim-textobj-variable-segment"] = function()
    local modes = { "o", "x" }
    return {
        {
            itemgroup = "Editing",
            keymaps = {
                { "iv", description = "Word in symbol text object", mode = modes },
                { "av", description = "Word in symbol including '_' text object", mode = modes },
            },
        },
    }
end

local paste_mode = false
local colorcolumn = nil

M["other_keymaps"] = function()
    local toggle_copy_mode = function()
        if paste_mode then
            vim.cmd("IBLEnable")
            if vim.o.colorcolumn ~= nil then
                vim.o.colorcolumn = colorcolumn
            end
            vim.o.number = true
            vim.o.signcolumn = "yes"
        else
            vim.cmd("IBLDisable")
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

    local function insert_spaces(is_before)
        return function()
            local current_line = vim.api.nvim_win_get_cursor(0)[1]
            if is_before then
                current_line = current_line - 1
            end
            local new_lines = {}

            for _ = 1, vim.v.count1 do
                table.insert(new_lines, "")
            end
            vim.api.nvim_buf_set_lines(0, current_line, current_line, false, new_lines)
        end
    end

    return {
        -- General keymaps
        { "\\", ";" },

        -- Disable bad keys
        { "<home>", "<nop>" },
        { "<end>", "<nop>" },
        { "<del>", "<nop>" },
        { "<insert>", "<nop>" },
        { "<left>", "<nop>" },
        { "<down>", "<nop>" },
        { "<up>", "<nop>" },
        { "<right>", "<nop>" },

        {
            itemgroup = "Tab management",
            description = "Create, move and reorder tabs",
            keymaps = {
                { "<leader>tt", "<cmd>tabnew<CR>", description = "New tab" },
                { "<leader>to", "<cmd>tabonly<CR>", description = "Close all other tabs" },
                { "gb", "<cmd>tabprevious<CR>", description = "Previous tab" },
                { "gf", "<cmd>-tabmove<CR>", description = "Move tab left" },
                { "gh", "<cmd>+tabmove<CR>", description = "Move tab right" },
            },
        },
        {
            itemgroup = "Miscellaneous",
            description = "Other stuff",
            keymaps = {
                {
                    "<leader>p",
                    toggle_copy_mode,
                    description = "Toggle copymode to allow copying from vim to outside of the terminal",
                },

                { "[<space>", insert_spaces(true), description = "Add new lines before current line" },
                { "]<space>", insert_spaces(false), description = "Add new lines after current line" },
            },
        },
        {
            itemgroup = "Navigation",
            keymaps = {
                { "zl", "zL", description = "Scroll Horizontally right" },
                { "zh", "zH", description = "Scroll Horizontally left" },
            },
        },
        {
            itemgroup = "Language",
            keymaps = {
                {
                    "<leader>D",
                    function()
                        if vim.diagnostic.is_disabled(0) then
                            vim.diagnostic.enable(0)
                        else
                            vim.diagnostic.disable(0)
                        end
                    end,
                    description = "Toggle diagnostics display",
                },
            },
        },

        -- Other
        { "dd", delete_special },
        { ">", ">gv", mode = "v" },
        { "<", "<gv", mode = "v" },
        {"<leader>-", "<cmd>ToggleWhitespace<CR>", description = "Show/Hide whitespaces at the end of lines" },
    }
end

return M
