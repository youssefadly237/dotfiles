return {
  "stevearc/aerial.nvim",
  lazy = true,
  cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
  keys = {
    { "<leader>o", "<cmd>AerialToggle!<CR>", desc = "Toggle Aerial outline" },
  },
  opts = {
    backends = { "lsp", "treesitter", "markdown" },
    layout = {
      max_width = { 40, 0.2 },
      min_width = 20,
      default_direction = "prefer_right",
    },
    show_guides = true,
    filter_kind = false,
    highlight_on_hover = true,
    autojump = false,
    on_attach = function(bufnr)
      vim.keymap.set("n", "]]", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "Next symbol" })
      vim.keymap.set("n", "[[", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "Previous symbol" })
    end,
  },
}
