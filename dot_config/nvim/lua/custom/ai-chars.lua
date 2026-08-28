-- you can AI but you can not hide from me (evil smile)

local M = {}

local ns = vim.api.nvim_create_namespace("ai_char_lint")
local group = vim.api.nvim_create_augroup("AiCharLint", { clear = true })

M.enabled = true
M.max_lines = 10000
M.ignore_filetypes = {
  man = true,
}

local chars = {}

local function add_char(cp, name)
  chars[vim.fn.nr2char(cp, true)] = name
end

add_char(0x00A0, "NO-BREAK SPACE")
add_char(0x1680, "OGHAM SPACE MARK")
add_char(0x2004, "THREE-PER-EM SPACE")
add_char(0x2005, "FOUR-PER-EM SPACE")
add_char(0x2006, "SIX-PER-EM SPACE")
add_char(0x2007, "FIGURE SPACE")
add_char(0x2008, "PUNCTUATION SPACE")
add_char(0x2009, "THIN SPACE")
add_char(0x200A, "HAIR SPACE")
add_char(0x2013, "EN DASH")
add_char(0x2014, "EM DASH")
add_char(0x2018, "LEFT SINGLE QUOTATION MARK")
add_char(0x2019, "RIGHT SINGLE QUOTATION MARK")
add_char(0x201C, "LEFT DOUBLE QUOTATION MARK")
add_char(0x201D, "RIGHT DOUBLE QUOTATION MARK")
add_char(0x2022, "BULLET")
add_char(0x2026, "HORIZONTAL ELLIPSIS")
add_char(0x202F, "NARROW NO-BREAK SPACE")
add_char(0x205F, "MEDIUM MATHEMATICAL SPACE")
add_char(0x2190, "LEFTWARDS ARROW")
add_char(0x2192, "RIGHTWARDS ARROW")
add_char(0x2212, "MINUS SIGN")
add_char(0xFEFF, "ZERO WIDTH NO-BREAK SPACE")

function M.scan(bufnr)
  bufnr = bufnr or 0

  if not M.enabled or M.ignore_filetypes[vim.bo[bufnr].filetype] then
    vim.diagnostic.reset(ns, bufnr)
    return
  end

  if vim.api.nvim_buf_line_count(bufnr) > M.max_lines then
    vim.diagnostic.reset(ns, bufnr)
    return
  end

  local diagnostics = {}
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for lnum, line in ipairs(lines) do
    if line:find("[\128-\255]") then
      for pat, name in pairs(chars) do
        local pos = 1

        while true do
          local s, e = line:find(pat, pos, true)
          if not s then
            break
          end

          diagnostics[#diagnostics + 1] = {
            lnum = lnum - 1,
            col = s - 1,
            end_col = e,
            severity = vim.diagnostic.severity.WARN,
            source = "ai-char-lint",
            message = "Suspicious char: " .. name,
          }

          pos = e + 1
        end
      end
    end
  end

  vim.diagnostic.set(ns, bufnr, diagnostics, {})
end

function M.toggle()
  M.enabled = not M.enabled

  if M.enabled then
    M.scan(0)
  else
    vim.diagnostic.reset(ns, 0)
  end

  vim.notify("ai-char-lint " .. (M.enabled and "enabled" or "disabled"))
end

function M.setup()
  vim.api.nvim_create_autocmd({ "BufWinEnter", "InsertLeave", "TextChanged" }, {
    group = group,
    pattern = "*",
    callback = function(args)
      M.scan(args.buf)
    end,
  })

  vim.api.nvim_create_user_command("AiCharLintToggle", M.toggle, {})
end

return M
