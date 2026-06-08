-- Keymaps are automatically loaded on the VeryLazy event.
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- Save & quit
map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file" })
map("i", "<C-s>", "<esc><cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Clear search highlight
map({ "n", "i" }, "<Esc>", "<cmd>noh<cr><Esc>", { desc = "Clear search highlight" })

-- Keep cursor centered when jumping
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Move selected lines up/down (visual mode)
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Better paste over selection: don't yank what was replaced
map("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })

-- Delete to black hole register
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

-- Quick yank/paste from system clipboard explicitly
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Diagnostics
map("n", "<leader>xl", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- Quickfix navigation
map("n", "<C-j>", "<cmd>cnext<cr>zz", { desc = "Next quickfix" })
map("n", "<C-k>", "<cmd>cprev<cr>zz", { desc = "Prev quickfix" })

-- Make current file executable (handy for scripts)
map("n", "<leader>cx", function()
  vim.fn.system({ "chmod", "+x", vim.fn.expand("%") })
  vim.notify("Made executable: " .. vim.fn.expand("%"), vim.log.levels.INFO)
end, { desc = "Make file executable" })

-- Quick toggles
map("n", "<leader>uw", function()
  vim.opt.wrap = not vim.opt.wrap:get()
  vim.notify("Wrap: " .. tostring(vim.opt.wrap:get()))
end, { desc = "Toggle wrap" })
