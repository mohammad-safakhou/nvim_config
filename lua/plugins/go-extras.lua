-- Extra Go quality-of-life on top of LazyVim's go extra (gopls + dap-go).
-- Provides struct tag editing, test generation, and quick run/test maps.
return {
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "go", "gomod", "gosum", "gowork" },
    build = ':lua require("go.install").update_all_sync()',
    opts = {
      lsp_cfg = false, -- LazyVim's go extra already configures gopls
      lsp_inlay_hints = { enable = false }, -- handled by nvim-lspconfig
      dap_debug = true,
      dap_debug_keymap = false,
      trouble = true,
      luasnip = true,
    },
    keys = {
      { "<leader>cG", "", desc = "+go" },
      { "<leader>cGt", "<cmd>GoTest<cr>", desc = "Go test (package)" },
      { "<leader>cGf", "<cmd>GoTestFunc<cr>", desc = "Go test (func)" },
      { "<leader>cGc", "<cmd>GoCoverage<cr>", desc = "Go coverage" },
      { "<leader>cGa", "<cmd>GoAddTag<cr>", desc = "Add struct tag" },
      { "<leader>cGr", "<cmd>GoRmTag<cr>", desc = "Remove struct tag" },
      { "<leader>cGi", "<cmd>GoIfErr<cr>", desc = "Generate if err" },
      { "<leader>cGm", "<cmd>GoModTidy<cr>", desc = "go mod tidy" },
      { "<leader>cGg", "<cmd>GoGenerate<cr>", desc = "go generate" },
    },
  },
}
