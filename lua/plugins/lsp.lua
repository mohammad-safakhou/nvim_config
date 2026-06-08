-- LSP customization on top of LazyVim language extras.
-- The Java/Python/Go/TypeScript/JSON/YAML/Tailwind/Docker extras already
-- configure their respective servers; here we tune them for daily usage.

return {
  -- Install all tooling up-front via Mason. The LazyVim language extras only
  -- install their servers on first filetype open, which is fine but feels
  -- broken on a fresh machine. Listing everything here makes a single
  -- `:Lazy sync` (or just opening Neovim once) install the full toolchain.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        -- Java
        "jdtls",
        "google-java-format",
        "java-debug-adapter",
        "java-test",
        -- Go
        "gopls",
        "gofumpt",
        "goimports",
        "golangci-lint",
        "delve",
        -- Python
        "pyright",
        "ruff",
        "debugpy",
        -- Frontend / web
        "typescript-language-server",
        "eslint-lsp",
        "prettierd",
        "tailwindcss-language-server",
        "css-lsp",
        "html-lsp",
        "json-lsp",
        "yaml-language-server",
        -- SQL
        "sqlls",
        "sqlfluff",
        -- Lua (for editing this config)
        "lua-language-server",
        "stylua",
        -- Shell
        "bash-language-server",
        "shfmt",
        "shellcheck",
        -- Misc
        "hadolint",
      })
    end,
  },

  -- LSP server settings.
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Inlay hints are nice for Go/TS; toggle with <leader>uh.
      inlay_hints = { enabled = true },
      diagnostics = {
        virtual_text = { spacing = 4, prefix = "●", source = "if_many" },
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
      },
      -- Override LazyVim's gopls setup hook. The upstream extra patches
      -- semanticTokensProvider by reading `client.config.capabilities
      -- .textDocument.semanticTokens`, which is nil on Neovim 0.12+ for
      -- recent gopls (gopls now advertises semantic tokens itself, so the
      -- workaround is unnecessary). Returning false tells LazyVim to use
      -- the default setup path without the broken patch.
      setup = {
        gopls = function(_, _)
          return false
        end,
      },
      servers = {
        -- Go
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                -- `fieldalignment` was removed in gopls v0.17.0; use hover on
                -- struct fields for size/offset info instead.
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-node_modules" },
              semanticTokens = true,
            },
          },
        },

        -- Python (LazyVim python extra uses basedpyright/pyright + ruff).
        pyright = {
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
                typeCheckingMode = "basic",
              },
            },
          },
        },

        -- Frontend
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "literal",
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },

        -- SQL: keep sqlls for navigation; disable its formatting since we use sqlfluff.
        sqlls = {
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
      },
    },
  },

  -- jdtls bootstrap.
  -- The Mason `jdtls` wrapper is `bash -> python3 -> java`. Two failure modes
  -- on this machine:
  --   1. `java` resolves to an asdf shim with no version selected, so jdtls
  --      gets a non-functional Java and exits before printing anything.
  --   2. `python3` resolves to an asdf shim with no python version selected,
  --      so the wrapper itself crashes before launching Java.
  -- Set both JAVA_HOME and ensure a working python3 is on PATH for the
  -- Neovim process; the spawned jdtls inherits this env.
  {
    "mfussenegger/nvim-jdtls",
    init = function()
      local home = vim.env.HOME

      -- Java 21 runtime
      local java_candidates = {
        home .. "/.asdf/installs/java/corretto-21.0.6.7.1",
        home .. "/.asdf/installs/java/corretto-21.0.2.13.1",
      }
      for _, jh in ipairs(java_candidates) do
        if vim.fn.executable(jh .. "/bin/java") == 1 then
          vim.env.JAVA_HOME = jh
          vim.env.PATH = jh .. "/bin:" .. (vim.env.PATH or "")
          break
        end
      end

      -- python3 for the jdtls launcher script. Prefer asdf's installed python
      -- (so it matches whatever the user has), fall back to Homebrew.
      local py_candidates = {
        home .. "/.asdf/installs/python/3.13.7/bin",
        home .. "/.asdf/installs/python/3.12.6/bin",
        "/opt/homebrew/bin",
        "/usr/local/bin",
      }
      for _, dir in ipairs(py_candidates) do
        if vim.fn.executable(dir .. "/python3") == 1 then
          vim.env.PATH = dir .. ":" .. (vim.env.PATH or "")
          break
        end
      end
    end,
  },

  -- Custom: postgrestools as a user-defined LSP server.
  -- Registered via lspconfig.configs only when the binary exists, so users
  -- without it installed don't see errors.
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      if vim.fn.executable("postgrestools") == 1 then
        local configs = require("lspconfig.configs")
        if not configs.postgrestools then
          configs.postgrestools = {
            default_config = {
              cmd = { "postgrestools", "lsp-proxy" },
              filetypes = { "sql", "pgsql" },
              root_dir = require("lspconfig.util").root_pattern(
                "postgrestools.jsonc",
                ".git"
              ),
              single_file_support = true,
            },
          }
        end
        opts.servers = opts.servers or {}
        opts.servers.postgrestools = opts.servers.postgrestools or {}
      end
      return opts
    end,
  },
}
