return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("diffview").setup()
  end,
  keys = {
    { "<leader>ggd", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
    { "<leader>ggc", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
    { "<leader>ggh", "<cmd>DiffviewFileHistory<cr>", desc = "File History" },
    { "<leader>ggf", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (Current)" },
  },
}
