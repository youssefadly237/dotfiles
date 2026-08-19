return {
  "youssefadly237/glyf.nvim",
  cmd = { "Glyf", "GlyfInsert", "GlyfBuild" },
  keys = {
    { "<leader>g", "<cmd>Glyf<cr>", desc = "Glyph search" },
  },
  opts = {
    picker = { prompt_prefix = " " },
    limit = 100,
  },
}
