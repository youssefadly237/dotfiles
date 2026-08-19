return {
  "nvimtools/none-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvimtools/none-ls-extras.nvim",
  },
  config = function()
    local null_ls = require("null-ls")
    local formatting = null_ls.builtins.formatting
    local diagnostics = null_ls.builtins.diagnostics

    null_ls.setup({
      sources = {
        -- C/C++
        formatting.clang_format,

        -- Python
        {
          method = null_ls.methods.FORMATTING,
          filetypes = { "python" },
          generator = null_ls.formatter({
            command = "ruff",
            args = { "format", "--stdin-filename", "$FILENAME", "-" },
            to_stdin = true,
          }),
        },
        {
          method = null_ls.methods.CODE_ACTION,
          filetypes = { "python" },
          generator = null_ls.generator({
            command = "ruff",
            args = { "check", "--fix", "--stdin-filename", "$FILENAME", "-" },
            to_stdin = true,
          }),
        },

        -- Lua
        formatting.stylua,

        -- JavaScript/TypeScript
        formatting.prettier,

        -- Markdown
        require("none-ls.diagnostics.eslint_d").with({
          condition = function(utils)
            return utils.root_has_file({ ".eslintrc", ".eslintrc.js", ".eslintrc.json" })
          end,
        }),
        formatting.prettier.with({
          filetypes = { "markdown", "md" },
          extra_args = { "--prose-wrap", "always", "--print-width", "80" },
        }),
        diagnostics.markdownlint,

        -- sql
        formatting.sql_formatter.with({
          extra_args = { "--language", "postgresql" },
        }),

        -- Bash
        formatting.shfmt.with({
          extra_args = { "-i", "4" },
        }),

        -- POSIX shell
        formatting.shfmt.with({
          filetypes = { "sh" },
          extra_args = { "-i", "4", "-ln", "posix" },
        }),

        -- Zsh
        formatting.shfmt.with({
          filetypes = { "zsh" },
          extra_args = { "-i", "4", "-ln", "zsh" },
        }),

        -- TOML
        {
          method = null_ls.methods.FORMATTING,
          filetypes = { "toml" },
          generator = null_ls.formatter({
            command = "taplo",
            args = { "format", "-" },
            to_stdin = true,
          }),
        },

        -- Assembly
        formatting.asmfmt,
      },
    })
  end,
}
