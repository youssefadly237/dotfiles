return {
  "neovim/nvim-lspconfig",
  version = false,
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp", -- Needed to bridge LSP and nvim-cmp
  },
  config = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local lsp = vim.lsp

    -- Disable formatting for LSPs where null-ls handles it
    local function disable_formatting(client)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end

    -- Helper function to configure and enable LSP
    local function setup(name, config)
      lsp.config(name, vim.tbl_extend("force", { capabilities = capabilities }, config or {}))
      lsp.enable(name)
    end

    -- Python LSP
    setup("ruff", {
      on_attach = function(client)
        client.server_capabilities.hoverProvider = false
      end,
      init_options = {
        settings = {
          logLevel = "info",
        },
      },
    })

    setup("pyright", {
      on_attach = disable_formatting,
      settings = {
        pyright = {
          disableOrganizeImports = true,
        },
        python = {
          analysis = {
            typeCheckingMode = "basic",
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "workspace",
          },
        },
      },
    })

    -- C/C++ LSP
    setup("clangd", {
      on_attach = disable_formatting,
    })

    -- TypeScript/JavaScript LSP
    setup("ts_ls", {
      on_attach = disable_formatting,
    })

    -- Rust
    setup("rust_analyzer", {
      settings = {
        ["rust-analyzer"] = {
          diagnostics = {
            enable = true,
            experimental = {
              enable = true,
            },
          },
          check = {
            command = "clippy",
          },
          rustfmt = {
            rangeFormatting = {
              enable = true,
            },
          },
          formatting = {
            enable = true,
          },
        },
      },
    })

    -- Lua LSP (for Neovim config/dev)
    setup("lua_ls", {
      on_attach = disable_formatting,
      settings = {
        Lua = {
          format = {
            enable = true,
          },
          indent = {
            style = "space",
            size = 2,
          },
          runtime = {
            version = "LuaJIT",
          },
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
        },
      },
    })

    -- Bash LSP
    setup("bashls", {
      on_attach = disable_formatting,
    })

    -- TOML LSP (Taplo) - disable formatting since we have null-ls taplo formatter
    setup("taplo", {
      on_attach = disable_formatting,
    })

    -- Typst LSP (Tinymist)
    setup("tinymist", {
      settings = {
        formatterMode = "typstyle",
        exportPdf = "onType",
        semanticTokens = "disable",
        projectResolution = "lockDatabase",
      },
    })

    -- HTML LSP
    setup("html")

    -- CSS LSP
    setup("cssls")

    -- LaTeX LSP (TexLab with TexLive 2025 integration)
    setup("texlab", {
      settings = {
        texlab = {
          build = {
            executable = "latexmk",
            args = {
              "-pdf",
              "-interaction=nonstopmode",
              "-synctex=1",
              "-outdir=build",
              "%f",
            },
            onSave = false,
            forwardSearchAfter = false,
          },
          forwardSearch = {
            executable = "zathura",
            args = { "--synctex-forward", "%l:1:%f", "%p" },
          },
          chktex = {
            onOpenAndSave = true,
            onEdit = false,
          },
          formatterLineLength = 80,
          latexFormatter = "latexindent",
          latexindent = {
            modifyLineBreaks = false,
          },
        },
      },
    })

    -- Assembly LSP
    setup("asm_lsp", {
      on_attach = disable_formatting,
      filetypes = { "asm", "s", "asm64" },
    })

    -- Arduino LSP (depends on clangd && arudino-cli)
    setup("arduino_language_server", {
      cmd = {
        "arduino-language-server",
        "-fqbn",
        "esp32:esp32:nodemcu-32s",
      },
      filetypes = { "ino", "arduino" },
    })
  end,
}
