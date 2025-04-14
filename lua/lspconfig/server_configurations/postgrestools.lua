local util = require("lspconfig.util")

return {
  default_config = {
    cmd = { "postgrestools" },
    filetypes = { "sql", "pgsql" },
    root_dir = util.root_pattern(".git", "."),
    single_file_support = true,
  },
}
