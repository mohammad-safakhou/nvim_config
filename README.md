# Neovim config

LazyVim-based setup tuned for daily work in Java, Python, Go and frontend
(TS/JS/React/Vue/Svelte/Tailwind), with SQL and REST tooling on the side.

## Highlights

- **Autocompletion disabled** by design. LSP, snippets, signature help and
  diagnostics still work; trigger omni-completion manually with `<C-x><C-o>`.
- **LazyVim language extras** for Java, Python, Go, TypeScript, Tailwind,
  JSON/YAML/TOML/Markdown, Docker, SQL — see `lazyvim.json`.
- **LSP**
  - `jdtls` for Java, pinned to a real Corretto 21 install (see `lua/plugins/lsp.lua`)
  - `gopls` with inlay hints, gofumpt, staticcheck, vuln check
  - `pyright` + `ruff` for Python
  - `ts_ls`, `eslint`, `tailwindcss`, `cssls`, `html`, `jsonls`, `yamlls`
  - `sqlls` (+ optional `postgrestools` when installed) for SQL
- **Formatting** via `conform.nvim`: google-java-format, gofumpt+goimports,
  ruff, prettierd, stylua, shfmt, sqlfluff. Format-on-save is on, toggle with
  `<leader>uF` or `:ConformDisable[!]` / `:ConformEnable`.
- **Linting** via `nvim-lint`: golangci-lint, ruff, shellcheck, sqlfluff,
  hadolint.
- **Debugging** via LazyVim's DAP core extra + delve (Go), debugpy (Python),
  java-debug-adapter + java-test (Java).
- **DB**: `vim-dadbod` + dadbod-ui under `<leader>D`.
- **REST**: `kulala.nvim` for `.http` files under `<leader>R`.
- **Go extras**: struct tags, if-err, GoTest, GoCoverage under `<leader>cG`.

## Layout

```
init.lua
lazyvim.json              -- LazyVim extras (language packs + DAP + test)
lazy-lock.json
lua/
  config/
    lazy.lua              -- lazy.nvim bootstrap
    options.lua           -- editor options
    keymaps.lua           -- extra keymaps
    autocmds.lua          -- whitespace trim, per-filetype indents, etc.
  plugins/
    lsp.lua               -- LSP servers + jdtls override + postgrestools
    formatting.lua        -- conform.nvim per-filetype formatters
    linting.lua           -- nvim-lint per-filetype linters
    no-completion.lua     -- disables nvim-cmp / blink.cmp
    db.lua                -- vim-dadbod + UI
    rest.lua              -- kulala REST client
    go-extras.lua         -- ray-x/go.nvim helpers
```

## First-run

```vim
:Lazy sync
:Mason
```

Mason will pull the toolchains listed in `lua/plugins/lsp.lua`. If `jdtls`
fails to start, make sure one of these Java binaries exists or edit the
candidate list in `lua/plugins/lsp.lua`:

- `~/.asdf/installs/java/corretto-21.0.6.7.1/bin/java`
- `~/.asdf/installs/java/corretto-21.0.2.13.1/bin/java`

## Handy keymaps

| Key            | Action                          |
| -------------- | ------------------------------- |
| `<C-s>`        | Save                            |
| `<S-h>/<S-l>`  | Prev / next buffer              |
| `<C-d>/<C-u>`  | Half page down/up, centered     |
| `J/K` (visual) | Move selection down/up          |
| `<leader>p`    | Paste without overwriting reg   |
| `<leader>d`    | Delete without yanking          |
| `<leader>y/Y`  | Yank to system clipboard        |
| `<leader>cx`   | `chmod +x` current file         |
| `<leader>uw`   | Toggle wrap                     |
| `<leader>uF`   | Toggle autoformat-on-save       |
| `<leader>D*`   | Database (DBUI)                 |
| `<leader>R*`   | REST client (kulala)            |
| `<leader>cG*`  | Go helpers (tags / tests / etc) |
