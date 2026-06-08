-- Format-on-save and per-language formatters via conform.nvim.
-- LazyVim already wires conform; we just tune which formatter runs per filetype.

return {
  {
    "stevearc/conform.nvim",
    -- LazyVim already wires format-on-save through `vim.lsp.buf.format` +
    -- conform. We only customise which formatter runs per filetype.
    opts = {
      default_format_opts = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        -- Java: google-java-format (installed via Mason).
        java = { "google-java-format" },
        -- Python: ruff handles import sort + format quickly.
        python = { "ruff_organize_imports", "ruff_format" },
        -- Go: goimports first (manages imports), then gofumpt.
        go = { "goimports", "gofumpt" },
        -- Frontend
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        vue = { "prettierd", "prettier", stop_after_first = true },
        svelte = { "prettierd", "prettier", stop_after_first = true },
        astro = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        scss = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        jsonc = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        graphql = { "prettierd", "prettier", stop_after_first = true },
        -- SQL
        sql = { "sqlfluff" },
        -- Shell
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        -- Lua
        lua = { "stylua" },
      },
      formatters = {
        ["google-java-format"] = {
          prepend_args = { "--aosp" }, -- 4-space indent variant; remove for 2-space.
        },
        shfmt = {
          prepend_args = { "-i", "2", "-ci" },
        },
        sqlfluff = {
          args = { "format", "--disable-progress-bar", "-" },
        },
      },
    },
  },
}
-- Use LazyVim's built-in `<leader>uf` to toggle format-on-save (buffer) and
-- `<leader>uF` for global. Both are wired by LazyVim automatically.
