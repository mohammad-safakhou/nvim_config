-- Autocmds are automatically loaded on the VeryLazy event.
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

local aug = function(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- Trim trailing whitespace on save (skip markdown to preserve hard breaks).
vim.api.nvim_create_autocmd("BufWritePre", {
  group = aug("trim_whitespace"),
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if ft == "markdown" or ft == "diff" then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[silent! keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- Reload file if it changed on disk (e.g. branch switch).
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = aug("checktime"),
  command = "checktime",
})

-- Language-specific indentation overrides (most LazyVim language extras
-- already handle this via treesitter, but explicit values avoid surprises).
local two_space = {
  "javascript", "javascriptreact", "typescript", "typescriptreact",
  "vue", "svelte", "astro",
  "html", "css", "scss", "sass", "less",
  "json", "jsonc", "yaml", "toml",
  "lua",
}
vim.api.nvim_create_autocmd("FileType", {
  group = aug("indent_2"),
  pattern = two_space,
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
    vim.bo.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = aug("indent_go"),
  pattern = "go",
  callback = function()
    -- Go uses tabs, width 4.
    vim.bo.expandtab = false
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = aug("indent_4"),
  pattern = { "java", "python", "sql" },
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
    vim.bo.expandtab = true
  end,
})

-- Show diagnostics on cursor hold without using the inline virtual text spam.
vim.api.nvim_create_autocmd("CursorHold", {
  group = aug("diag_float"),
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
  end,
})

-- `gqq` / `gqap` need `textwidth` set; many filetypes leave it at 0 (no
-- wrap). Apply a sensible width to almost every buffer and let prose
-- filetypes also auto-wrap as you type. Runs late (BufWinEnter) so it wins
-- against ftplugins and editorconfig defaults.
local prose_ft = { markdown = true, gitcommit = true, text = true, mail = true }
local no_wrap_ft = { TelescopePrompt = true, snacks_picker_input = true, help = true, qf = true, lazy = true, mason = true }

vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
  group = aug("textwidth"),
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if ft == "" or no_wrap_ft[ft] then
      return
    end
    if prose_ft[ft] then
      vim.bo[args.buf].textwidth = 80
      -- Add `t` so prose lines auto-wrap as you type.
      local fo = vim.bo[args.buf].formatoptions
      if not fo:find("t") then
        vim.bo[args.buf].formatoptions = fo .. "t"
      end
    else
      vim.bo[args.buf].textwidth = 100
    end
    -- Ensure `c` (wrap comments) and `q` (allow `gq` to format comments)
    -- are always present, regardless of ftplugin defaults.
    local fo = vim.bo[args.buf].formatoptions
    for _, flag in ipairs({ "c", "q", "r", "j" }) do
      if not fo:find(flag) then
        fo = fo .. flag
      end
    end
    vim.bo[args.buf].formatoptions = fo

    -- Clear `formatexpr` so `gq` uses Vim's built-in wrapping instead of the
    -- LSP's range-format (which often refuses to touch comments or no-ops).
    vim.bo[args.buf].formatexpr = ""
  end,
})

-- Silent autosave on buffer-leave and focus-loss. We use `noautocmd` to
-- skip BufWritePre/BufWritePost autocmds (so format-on-save does NOT run
-- here). Manual saves with <C-s> / :w still format as normal.
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
  group = aug("autosave"),
  callback = function(args)
    local buf = args.buf
    if vim.bo[buf].buftype ~= "" then
      return -- skip terminals, help, quickfix, prompt, etc.
    end
    if not vim.bo[buf].modifiable or vim.bo[buf].readonly then
      return
    end
    if vim.api.nvim_buf_get_name(buf) == "" then
      return -- unnamed buffer, no path to save to
    end
    if not vim.bo[buf].modified then
      return
    end
    -- `update` only writes when the buffer is modified. `noautocmd` skips
    -- BufWritePre/Post which is what runs format-on-save / lint-on-save.
    vim.api.nvim_buf_call(buf, function()
      vim.cmd("silent! noautocmd update")
    end)
  end,
})
