return {
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
                pycodestyle = { enabled = false }, -- optional, disables pep8 warnings
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
            -- Disable formatting to avoid conflicts with pgformatter
            client.server_capabilities.documentFormattingProvider = false
          end,
        },
        postgrestools = {},
      },
    },
  },
}
