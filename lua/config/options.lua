-- Options are automatically loaded before lazy.nvim startup.
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt
local g = vim.g

-- Leader keys (set early; LazyVim also sets these but explicit is fine).
g.mapleader = " "
g.maplocalleader = "\\"

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.colorcolumn = "100"
opt.termguicolors = true
opt.pumheight = 12
opt.showmode = false
opt.laststatus = 3 -- global statusline

-- Indentation defaults (most languages override via ftplugin / treesitter).
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.shiftround = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

-- Files
opt.undofile = true
opt.undolevels = 10000
opt.swapfile = false
opt.backup = false
opt.autoread = true
opt.confirm = true

-- Splits
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"

-- Folding via treesitter (LazyVim wires this; explicit values are fine).
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99

-- Misc
opt.updatetime = 200
opt.timeoutlen = 400
opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.virtualedit = "block"
opt.completeopt = "menu,menuone,noselect"
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
-- Each fillchar must be exactly one display cell. Stick to single ASCII
-- or known single-cell Unicode glyphs to avoid E1511.
opt.fillchars = {
  foldopen = "v",
  foldclose = ">",
  fold = " ",
  foldsep = " ",
  diff = "/",
  eob = " ",
}

-- Treat dashes as part of words (handy for kebab-case in frontend code).
vim.cmd([[autocmd FileType html,css,scss,javascript,typescript,javascriptreact,typescriptreact,vue,svelte,astro setlocal iskeyword+=-]])

-- Disable some Neovim default providers we don't use.
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
g.loaded_python3_provider = 1 -- keep python for debugpy etc.
