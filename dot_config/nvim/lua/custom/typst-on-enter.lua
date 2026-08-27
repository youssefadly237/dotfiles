local M = {}

function M.handle()
  local bufnr = vim.api.nvim_get_current_buf()
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = "tinymist" })[1]
  if not client then
    return false
  end

  local experimental = client.server_capabilities.experimental
  if type(experimental) ~= "table" or not experimental.onEnter then
    return false
  end

  local params = vim.lsp.util.make_range_params(0, client.offset_encoding)

  local ok, res = pcall(client.request_sync, client, "experimental/onEnter", params, 1000, bufnr)
  local edits = ok and res and not res.err and res.result
  if type(edits) ~= "table" or #edits == 0 then
    return false
  end

  local edit = edits[1]

  local placeholder = edit.newText:find("%$0")
  local before = edit.newText:sub(1, (placeholder or #edit.newText + 1) - 1)
  edit.newText = edit.newText:gsub("%$0", "")

  local line = vim.api.nvim_buf_get_lines(bufnr, edit.range.start.line, edit.range.start.line + 1, false)[1] or ""
  local start_col = vim.str_byteindex(line, client.offset_encoding, edit.range.start.character, false)

  vim.lsp.util.apply_text_edits(edits, bufnr, client.offset_encoding)

  local segs = vim.split(before, "\n", { plain = true })
  local row = edit.range.start.line + #segs
  local col = (#segs > 1) and #segs[#segs] or (start_col + #before)
  vim.api.nvim_win_set_cursor(0, { row, col })
  return true
end

function M.attach(bufnr)
  -- NOTE: deliberately NOT an expr-mapping: expr callbacks run under
  -- textlock (E565), so apply_text_edits would fail there.
  vim.keymap.set("i", "<CR>", function()
    if M.handle() then
      return
    end
    local cr = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
    vim.api.nvim_feedkeys(cr, "n", false)
  end, { buffer = bufnr, silent = true, desc = "Tinymist onEnter" })
end

return M
