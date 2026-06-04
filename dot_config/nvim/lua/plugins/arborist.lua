return {
  "arborist-ts/arborist.nvim",
  config = function()
    require("arborist").setup({
      ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "python",
        "rust",
        "c",
        "cpp",
        "bash",
        "zsh",
        "markdown",
        "markdown_inline",
        "json",
        "yaml",
        "toml",
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "latex",
      },
    })
  end,
}
