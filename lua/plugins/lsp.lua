-- LSP customization on top of LazyVim language extras.
-- The Java/Python/Go/TypeScript/JSON/YAML/Tailwind/Docker extras already
-- configure their respective servers; here we tune them for daily usage.

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    local test_pat = "_test%.go$"
    local function is_test(fname)
      return fname and fname:match(test_pat) ~= nil
    end

    vim.api.nvim_set_hl(0, "SnacksPickerTestFile", { link = "SnacksPickerComment" })

    local function pick(method)
      return function()
        local clients = vim.lsp.get_clients({ bufnr = 0, method = method })
        if #clients == 0 then
          return
        end
        local params = vim.lsp.util.make_position_params()
        if method == "textDocument/references" then
          ---@diagnostic disable-next-line: inject-field
          params.context = { includeDeclaration = true }
        end
        local all = {}
        local pending = #clients
        for _, c in ipairs(clients) do
          c:request(method, params, function(err, result)
            if not err and result then
              if vim.tbl_islist(result) then
                for _, r in ipairs(result) do
                  all[#all + 1] = r
                end
              else
                all[#all + 1] = result
              end
            end
            pending = pending - 1
            if pending > 0 then
              return
            end
            if #all == 0 then
              return
            end
            table.sort(all, function(a, b)
              local a_u = a.uri or a.targetUri
              local b_u = b.uri or b.targetUri
              local a_t = a_u and is_test(vim.uri_to_fname(a_u))
              local b_t = b_u and is_test(vim.uri_to_fname(b_u))
              if a_t ~= b_t then
                return not a_t
              end
              return false
            end)
            local oe = clients[1].offset_encoding
            if #all == 1 then
              vim.lsp.util.jump_to_location(all[1], oe, {
                reuse_win = true,
                tagstack = true,
              })
              return
            end
            local locs = vim.lsp.util.locations_to_items(all, oe)
            local bufmap = {}
            for _, b in ipairs(vim.api.nvim_list_bufs()) do
              if vim.bo[b].buflisted and vim.bo[b].buftype == "" and vim.api.nvim_buf_is_loaded(b) then
                local name = vim.api.nvim_buf_get_name(b)
                if name ~= "" then
                  bufmap[name] = b
                end
              end
            end
            local items = {}
            for _, loc in ipairs(locs) do
              items[#items + 1] = {
                text = loc.filename .. " " .. loc.text,
                buf = bufmap[loc.filename],
                file = loc.filename,
                pos = { loc.lnum, loc.col - 1 },
                end_pos = loc.end_lnum and loc.end_col and { loc.end_lnum, loc.end_col - 1 } or nil,
                line = loc.text,
                filename_hl = is_test(loc.filename) and "SnacksPickerTestFile" or nil,
              }
            end
            local title = method == "textDocument/definition" and "Definitions"
              or method == "textDocument/references" and "References"
              or method == "textDocument/implementation" and "Implementations"
              or "Type Definitions"
            Snacks.picker.pick({
              finder = function(_, _)
                return function(cb)
                  for _, item in ipairs(items) do
                    cb(item)
                  end
                end
              end,
              format = "file",
              title = title,
              auto_confirm = true,
              jump = { tagstack = true, reuse_win = true },
            })
          end)
        end
      end
    end

    local function override(buf)
      if not vim.lsp.get_clients({ bufnr = buf, method = "textDocument/definition" })[1] then
        return
      end
      local km = vim.keymap.set
      km("n", "gd", pick("textDocument/definition"), { buffer = buf, desc = "Goto Definition (sorted)" })
      km("n", "gr", pick("textDocument/references"), { buffer = buf, desc = "References (sorted)" })
      km("n", "gI", pick("textDocument/implementation"), { buffer = buf, desc = "Goto Implementation (sorted)" })
      km("n", "gy", pick("textDocument/typeDefinition"), { buffer = buf, desc = "Goto Type Definition (sorted)" })
    end
    -- Apply to existing buffers
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) then
        override(buf)
      end
    end
    -- Always override on enter (runs after Snacks' debounced callback)
    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function()
        override(vim.api.nvim_get_current_buf())
      end,
    })
  end,
})

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
