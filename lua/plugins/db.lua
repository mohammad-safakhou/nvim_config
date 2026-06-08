-- Database client using vim-dadbod + UI.
-- Set DB connections in ~/.local/share/db_ui/connections.json or via
-- `let g:dbs = {...}` per-project (e.g. in a .nvim.lua exrc file).

return {
  {
    "tpope/vim-dadbod",
    cmd = { "DB" },
    dependencies = {
      { "kristijanhusak/vim-dadbod-ui" },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" } },
    },
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    keys = {
      { "<leader>D", "", desc = "+database" },
      { "<leader>Du", "<cmd>DBUIToggle<cr>", desc = "Toggle DBUI" },
      { "<leader>Da", "<cmd>DBUIAddConnection<cr>", desc = "Add DB connection" },
      { "<leader>Df", "<cmd>DBUIFindBuffer<cr>", desc = "Find DB buffer" },
      { "<leader>Dr", "<cmd>DBUIRenameBuffer<cr>", desc = "Rename DB buffer" },
      { "<leader>Dl", "<cmd>DBUILastQueryInfo<cr>", desc = "Last query info" },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_winwidth = 40
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
      vim.g.db_ui_execute_on_save = 0
    end,
  },
}
