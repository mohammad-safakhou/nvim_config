-- HTTP/REST client for .http files. Use :Kulala* commands or the leader maps below.
-- Run requests with <leader>Rs, jump to the next/prev request with ]r / [r.
return {
  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    keys = {
      { "<leader>R", "", desc = "+rest" },
      { "<leader>Rs", function() require("kulala").run() end, desc = "Send request" },
      { "<leader>Ra", function() require("kulala").run_all() end, desc = "Send all requests" },
      { "<leader>Rr", function() require("kulala").replay() end, desc = "Replay last request" },
      { "<leader>Ri", function() require("kulala").inspect() end, desc = "Inspect request" },
      { "<leader>Rt", function() require("kulala").toggle_view() end, desc = "Toggle headers/body view" },
      { "<leader>Rc", function() require("kulala").copy() end, desc = "Copy as curl" },
      { "<leader>Re", function() require("kulala").set_selected_env() end, desc = "Select environment" },
      { "]r", function() require("kulala").jump_next() end, desc = "Next request" },
      { "[r", function() require("kulala").jump_prev() end, desc = "Prev request" },
    },
    opts = {
      default_view = "body",
      default_env = "dev",
      debug = false,
      show_icons = "on_request",
      icons = {
        inlay = { loading = "⏳", done = "✅", error = "❌" },
      },
    },
  },
}
