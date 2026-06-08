-- Linters via nvim-lint. LazyVim ships nvim-lint already; this just maps
-- linters per filetype.
return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        go = { "golangcilint" },
        python = { "ruff" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        zsh = { "shellcheck" },
        sql = { "sqlfluff" },
        dockerfile = { "hadolint" },
        -- JS/TS linting is handled by eslint-lsp via LazyVim's typescript extra,
        -- so we don't double up here.
      },
    },
  },
}
