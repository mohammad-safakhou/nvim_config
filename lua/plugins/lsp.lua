return {
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        postgrestools = function()
          require("lspconfig/configs").postgrestools = require("lspconfig.server_configurations.postgrestools")
          return true
        end,
      },
      servers = {
        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
              gofumpt = true,
              goimports = true,
              useplaceholders = true,
              completeunimported = true,
            },
          },
        },
        pylsp = {
          settings = {
            pylsp = {
              plugins = {
                pycodestyle = { enabled = false },
                pyflakes = { enabled = true },
                jedi_completion = { enabled = true },
                jedi_definition = { enabled = true },
                jedi_references = { enabled = true },
              },
            },
          },
        },
        sqls = {
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
          end,
        },
        postgrestools = {},
      },
    },

    config = function(_, opts)
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if ok then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
      end

      require("lspconfig").util.default_config = vim.tbl_extend("force", require("lspconfig").util.default_config, {
        capabilities = capabilities,
      })

      require("lspconfig.configs").postgrestools = require("lspconfig.server_configurations.postgrestools")

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          local jdtls = require("jdtls")

          local home = os.getenv("HOME")
          local workspace_dir = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

          local fallback_java = "/Users/safa.safakhou/.asdf/installs/java/corretto-21.0.3.9.1/bin/java"
          local java_bin = vim.fn.exepath("java")
          local java_version_output = vim.fn.systemlist(java_bin .. " -version")
          local major = tonumber(java_version_output[1]:match("(%d+)"))

          if not major or major < 21 then
            java_bin = fallback_java
          end

          local config = {
            cmd = {
              java_bin,
              "-Declipse.application=org.eclipse.jdt.ls.core.id1",
              "-Dosgi.bundles.defaultStartLevel=4",
              "-Declipse.product=org.eclipse.jdt.ls.core.product",
              "-Dlog.protocol=true",
              "-Dlog.level=ALL",
              "-Xms1g",
              "--add-modules=ALL-SYSTEM",
              "--add-opens",
              "java.base/java.util=ALL-UNNAMED",
              "--add-opens",
              "java.base/java.lang=ALL-UNNAMED",
              "-jar",
              vim.fn.glob(home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
              "-configuration",
              home .. "/.local/share/nvim/mason/packages/jdtls/config_mac",
              "-data",
              workspace_dir,
            },
            root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
            settings = {
              java = {
                signatureHelp = { enabled = true },
                contentProvider = { preferred = "fernflower" },
              },
            },
            init_options = {
              bundles = {},
            },
          }

          jdtls.start_or_attach(config)
        end,
      })
    end,
  },
}
