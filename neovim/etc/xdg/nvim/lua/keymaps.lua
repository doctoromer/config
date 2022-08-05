local M = {}

vim.g.mapleader = ";"

M["nvim-lspconfig"] = function()
  return {
    {"<leader>gD", vim.lsp.buf.type_definition, description = "Goto type definition"},
    {"<leader>gf", vim.lsp.buf.formatting, description = "Format all file"},
    {"<leader>ca", vim.lsp.buf.code_action, description = "Code action"},
    {"<leader>gf", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", description = "Format range", mode = "v"},
    {"gD", vim.lsp.buf.declaration, description = "Goto decleration"},
    {"gi", vim.lsp.buf.implementation, description = "Goto implementation"},
  }
end

M["lspsaga.nvim"] = function()
  local saga_provider = require("lspsaga.provider")
  local saga_hover = require("lspsaga.hover")
  local saga_rename = require("lspsaga.rename")
  local saga_diagnostic = require("lspsaga.diagnostic")
  local saga_floaterm = require("lspsaga.floaterm")

  vim.api.nvim_set_keymap(
    "t",
    "<C-t>",
    "<C-\\><C-n>:lua require('lspsaga.floaterm').close_float_terminal()<CR>",
    {noremap = true, silent = true}
  )

  return {
    {"<leader>gd", saga_provider.lsp_finder, description = "Show definition and references"},
    {"K", saga_hover.render_hover_doc, description = "Show hover information"},
    {"gr", saga_rename.rename, description = "Rename symbol"},
    {"gp", saga_provider.preview_definition, description = "Preview definition"},
    {"[d", saga_diagnostic.navigate("prev"), description = "Previous diagnostic"},
    {"]d", saga_diagnostic.navigate("next"), description = "Next diagnostic"},
    {"<C-t>", saga_floaterm.open_float_terminal, description = "Toggle float terminal"},
  }
end


M["treesitter-unit"] = function()
  return {
    {"iu", ":lua require'treesitter-unit'.select()<CR>", mode = "x"},
    {"au", ":lua require'treesitter-unit'.select(true)<CR>", mode = "x"},
    {"iu", ":<c-u>lua require'treesitter-unit'.select()<CR>", mode = "o"},
    {"au", ":<c-u>lua require'treesitter-unit'.select(true)<CR>", mode = "o"}
  }
end

M["neogen"] = function()
  return {
    {"<leader>n", require("neogen").generate, mode = "n"}
  }
end

M["telescope.nvim"] = function()
  local telescope = require("telescope.builtin")

  return {
    {"<leader>f", telescope.find_files, description = "Find file"},
    {"<leader>a", telescope.live_grep, description = "Search in files"},
    {"<leader>l", telescope.current_buffer_fuzzy_find, description = "Search in current file"},
    {"<leader>b", telescope.buffers, description = "Find buffer"},
    {"<leader>H", telescope.help_tags, description = "Help pages"},
    {"<leader>m", telescope.keymaps, description = "Find keymaps"},
    {"gx", telescope.lsp_references, description = "Show references"},
    {"gd", telescope.lsp_definitions, description = "Goto definition"},
    {"gs", telescope.lsp_document_symbols, description = "Show symbols"},
  }
end

M["gitsigns.nvim"] = function()
  local gitsigns = require("gitsigns")
  return {
    {"]c", "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", description = "Goto next hunk", opts = {expr = true}},
    {"[c", "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", description = "Goto previous hunk", opts = {expr = true}},
    {"<leader>hs", ":Gitsigns stage_hunk<CR>", description = "Git stage hunk", mode = {"n", "v"}},
    {"<leader>hr", ":Gitsigns reset_hunk<CR>", description = "Git reset hunk", mode = {"n", "v"}},
    {"<leader>hS", gitsigns.stage_buffer, description = "Git stage buffer"},
    {"<leader>hu", gitsigns.undo_stage_hunk, description = "Git undo stage buffer"},
    {"<leader>hR", gitsigns.reset_buffer, description = "Git reset buffer"},
    {"<leader>hp", gitsigns.preview_hunk, description = "Git preview hunk"},
    {"<leader>hb", function() gitsigns.blame_line{full = true} end, description = "Git blame line"},
    {"<leader>tb", gitsigns.toggle_current_line_blame, description = "Toggle current git line blame"},
    {"<leader>hd", gitsigns.diffthis, description = ""},
    {"<leader>hD", function() gitsigns.diffthis("~") end, description = ""},
    {"<leader>td", gitsigns.toggle_deleted, description = ""},
    {"ih", ":<C-U>Gitsigns select_hunk<CR>", description = "", mode = {"o", "x"}},
  }
end

M["Navigator.nvim"] = function()
  local navigator = require("Navigator")

  return {
    {"<M-h>", navigator.left, description = "Tmux left"},
    {"<M-j>", navigator.down, description = "Tmux down"},
    {"<M-k>", navigator.up, description = "Tmux up"},
    {"<M-l>", navigator.right, description = "Tmux right"},
  }
end

M["vim-argwrap"] = function()
  return {
      {"ga", "<cmd>ArgWrap<CR>", description = "Spread arguments"}
  }
end

M["vim-easymotion"] = function()
  return {
    {"<Space>", "<Plug>(easymotion-prefix)", description = "Easymotion prefix"}
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

  return {
    -- General keymaps
    {";", "<nop>", description = ""},
    {"\\", ";", description = ""},

    -- Disable bad keys
    {"<home>", "<nop>", description = "Bad key"},
    {"<end>", "<nop>", description = "Bad key"},
    {"<del>", "<nop>", description = "Bad key"},
    {"<insert>", "<nop>", description = "Bad key"},
    {"<left>", "<nop>", description = "Bad key"},
    {"<down>", "<nop>", description = "Bad key"},
    {"<up>", "<nop>", description = "Bad key"},
    {"<right>", "<nop>", description = "Bad key"},

    -- Tabs
    {"<leader>tt", "<cmd>tabnew<CR>", description = "New tab"},
    {"gb", "<cmd>tabprevious<CR>", description = "Previous tab"},
    {"gf", "<cmd>-tabmove<CR>", description = "Move tab left"},
    {"gh", "<cmd>+tabmove<CR>", description = "Move tab right"},

    {"<leader>p", toggle_copy_mode, description = "Toggle copymode"},

    -- Horizontal scroll
    {"zl", "zL", description = "Scroll right"},
    {"zh", "zH", description = "Scroll left"},

    -- Other
    {">", ">gv", description = "Indent", mode = "v"},
    {"<", "<gv", description = "Dedent", mode = "v"},
  }
end

return M
