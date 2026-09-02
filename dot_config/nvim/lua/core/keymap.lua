local map = vim.keymap.set

-- Toggle spell check
map("n", "<C-s>", ":set spell!<CR>", { desc = "Toggle spell check", silent = true })
map("i", "<C-s>", "<C-O>:set spell!<CR>", { desc = "Toggle spell check", silent = true })

-- Spell navigation
map("n", "z=", "z=", { desc = "Suggest spelling corrections" })
map("n", "zg", "zg", { desc = "Mark word as correct" })
map("n", "zw", "zw", { desc = "Mark word as incorrect" })

-- LSP mappings
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action", silent = true })

-- Basic file operations
map("n", "<leader>w", ":w<CR>", { desc = "Save" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })

-- Diagnostic panel
map("n", "<leader>dp", "<cmd>Telescope diagnostics<CR>", { desc = "Open Diagnostics Panel" })

-- Formatting
map("n", "<C-f>", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "LSP format" })

-- Copy diagnostics
map({ "n", "v" }, "<leader>cd", function()
  local start_line, end_line

  if vim.fn.mode() == "v" or vim.fn.mode() == "V" then
    start_line = vim.fn.line("v")
    end_line = vim.fn.line(".")
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
  else
    start_line = vim.fn.line(".")
    end_line = start_line
  end

  local severity_names = {
    [vim.diagnostic.severity.ERROR] = "Error",
    [vim.diagnostic.severity.WARN] = "Warning",
    [vim.diagnostic.severity.INFO] = "Info",
    [vim.diagnostic.severity.HINT] = "Hint",
  }

  local diagnostics = vim.diagnostic.get(0)
  local lines_with_issues = {}

  for _, d in ipairs(diagnostics) do
    local lnum = d.lnum + 1
    if lnum >= start_line and lnum <= end_line then
      local line_text = vim.api.nvim_buf_get_lines(0, d.lnum, d.lnum + 1, false)[1]
      local severity = severity_names[d.severity] or "Unknown"
      local message = ("[%d] %s\n%s (%s): %s"):format(lnum, line_text, severity, d.source or "Unknown", d.message)
      table.insert(lines_with_issues, message)
    end
  end

  if #lines_with_issues == 0 then
    vim.notify("No diagnostics in selected range", vim.log.levels.WARN)
    return
  end

  local final = table.concat(lines_with_issues, "\n\n")
  vim.fn.setreg("+", final)
  vim.notify("Copied " .. #lines_with_issues .. " diagnostic(s) to clipboard")
end, { desc = "Copy diagnostics on line or selection" })

-- Window splitting and management
map("n", "<leader>v", ":vsplit<CR>", { desc = "Vertical split", silent = true })
map("n", "<leader>h", ":split<CR>", { desc = "Horizontal split", silent = true })

-- LSP navigation
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to Declaration" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
map("n", "gr", vim.lsp.buf.references, { desc = "Go to References" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window", silent = true })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window", silent = true })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window", silent = true })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window", silent = true })

-- Window resizing
map("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height", silent = true })
map("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height", silent = true })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width", silent = true })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width", silent = true })

-- Multi cursor
map("n", "<leader>cl", function()
  local ns = vim.api.nvim_get_namespaces()["nvim.multicursor"]
  if ns then
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  end
end, { desc = "Clear multicursors" })

-- Mouse
vim.keymap.set({ "n", "v", "i" }, "<X1Mouse>", "<C-o>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "i" }, "<X2Mouse>", "<C-i>", { noremap = true, silent = true })
