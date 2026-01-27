return {
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        border = "rounded",
      },
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "clangd",
        "eslint",
        "lua_ls",
        "pyright",
        "ts_ls",
        "bashls",
        "html",
        "cssls",
        "taplo",
        "texlab",
        "asm_lsp",
      },
      automatic_installation = true,
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "ruff",
        "clang-format",
        "prettier",
        "stylua",
        "markdownlint",
        "sql-formatter",
        "shfmt",
        "taplo",
        "latexindent",
        "asmfmt",
        "arduino_language_server",
      },
      auto_update = false,
      run_on_start = true,
    },
  },
}
