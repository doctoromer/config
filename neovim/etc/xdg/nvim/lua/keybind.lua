function map(mode, lhs, rhs, opts)
    opts = opts or { noremap = true, silent = true }
    vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

vim.g.mapleader = ";"

map("n", "<leader>x", "<cmd>Trouble<cr>")

-- Telescope
map("n", "<leader>f", "<cmd>Telescope find_files<cr>")
map("n", "<leader>a", "<cmd>Telescope live_grep<cr>")
map("n", "<leader>l", "<cmd>Telescope current_buffer_fuzzy_find<cr>")
map("n", "<leader>b", "<cmd>Telescope buffers<cr>")
map("n", "<leader>h", "<cmd>Telescope help_tags<cr>")
map("n", "<leader>m", "<cmd>Telescope keymaps<cr>")

-- Telescope LSP
map("n", "gx", "<cmd>Telescope lsp_references<cr>")
map("n", "gd", "<cmd>Telescope lsp_definitions<cr>")
map("n", "gs", "<cmd>Telescope lsp_document_symbols<cr>")


-- Easymotion
map("n", "<Space>", "<Plug>(easymotion-prefix)", {})
map("v", "<Space>", "<Plug>(easymotion-prefix)", {})

-- vim-tmux-navigator
map("n", "<M-h>", "<cmd>TmuxNavigateLeft<cr>")
map("n", "<M-j>", "<cmd>TmuxNavigateDown<cr>")
map("n", "<M-k>", "<cmd>TmuxNavigateUp<cr>")
map("n", "<M-l>", "<cmd>TmuxNavigateRight<cr>")

-- Argwrap
map("n", "ga", "<cmd>ArgWrap<cr>")

-- LSP
map("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>")
map("n", "<leader>gD", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
map("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>")
map("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
map("n", "gr", "<cmd>lua vim.lsp.buf.rename()<CR>")
map("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>")
map("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>")
map("n", "<leader>gf", "<cmd>lua vim.lsp.buf.formatting()<CR>")
map("v", "<leader>gf", "<cmd>lua vim.lsp.buf.range_formatting()<CR>")
map("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")

-- vsnips
map("i", "<C-space>", "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'", {expr = true})
map("s", "<C-space>", "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'", {expr = true})
map ("i", "<Tab>",  "vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>'", {expr = true})
map ("s", "<Tab>",  "vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>'", {expr = true})
map ("i", "<S-Tab>",  "vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'", {expr = true})
map ("s", "<S-Tab>",  "vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'", {expr = true})

-- nvim-dap
map("n", "<F5>", "<cmd>lua require'dap'.continue()<CR>")
map("n", "<F8>", "<cmd>lua require'dap'.step_over()<CR>")
map("n", "<F9>", "<cmd>lua require'dap'.step_into()<CR>")
map("n", "<F10>", "<cmd>lua require'dap'.step_out()<CR>")
map("n", "<leader>b", "<cmd>lua require'dap'.toggle_breakpoint()<CR>")
map("n", "<leader>B", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
map("n", "<leader>dr", "<cmd>lua require'dap'.repl.open()<CR>")
map("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<CR>")
map("n", "<leader>dr", "<cmd>lua require'dap'.repl.open()<CR>")
map("n", "<leader>do", "<cmd>lua require('dapui').toggle()<CR>")

-- General keybindings
map("n", ";", "<nop>")
map("n", "\\", ";")

-- Stay in visual mode after indent or unindent
map("v", ">", ">gv")
map("v", "<", "<gv")

-- Disable bad keys
map("n", "<home>", "<nop>")
map("n", "<end>", "<nop>")
map("n", "<del>", "<nop>")
map("n", "<insert>", "<nop>")
map("n", "<left>", "<nop>")
map("n", "<down>", "<nop>")
map("n", "<up>", "<nop>")
map("n", "<right>", "<nop>")

-- Tabs
map("n", "<leader>tt", "<cmd>tabnew<cr>")
map("n", "gb", "<cmd>tabprevious<cr>")
map("n", "gf", "<cmd>-tabmove<cr>")
map("n", "gh", "<cmd>+tabmove<cr>")

-- Horizontal scroll
map("n", "zl", "zL")
map("n", "zh", "zH")

-- Other
map("n", "Y", "y$")
map("n", "<c-l>", "<cmd>noh<cr>")
