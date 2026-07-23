-- Line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Indentation
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smartindent = true

-- Search
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true

-- Clipboard
vim.o.clipboard = "unnamedplus"

-- Mouse
vim.o.mouse = "a"

-- Backup and swap
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.undofile = true

-- UI improvements
vim.o.termguicolors = true
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.o.wrap = false
vim.o.cursorline = true
vim.o.signcolumn = "yes"
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.winborder = "single"

-- Completion
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.completeopt = "menu,menuone,noselect"

-- Performance
vim.o.updatetime = 300
vim.o.timeoutlen = 500

vim.o.list = true
vim.o.listchars = "tab:→ ,space:·,trail:·,nbsp:␣"

-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable netrw (using file explorer plugin instead)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Spell checking
vim.opt.spell = true
vim.opt.spelllang = { "en" }

-- Folding
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldenable = false

-- Python-specific folding override
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.foldmethod = "indent"
  end,
})

-- bidi
vim.opt.termbidi = true

-- neovide
vim.g.neovide_scale_factor = 0.75
