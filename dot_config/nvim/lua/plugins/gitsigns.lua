return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("gitsigns").setup({
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 500,
      },
    })
  end,
  keys = {
    { "<leader>ggb", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle Git Blame" },
    { "<leader>ggB", "<cmd>Gitsigns blame_line<cr>", desc = "Show Full Blame" },
  },
}
