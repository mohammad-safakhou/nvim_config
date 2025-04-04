return {
  {
    "neovim/nvim-lspconfig",
    opts = {
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
              usePlaceholders = true,
              completeUnimported = true,
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
      },
    },
  },
}
