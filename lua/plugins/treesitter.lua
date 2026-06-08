-- Pin nvim-treesitter to the new `main` branch. The old `master` branch is
-- archived and LazyVim's current treesitter config (`TS.get_installed`) only
-- exists on `main`. Keeping the branch explicit so `:Lazy update` doesn't
-- accidentally check out `master`.
return {
  { "nvim-treesitter/nvim-treesitter", branch = "main" },
  { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
}
